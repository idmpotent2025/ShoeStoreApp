//
//  NativeEmailOTPSignInViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import Auth0

class NativeEmailOTPSignInViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showEmailInput = false
    @Published var showOTPInput = false
    @Published var email = ""
    @Published var otpCode = ""

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

    func startEmailOTPFlow() {
        email = ""
        otpCode = ""
        errorMessage = nil
        successMessage = nil
        showEmailInput = true
    }

    func sendOTP() {
        guard !email.isEmpty else {
            errorMessage = "Please enter an email address"
            return
        }

        // Basic email validation
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        guard emailPredicate.evaluate(with: email) else {
            errorMessage = "Please enter a valid email address"
            return
        }

        isLoading = true
        errorMessage = nil

        Auth0
            .authentication()
            //.startPasswordless(email: email, type: .code) wont work as
            //defaults to database and fails as database email is only for UL
            .startPasswordless(email: email, type: .code, connection: "email")
            .start { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    switch result {
                    case .success:
                        self?.showEmailInput = false
                        self?.showOTPInput = true
                        self?.successMessage = "OTP sent to \(self?.email ?? "")"
                    case .failure(let error):
                        self?.errorMessage = "Failed to send OTP: \(error.localizedDescription)"
                    }
                }
            }
    }

    func verifyOTP() {
        guard !otpCode.isEmpty else {
            errorMessage = "Please enter the OTP code"
            return
        }

        isLoading = true
        errorMessage = nil

        Auth0
            .authentication()
            .login(
                   email: email,
                   code: otpCode,
                   scope: "openid profile email offline_access")
            
            .start { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    switch result {
                    case .success(let credentials):
                        self?.authService.isAuthenticated = true
                        self?.authService.idToken = credentials.idToken
                        self?.authService.accessToken = credentials.accessToken
                        self?.authService.refreshToken = credentials.refreshToken

                        self?.isAuthenticated = true
                        self?.userEmail = self?.email
                        self?.showOTPInput = false
                        self?.successMessage = "Email OTP authentication successful!"

                        // Fetch user profile
                        self?.fetchUserProfile(accessToken: credentials.accessToken)

                    case .failure(let error):
                        self?.errorMessage = "Invalid OTP code: \(error.localizedDescription)"
                    }
                }
            }
    }

    private func fetchUserProfile(accessToken: String) {
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { result in
                switch result {
                case .success(let profile):
                    self.authService.userProfile = profile
                case .failure(let error):
                    print("Failed to fetch user profile: \(error)")
                }
            }
    }

    func reset() {
        showEmailInput = false
        showOTPInput = false
        email = ""
        otpCode = ""
        errorMessage = nil
        successMessage = nil
    }
}
