//
//  NativeAppleSignInViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import Auth0
import AuthenticationServices
import UIKit

@MainActor
class NativeAppleSignInViewModel: NSObject, ObservableObject {
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var isAuthenticated = false
    @Published var userEmail: String?

    private let authService: AuthService
    private var credentialsManager: CredentialsManager

    init(authService: AuthService) {
        self.authService = authService
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())
        super.init()
    }

    func signIn() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self
        controller.performRequests()
    }

    private func fetchUserProfile(accessToken: String) {
        Auth0
            .authentication()
            .userInfo(withAccessToken: accessToken)
            .start { [weak self] result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let profile):
                        self?.userEmail = profile.email
                        self?.authService.userProfile = profile
                        print("User profile: \(profile)")

                    case .failure(let error):
                        print("Failed to fetch user profile: \(error)")
                    }
                }
            }
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension NativeAppleSignInViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        guard let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid credential type"
            }
            return
        }

        guard let authorizationCode = appleIDCredential.authorizationCode,
              let authCodeString = String(data: authorizationCode, encoding: .utf8) else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Failed to get Apple credentials"
            }
            return
        }

        // Exchange Apple credentials for Auth0 tokens using native iOS integration
        Auth0
            .authentication()
            .login(
                appleAuthorizationCode: authCodeString,
                fullName: appleIDCredential.fullName,
                scope: "openid profile email offline_access"
            )
            .start { [weak self] (result: Result<Credentials, AuthenticationError>) in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    switch result {
                    case .success(let credentials):
                        self?.isAuthenticated = true
                        self?.successMessage = "Sign in with Apple successful!"

                        // Store credentials in AuthService and CredentialsManager
                        self?.authService.isAuthenticated = true
                        self?.authService.idToken = credentials.idToken
                        self?.authService.accessToken = credentials.accessToken
                        self?.authService.refreshToken = credentials.refreshToken
                        _ = self?.credentialsManager.store(credentials: credentials)

                        // Store email if available
                        if let email = appleIDCredential.email {
                            self?.userEmail = email
                        }

                        // Fetch user profile for additional details
                        self?.fetchUserProfile(accessToken: credentials.accessToken)

                    case .failure(let error):
                        self?.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                        print("Apple Sign In error: \(error)")
                    }
                }
            }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false

            guard let authError = error as? ASAuthorizationError else {
                self.errorMessage = error.localizedDescription
                return
            }

            switch authError.code {
            case .canceled:
                self.errorMessage = "Sign in canceled"
            case .failed:
                self.errorMessage = "Sign in failed"
            case .invalidResponse:
                self.errorMessage = "Invalid response from Apple"
            case .notHandled:
                self.errorMessage = "Sign in not handled"
            case .unknown:
                self.errorMessage = "Unknown error occurred"
            case .notInteractive:
                self.errorMessage = "Sign in not available in non-interactive mode"
            @unknown default:
                self.errorMessage = "Unexpected error"
            }

            print("Apple Sign In failed: \(self.errorMessage ?? "Unknown error")")
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension NativeAppleSignInViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
