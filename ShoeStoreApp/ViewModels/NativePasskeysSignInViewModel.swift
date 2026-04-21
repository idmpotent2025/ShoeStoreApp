//
//  NativePasskeysSignInViewModel.swift
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
class NativePasskeysSignInViewModel: NSObject, ObservableObject {
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

        // Create a native passkey authentication request
        let publicKeyCredentialProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: "digitalkiosk.cic-demo-platform.auth0app.com")

        // Create a challenge (for demo purposes, using a mock challenge)
        let challenge = Data("demo-challenge-\(UUID().uuidString)".utf8)

        let assertionRequest = publicKeyCredentialProvider.createCredentialAssertionRequest(challenge: challenge)

        // Create the authorization controller
        let authController = ASAuthorizationController(authorizationRequests: [assertionRequest])
        authController.delegate = self
        authController.presentationContextProvider = self

        // Perform the request - this will show the native Face ID/Touch ID prompt
        authController.performRequests()
    }

    func clearMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension NativePasskeysSignInViewModel: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {

        guard let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion else {
            DispatchQueue.main.async {
                self.isLoading = false
                self.errorMessage = "Invalid credential type"
            }
            return
        }

        // For demo purposes: simulate successful authentication
        // In production, you would send credential.rawAuthenticatorData, credential.signature, etc. to Auth0
        DispatchQueue.main.async {
            self.isLoading = false
            self.isAuthenticated = true
            self.successMessage = "Passkey authentication successful!"
            self.userEmail = "demo.user@example.com"

            // Store mock authentication state
            self.authService.isAuthenticated = true
            self.authService.idToken = "mock-id-token-\(UUID().uuidString)"
            self.authService.accessToken = "mock-access-token-\(UUID().uuidString)"

            print("✅ Native passkey authentication completed")
            print("Credential ID: \(credential.credentialID.base64EncodedString())")
            print("User ID: \(credential.userID.base64EncodedString())")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        DispatchQueue.main.async {
            self.isLoading = false

            guard let authError = error as? ASAuthorizationError else {
                self.errorMessage = "Passkey authentication failed: \(error.localizedDescription)"
                return
            }

            switch authError.code {
            case .canceled:
                self.errorMessage = "Passkey authentication canceled"
            case .failed:
                self.errorMessage = "Passkey authentication failed"
            case .invalidResponse:
                self.errorMessage = "Invalid response from passkey"
            case .notHandled:
                self.errorMessage = "Passkey authentication not handled"
            case .unknown:
                self.errorMessage = "Unknown passkey error occurred"
            case .notInteractive:
                self.errorMessage = "Passkey not available in non-interactive mode"
            @unknown default:
                self.errorMessage = "Unexpected passkey error"
            }

            print("❌ Passkey authentication failed: \(self.errorMessage ?? "Unknown error")")
        }
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension NativePasskeysSignInViewModel: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
