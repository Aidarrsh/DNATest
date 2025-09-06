//
//  LoginViewController.swift
//  DNATest
//
//  Created by Айдар Шарипов on 6/9/25.
//

import UIKit
import SnapKit
import AuthenticationServices
import GoogleSignIn

final class LoginViewController: UIViewController {
    private let contentView = LoginContentView()
    private let viewModel = AuthViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupView()
        bindViewModel()
        setupTargets()
    }
    
    private func setupView() {
        view.addSubview(contentView)
        contentView.snp.makeConstraints{ $0.edges.equalToSuperview() }
        view.backgroundColor = UIColor(hex: "#EFF3FF")
    }
    
    private func bindViewModel() {
        viewModel.onBackendLoginSuccess = { [weak self] session in
            guard let self else { return }
            print("CourtAI OK. token: \(session.accessToken.prefix(8))..., user: \(session.userName)")
            self.presentMain()
        }
        viewModel.onAuthFailure = { [weak self] error in
            self?.showAlert(title: "Login failed", message: "\(error)")
        }
    }
    
    private func setupTargets() {
        contentView.appleButton.addTarget(self, action: #selector(handleAppleTap), for: .touchUpInside)
        contentView.googleButton.addTarget(self, action: #selector(handleGoogleTap), for: .touchUpInside)
    }
    
    // MARK: - Actions
    
    @objc private func handleAppleTap() {
        if let window = view.window {
            viewModel.signInWithApple(presentationAnchor: window)
            return
        }
        if let scene = (UIApplication.shared.connectedScenes.first { $0.activationState == .foregroundActive }) as? UIWindowScene,
           let keyWindow = scene.windows.first(where: { $0.isKeyWindow }) {
            viewModel.signInWithApple(presentationAnchor: keyWindow)
        } else {
            viewModel.onAuthFailure?(AuthError.noPresentingVC)
        }
    }
    
    @objc private func handleGoogleTap() {
        viewModel.signInWithGoogle(from: self)
    }
    
    // MARK: - Navigation
    
    private func presentMain() {
        let tab = TabBarController()
        tab.modalPresentationStyle = .fullScreen
        present(tab, animated: true)
    }
    
    // MARK: - Helpers
    
    private func showAlert(title: String, message: String) {
        let ac = UIAlertController(title: title, message: message, preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
    }
}
