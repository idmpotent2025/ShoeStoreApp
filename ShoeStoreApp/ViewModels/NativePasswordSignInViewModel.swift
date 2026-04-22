//
//  NativePasswordSignInViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import Auth0

class NativePasswordSignInViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var userEmail: String?
    @Published var errorMessage: String?
    @Published var successMessage: String?
    @Published var showPasswordInput = false
    @Published var usernameOrEmail = ""
    @Published var password = ""

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

    func startPasswordFlow() {
        usernameOrEmail = ""
        password = ""
        errorMessage = nil
        successMessage = nil
        showPasswordInput = true
    }

    func signIn() {
        guard !usernameOrEmail.isEmpty else {
            errorMessage = "Please enter your email or username"
            return
        }

        guard !password.isEmpty else {
            errorMessage = "Please enter your password"
            return
        }

        isLoading = true
        errorMessage = nil

        Auth0
            .authentication()
            .login(
                usernameOrEmail: usernameOrEmail,
                password: password,
                realmOrConnection: "auth0LocalDB",
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
                        self?.userEmail = self?.usernameOrEmail
                        self?.showPasswordInput = false
                        self?.successMessage = "Password authentication successful!"

                        // Fetch user profile
                        self?.fetchUserProfile(accessToken: credentials.accessToken)

                    case .failure(let error):
                        self?.errorMessage = "Login failed: \(error.localizedDescription)"
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
                    if let email = profile.email {
                        self.userEmail = email
                    }
                case .failure(let error):
                    print("Failed to fetch user profile: \(error)")
                }
            }
    }

    func reset() {
        showPasswordInput = false
        usernameOrEmail = ""
        password = ""
        errorMessage = nil
        successMessage = nil
    }
}
