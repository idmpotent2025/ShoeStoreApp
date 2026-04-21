//
//  PasskeyService.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import AuthenticationServices
import UIKit

@MainActor
class PasskeyService: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var username: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private let relyingPartyIdentifier = "demo.identityarchitect.app"

    func signInWithPasskey() {
        isLoading = true
        errorMessage = nil

        let challenge = Data(UUID().uuidString.utf8)
        let userID = Data(UUID().uuidString.utf8)

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)

        let assertionRequest = platformProvider.createCredentialAssertionRequest(challenge: challenge)

        let controller = ASAuthorizationController(authorizationRequests: [assertionRequest])
        controller.delegate = self
        controller.presentationContextProvider = self

        controller.performRequests()
    }

    func registerPasskey(username: String) {
        isLoading = true
        errorMessage = nil
        self.username = username

        let challenge = Data(UUID().uuidString.utf8)
        let userID = Data(username.utf8)

        let platformProvider = ASAuthorizationPlatformPublicKeyCredentialProvider(relyingPartyIdentifier: relyingPartyIdentifier)

        let registrationRequest = platformProvider.createCredentialRegistrationRequest(
            challenge: challenge,
            name: username,
            userID: userID
        )

        let controller = ASAuthorizationController(authorizationRequests: [registrationRequest])
        controller.delegate = self
        controller.presentationContextProvider = self

        controller.performRequests()
    }

    func signOut() {
        isAuthenticated = false
        username = nil
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension PasskeyService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isLoading = false

        if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialAssertion {
            // Passkey assertion successful
            username = String(decoding: credential.userID, as: UTF8.self)
            isAuthenticated = true
            print("Passkey authentication successful for user: \(username ?? "unknown")")
        } else if let credential = authorization.credential as? ASAuthorizationPlatformPublicKeyCredentialRegistration {
            // Passkey registration successful
            isAuthenticated = true
            print("Passkey registration successful")
        }
    }

    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        isLoading = false

        guard let authError = error as? ASAuthorizationError else {
            errorMessage = error.localizedDescription
            return
        }

        switch authError.code {
        case .canceled:
            errorMessage = "Passkey operation canceled"
        case .failed:
            errorMessage = "Passkey operation failed"
        case .invalidResponse:
            errorMessage = "Invalid response"
        case .notHandled:
            errorMessage = "Passkey not handled"
        case .unknown:
            errorMessage = "Unknown error occurred"
        @unknown default:
            errorMessage = "Unexpected error"
        }

        print("Passkey operation failed: \(errorMessage ?? "Unknown error")")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension PasskeyService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
