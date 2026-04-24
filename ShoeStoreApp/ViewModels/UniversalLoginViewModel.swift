//
//  UniversalLoginViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine

class UniversalLoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var showSuccess = false

    private let authService: AuthService
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService) {
        self.authService = authService

        // Observe auth service state
        authService.$isAuthenticated
            .sink { [weak self] authenticated in
                self?.isAuthenticated = authenticated
            }
            .store(in: &cancellables)
    }

    func startUniversalLogin() {
        isLoading = true
        errorMessage = nil

        authService.login { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success:
                    self?.showSuccess = true
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    func startSocialULogin() {
        isLoading = true
        errorMessage = nil

        authService.socialLogin { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success:
                    self?.showSuccess = true
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func startMFALogin() {
        isLoading = true
        errorMessage = nil

        authService.mfaLogin { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success:
                    self?.showSuccess = true
                    self?.isAuthenticated = true
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    
    

    @Published var showForgotPasswordSheet = false
    @Published var successMessage: String?

    func startForgotPassword() {
        showForgotPasswordSheet = true
    }

    func sendPasswordResetEmail(email: String) {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        authService.forgotPassword(email: email) { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success:
                    self?.successMessage = "✉️ Email sent! Please check your inbox and click the link to reset your password."
                    self?.showForgotPasswordSheet = false
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func startResetPassword() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        authService.resetPassword { [weak self] result in
            DispatchQueue.main.async {
                self?.isLoading = false

                switch result {
                case .success:
                    self?.successMessage = "✉️ Password reset email sent! Check your inbox and click the link to change your password."
                case .failure(let error):
                    self?.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func logout() {
        authService.logout()
        isAuthenticated = false
        showSuccess = false
    }
}
