//
//  TokensViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import UIKit
import LocalAuthentication
import Auth0

class TokensViewModel: ObservableObject {
    @Published var idToken: String?
    @Published var accessToken: String?
    @Published var refreshToken: String?
    @Published var copiedMessage: String?
    @Published var isRefreshing = false
    @Published var refreshError: String?

    private let authService: AuthService
    private var credentialsManager: CredentialsManager
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService) {
        self.authService = authService
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())

        // Observe tokens from auth service
        authService.$idToken
            .assign(to: &$idToken)

        authService.$accessToken
            .assign(to: &$accessToken)

        authService.$refreshToken
            .assign(to: &$refreshToken)
    }

    var hasTokens: Bool {
        return idToken != nil || accessToken != nil || refreshToken != nil
    }

    func copyToClipboard(_ text: String, tokenType: String) {
        #if os(iOS)
        UIPasteboard.general.string = text
        #else
        NSPasteboard.general.clearContents()
        NSPasteboard.general.setString(text, forType: .string)
        #endif

        copiedMessage = "\(tokenType) copied to clipboard"

        // Clear message after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.copiedMessage = nil
        }
    }

    func decodeToken(_ token: String) -> [String: Any]? {
        return JWTDecoder.decode(token)
    }

    func getTokenClaims(_ token: String) -> TokenClaims? {
        return JWTDecoder.extractClaims(from: token)
    }

    func isTokenExpired(_ token: String) -> Bool {
        return JWTDecoder.isTokenExpired(token)
    }

    func tokenExpirationDate(_ token: String) -> Date? {
        return JWTDecoder.tokenExpirationDate(from: token)
    }

    func unlockWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        // Check if biometric authentication is available
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async {
                self.refreshError = "Biometric authentication not available: \(error?.localizedDescription ?? "Unknown error")"
            }
            return
        }

        // Determine biometric type
        let biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"

        // Request biometric authentication
        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to refresh your tokens"
        ) { [weak self] success, authError in
            DispatchQueue.main.async {
                if success {
                    self?.refreshTokens()
                } else {
                    self?.refreshError = "\(biometricType) authentication failed: \(authError?.localizedDescription ?? "Unknown error")"
                }
            }
        }
    }

    private func refreshTokens() {
        isRefreshing = true
        refreshError = nil

        // First, get the current refresh token
        guard let refreshToken = authService.refreshToken else {
            DispatchQueue.main.async {
                self.isRefreshing = false
                self.refreshError = "No refresh token available"
            }
            return
        }

        // Use Auth0 Authentication API to refresh tokens
        Auth0
            .authentication()
            .renew(withRefreshToken: refreshToken, scope: "openid profile email offline_access")
            .start { [weak self] result in
                DispatchQueue.main.async {
                    self?.isRefreshing = false

                    switch result {
                    case .success(let credentials):
                        // Update tokens in AuthService
                        self?.authService.idToken = credentials.idToken
                        self?.authService.accessToken = credentials.accessToken

                        // Refresh token might be rotated (new one returned) or stay the same
                        if let newRefreshToken = credentials.refreshToken {
                            self?.authService.refreshToken = newRefreshToken
                        }

                        // Store new credentials in keychain
                        _ = self?.credentialsManager.store(credentials: credentials)

                        self?.copiedMessage = "Tokens refreshed successfully!"

                        // Clear message after 2 seconds
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self?.copiedMessage = nil
                        }

                    case .failure(let error):
                        self?.refreshError = "Failed to refresh tokens: \(error.localizedDescription)"
                        print("Token refresh error: \(error)")
                    }
                }
            }
    }
}
