//
//  FirebaseLoginRequest.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//


import Foundation
import os

struct FirebaseLoginRequest: Encodable {
    let jsonrpc = "2.0"
    let method = "auth.firebaseLogin"
    let params: Params
    let id = 1
    
    struct Params: Encodable {
        let fbIdToken: String
    }
}

struct FirebaseLoginResponse: Decodable {
    struct Result: Decodable {
        let accessToken: String
        let me: Me
        struct Me: Decodable {
            let id: Int
            let name: String
        }
    }
    struct RPCError: Decodable, Error {
        let code: Int
        let message: String
        let data: RPCErrorData?
        struct RPCErrorData: Decodable {
            let reason: String?
            let details: String?
        }
    }
    let jsonrpc: String
    let result: Result?
    let error: RPCError?
    let id: Int
}

enum CourtAIError: LocalizedError {
    case badStatus(Int, String)
    case decodeFailed(String)
    case rpcError(FirebaseLoginResponse.RPCError)
    case noResult
    
    var errorDescription: String? {
        switch self {
        case .badStatus(let code, let body):
            return "HTTP \(code). Body: \(body.prefix(500))"
        case .decodeFailed(let body):
            return "Decode failed. Body: \(body.prefix(500))"
        case .rpcError(let e):
            var s = "RPC error \(e.code): \(e.message)"
            if let r = e.data?.reason { s += " | reason: \(r)" }
            if let d = e.data?.details { s += " | details: \(d)" }
            return s
        case .noResult:
            return "No result in JSON-RPC response"
        }
    }
}

final class CourtAIAPI {
    private let baseURL = URL(string: "https://api.court360.ai/rpc/client")!
    private let log = Logger(subsystem: Bundle.main.bundleIdentifier ?? "DNATest",
                             category: "CourtAIAPI")
    
    // настраиваем свою сессию (таймауты, waitsForConnectivity)
    private lazy var session: URLSession = {
        let cfg = URLSessionConfiguration.default
        cfg.waitsForConnectivity = true
        cfg.timeoutIntervalForRequest = 30
        cfg.timeoutIntervalForResource = 60
        return URLSession(configuration: cfg)
    }()
    
    func login(firebaseIdToken: String) async throws -> FirebaseLoginResponse.Result {
        var request = URLRequest(url: baseURL)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let body = FirebaseLoginRequest(params: .init(fbIdToken: firebaseIdToken))
        let encoder = JSONEncoder()
        encoder.outputFormatting = .withoutEscapingSlashes
        request.httpBody = try encoder.encode(body)
        
        let t0 = Date()
        log.info("POST /rpc/client — auth.firebaseLogin (body ~\(request.httpBody?.count ?? 0) bytes)")
        
        let (data, response) = try await session.data(for: request)
        let dt = Int(Date().timeIntervalSince(t0) * 1000)
        
        guard let http = response as? HTTPURLResponse else {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            log.error("No HTTPURLResponse. Body: \(raw, privacy: .public)")
            throw CourtAIError.decodeFailed(raw)
        }
        
        if !(200..<300).contains(http.statusCode) {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            log.error("HTTP \(http.statusCode) in \(dt) ms. Body: \(raw, privacy: .public)")
            throw CourtAIError.badStatus(http.statusCode, raw)
        }
        
        do {
            let decoded = try JSONDecoder().decode(FirebaseLoginResponse.self, from: data)
            
            if let err = decoded.error {
                log.error("RPC error \(err.code): \(err.message, privacy: .public)")
                if let reason = err.data?.reason {
                    log.error("RPC error reason: \(reason, privacy: .public)")
                }
                if let details = err.data?.details {
                    log.error("RPC error details: \(details, privacy: .public)")
                }
                throw CourtAIError.rpcError(err)
            }
            
            if let result = decoded.result {
                log.info("RPC success in \(dt) ms. user=\(result.me.name, privacy: .public) id=\(result.me.id, privacy: .public)")
                return result
            }
            
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            log.error("No result in response. Raw: \(raw, privacy: .public)")
            throw CourtAIError.noResult
        } catch let decodeErr {
            let raw = String(data: data, encoding: .utf8) ?? "<non-utf8>"
            log.error("Decode failed in \(dt) ms. Err=\(decodeErr.localizedDescription, privacy: .public) Raw: \(raw, privacy: .public)")
            throw CourtAIError.decodeFailed(raw)
        }
    }
}
