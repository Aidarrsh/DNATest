//
//  AuthUser.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//

import Foundation
import AuthenticationServices
import GoogleSignIn
import CryptoKit
import UIKit
import FirebaseAuth
import os

struct BackendSession {
    let accessToken: String
    let userId: Int
    let userName: String
}

final class AuthViewModel: NSObject {
    // callbacks
    var onBackendLoginSuccess: ((BackendSession) -> Void)?
    var onAuthFailure: ((Error) -> Void)?
    
    // deps
    private let api = CourtAIAPI()
    private let tokenStore: TokenStore = KeychainTokenStore()
    
    // Apple
    private var currentNonce: String?
    private var appleController: ASAuthorizationController?
    private var presentationAnchor: ASPresentationAnchor?
    
    // Logger
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "aidarrsh.DNATest",
                             category: "Auth")
    
    // MARK: Google → Firebase → CourtAI
    func signInWithGoogle(from presenting: UIViewController) {
        let t0 = Date()
        log.info("Google: begin sign-in (presenting: \(String(describing: type(of: presenting))) )")
        
        Task { @MainActor in
            do {
                // 1) Google Sign-In
                let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
                let gid = result.user
                log.debug("Google: signed in, userID=\(gid.userID ?? "<nil>"), hasProfile=\(gid.profile != nil, privacy: .public)")
                
                let idToken = gid.idToken?.tokenString
                let accessToken = gid.accessToken.tokenString
                log.debug("Google: got tokens (idToken=\(self.redact(idToken), privacy: .public), accessToken=\(self.redact(accessToken), privacy: .public))")
                
                guard let idTokenUnwrapped = idToken else {
                    self.log.error("Google: idToken missing")
                    throw AuthError.googleSDK("No Google idToken")
                }
                
                // 2) Firebase Auth
                let credential = GoogleAuthProvider.credential(withIDToken: idTokenUnwrapped, accessToken: accessToken)
                let authResult = try await Auth.auth().signIn(with: credential)
                log.info("Firebase: Google credential signIn OK, uid=\(authResult.user.uid, privacy: .public)")
                
                // 3) Firebase idToken
                let fbIdToken = try await authResult.user.getIDToken()
                log.debug("Firebase: got idToken=\(self.redact(fbIdToken), privacy: .public)")
                
                // 4) CourtAI
                let tApiStart = Date()
                log.info("CourtAI: login request start")
                let court = try await api.login(firebaseIdToken: fbIdToken)
                self.log.info("CourtAI: login OK in \(self.ms(from: tApiStart)) ms, user=\(court.me.name, privacy: .public) (id=\(court.me.id, privacy: .public))")
                self.log.debug("CourtAI: accessToken=\(self.redact(court.accessToken), privacy: .public)")
                
                // 5) save
                try tokenStore.save(court.accessToken)
                log.info("Keychain: accessToken saved")
                
                // 6) callback
                let session = BackendSession(accessToken: court.accessToken, userId: court.me.id, userName: court.me.name)
                onBackendLoginSuccess?(session)
                
                log.info("Google flow finished in \(self.ms(from: t0)) ms")
            } catch {
                self.logError(error, prefix: "Google flow failed")
                onAuthFailure?(error)
            }
        }
    }
    
    // MARK: Apple → Firebase → CourtAI
    func signInWithApple(presentationAnchor: ASPresentationAnchor) {
        let t0 = Date()
        log.info("Apple: begin sign-in (anchor exists=\(true, privacy: .public))")
        
        let nonce = Self.randomNonceString()
        currentNonce = nonce
        log.debug("Apple: nonce prepared (len=\(nonce.count, privacy: .public))")
        
        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]
        request.nonce = sha256(nonce)
        log.debug("Apple: request configured (scopes=fullName,email)")
        
        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        self.appleController = controller
        self.presentationAnchor = presentationAnchor
        
        log.info("Apple: performing requests…")
        controller.performRequests()
        
    }
    
    // MARK: helpers
    private func sha256(_ input: String) -> String {
        SHA256.hash(data: Data(input.utf8)).map { String(format: "%02x", $0) }.joined()
    }
    private static func randomNonceString(length: Int = 32) -> String {
        let charset = Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""; result.reserveCapacity(length)
        var remaining = length
        while remaining > 0 {
            var random: [UInt8] = .init(repeating: 0, count: 16)
            SecRandomCopyBytes(kSecRandomDefault, random.count, &random)
            random.forEach {
                if remaining == 0 { return }
                if $0 < charset.count { result.append(charset[Int($0)]); remaining -= 1 }
            }
        }
        return result
    }
    
    // MARK: logging helpers
    private func redact(_ token: String?) -> String {
        guard let t = token, !t.isEmpty else { return "<nil>" }
        if t.count <= 12 { return "•••(\(t.count))" }
        return "\(t.prefix(8))…\(t.suffix(4))(\(t.count))"
    }
    private func ms(from start: Date) -> Int {
        Int(Date().timeIntervalSince(start) * 1000)
    }
    private func logError(_ error: Error, prefix: String) {
        if let urlErr = error as? URLError {
            log.error("\(prefix): URLError code=\(urlErr.code.rawValue, privacy: .public) (\(String(describing: urlErr.code), privacy: .public)) desc=\(urlErr.localizedDescription, privacy: .public)")
        } else if let authErr = error as? AuthError {
            log.error("\(prefix): AuthError=\(String(describing: authErr), privacy: .public)")
        } else {
            let ns = error as NSError
            log.error("\(prefix): NSError domain=\(ns.domain, privacy: .public) code=\(ns.code, privacy: .public) desc=\(ns.localizedDescription, privacy: .public)")
        }
    }
}

