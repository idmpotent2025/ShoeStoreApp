//
//  AuthService.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import Auth0

class AuthService: ObservableObject {
    @Published var isAuthenticated = false
    @Published var userProfile: UserInfo?
    @Published var idToken: String?
    @Published var accessToken: String?
    @Published var refreshToken: String?

    private var credentialsManager: CredentialsManager

    init() {
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())

        // Clear any stored credentials on init to ensure fresh start
        _ = self.credentialsManager.clear()
        self.isAuthenticated = false
    }

    func login(completion: @escaping (Result<Void, Error>) -> Void) {
        Auth0
            .webAuth()
            .scope("openid profile email offline_access")
            .audience("https://\(Auth0Plist.config?.domain ?? "")/userinfo")
            .start { result in
                switch result {
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.idToken = credentials.idToken
                    self.accessToken = credentials.accessToken
                    self.refreshToken = credentials.refreshToken

                    // Store credentials
                    _ = self.credentialsManager.store(credentials: credentials)

                    // Fetch user profile
                    self.fetchUserProfile(accessToken: credentials.accessToken)

                    completion(.success(()))

                case .failure(let error):
                    print("Failed to login: \(error)")
                    completion(.failure(error))
                }
            }
    }

    func socialLogin(completion: @escaping (Result<Void, Error>) -> Void) {
        Auth0
            .webAuth()
            .scope("openid profile email offline_access")
            .connection("google-oauth2")
            .audience("https://\(Auth0Plist.config?.domain ?? "")/userinfo")
            .start { result in
                switch result {
                case .success(let credentials):
                    self.isAuthenticated = true
                    self.idToken = credentials.idToken
                    self.accessToken = credentials.accessToken
                    self.refreshToken = credentials.refreshToken

                    // Store credentials
                    _ = self.credentialsManager.store(credentials: credentials)

                    // Fetch user profile
                    self.fetchUserProfile(accessToken: credentials.accessToken)

                    completion(.success(()))

                case .failure(let error):
                    print("Failed to login: \(error)")
                    completion(.failure(error))
                }
            }
    }
    
    
    
    func logout() {
        Auth0
            .webAuth()
            .clearSession { result in
                switch result {
                case .success:
                    self.isAuthenticated = false
                    self.userProfile = nil
                    self.idToken = nil
                    self.accessToken = nil
                    self.refreshToken = nil

                    // Clear stored credentials
                    _ = self.credentialsManager.clear()

                    print("Logged out successfully")

                case .failure(let error):
                    print("Failed to logout: \(error)")
                }
            }
    }

    private func checkStoredCredentials() {
        credentialsManager.credentials { result in
            switch result {
            case .success(let credentials):
                self.isAuthenticated = true
                self.idToken = credentials.idToken
                self.accessToken = credentials.accessToken
                self.refreshToken = credentials.refreshToken
                self.fetchUserProfile(accessToken: credentials.accessToken)

            case .failure:
                self.isAuthenticated = false
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
                    self.userProfile = profile

                case .failure(let error):
                    print("Failed to fetch user profile: \(error)")
                }
            }
    }
}

// Helper to read Auth0.plist
struct Auth0Plist {
    static var config: (clientId: String, domain: String)? {
        guard let path = Bundle.main.path(forResource: "Auth0", ofType: "plist"),
              let values = NSDictionary(contentsOfFile: path) as? [String: String],
              let clientId = values["ClientId"],
              let domain = values["Domain"] else {
            return nil
        }
        return (clientId, domain)
    }
}
