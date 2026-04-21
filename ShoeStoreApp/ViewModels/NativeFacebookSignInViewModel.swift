//
//  NativeFacebookSignInViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import Auth0

@MainActor
class NativeFacebookSignInViewModel: ObservableObject {
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
    }

    func signIn() {
        isLoading = true
        errorMessage = nil
        successMessage = nil

        Auth0
            .webAuth()
            .connection("facebook")
            .scope("openid profile email offline_access")
            .start { [weak self] result in
                DispatchQueue.main.async {
                    self?.isLoading = false

                    switch result {
                    case .success(let credentials):
                        self?.isAuthenticated = true
                        self?.successMessage = "Facebook login successful!"

                        // Store credentials in AuthService and CredentialsManager
                        self?.authService.isAuthenticated = true
                        self?.authService.idToken = credentials.idToken
                        self?.authService.accessToken = credentials.accessToken
                        self?.authService.refreshToken = credentials.refreshToken
                        _ = self?.credentialsManager.store(credentials: credentials)

                        // Optionally fetch user profile
                        self?.fetchUserProfile(accessToken: credentials.accessToken)

                    case .failure(let error):
                        self?.errorMessage = "Facebook login failed: \(error.localizedDescription)"
                        print("Facebook error: \(error)")
                    }
                }
            }
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