extension AuthViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        let anchorExists = (presentationAnchor != nil)
        log.debug("Apple: presentationAnchor requested (exists=\(anchorExists, privacy: .public))")
        return presentationAnchor ?? UIWindow()
    }
}

extension AuthViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        let t0 = Date()
        log.info("Apple: didCompleteWithAuthorization")
        
        Task { @MainActor in
            defer { currentNonce = nil; appleController = nil }
            guard let apple = authorization.credential as? ASAuthorizationAppleIDCredential else {
                log.error("Apple: no credential in authorization")
                onAuthFailure?(AuthError.appleIdentityTokenMissing)
                return
            }
            
            let userId = apple.user
            let email = apple.email ?? "<nil>"
            log.debug("Apple: credential received (user=\(userId, privacy: .public), email=\(email, privacy: .public))")
            
            guard let tokenData = apple.identityToken,
                  let tokenString = String(data: tokenData, encoding: .utf8),
                  let nonce = currentNonce
            else {
                log.error("Apple: identityToken or nonce missing")
                onAuthFailure?(AuthError.appleIdentityTokenMissing)
                return
            }
            log.debug("Apple: identityToken present (len=\(tokenString.count, privacy: .public)); nonce len=\(nonce.count, privacy: .public)")
            
            do {
                // 1) Firebase Auth (Apple)
                let credential = OAuthProvider.credential(withProviderID: "apple.com", idToken: tokenString, rawNonce: nonce)
                let authResult = try await Auth.auth().signIn(with: credential)
                log.info("Firebase: Apple credential signIn OK, uid=\(authResult.user.uid, privacy: .public)")
                
                // 2) Firebase idToken
                let fbIdToken = try await authResult.user.getIDToken()
                log.debug("Firebase: got idToken=\(self.redact(fbIdToken), privacy: .public)")
                
                // 3) CourtAI
                let tApiStart = Date()
                log.info("CourtAI: login request start")
                let court = try await api.login(firebaseIdToken: fbIdToken)
                self.log.info("CourtAI: login OK in \(self.ms(from: tApiStart)) ms, user=\(court.me.name, privacy: .public) (id=\(court.me.id, privacy: .public))")
                self.log.debug("CourtAI: accessToken=\(self.redact(court.accessToken), privacy: .public)")
                
                // 4) save
                try tokenStore.save(court.accessToken)
                log.info("Keychain: accessToken saved")
                
                // 5) callback
                let session = BackendSession(accessToken: court.accessToken, userId: court.me.id, userName: court.me.name)
                onBackendLoginSuccess?(session)
                
                log.info("Apple flow finished in \(self.ms(from: t0)) ms")
            } catch {
                self.logError(error, prefix: "Apple flow failed")
                onAuthFailure?(error)
            }
        }
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        currentNonce = nil
        appleController = nil
        
        let ns = error as NSError
        log.error("Apple: didCompleteWithError domain=\(ns.domain, privacy: .public) code=\(ns.code, privacy: .public) desc=\(ns.localizedDescription, privacy: .public)")
        onAuthFailure?(error)
    }
}

enum AuthError: Error {
    case cancelled
    case noPresentingVC
    case googleSDK(String)
    case appleIdentityTokenMissing
}
