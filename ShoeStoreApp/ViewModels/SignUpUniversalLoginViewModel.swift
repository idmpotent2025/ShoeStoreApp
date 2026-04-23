//
//  SignUpUniversalLoginViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import Auth0

class SignUpUniversalLoginViewModel: ObservableObject {
    @Published var isLoading = false
    @Published var isAuthenticated = false
    @Published var errorMessage: String?
    @Published var successMessage: String?

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

    func startSignUp() {
        isLoading = true
        errorMessage = nil

        Auth0
            .webAuth()
            .scope("openid profile email offline_access")
            .audience("https://\(Auth0Plist.config?.domain ?? "")/userinfo")
            .parameters(["screen_hint": "signup"])
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
                        self?.successMessage = "Account created successfully!"

                        // Fetch user profile
                        self?.fetchUserProfile(accessToken: credentials.accessToken)

                    case .failure(let error):
                        self?.errorMessage = "Sign up failed: \(error.localizedDescription)"
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
}
