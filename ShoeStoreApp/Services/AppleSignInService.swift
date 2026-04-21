//
//  AppleSignInService.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import AuthenticationServices
import UIKit

@MainActor
class AppleSignInService: NSObject, ObservableObject {
    @Published var isAuthenticated = false
    @Published var userIdentifier: String?
    @Published var fullName: String?
    @Published var email: String?
    @Published var errorMessage: String?
    @Published var isLoading = false

    private var currentNonce: String?

    func signIn() {
        isLoading = true
        errorMessage = nil

        let provider = ASAuthorizationAppleIDProvider()
        let request = provider.createRequest()
        request.requestedScopes = [.fullName, .email]

        let controller = ASAuthorizationController(authorizationRequests: [request])
        controller.delegate = self
        controller.presentationContextProvider = self

        controller.performRequests()
    }

    func signOut() {
        isAuthenticated = false
        userIdentifier = nil
        fullName = nil
        email = nil
    }
}

// MARK: - ASAuthorizationControllerDelegate

extension AppleSignInService: ASAuthorizationControllerDelegate {
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        isLoading = false

        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            userIdentifier = appleIDCredential.user

            if let givenName = appleIDCredential.fullName?.givenName,
               let familyName = appleIDCredential.fullName?.familyName {
                fullName = "\(givenName) \(familyName)"
            }

            email = appleIDCredential.email

            isAuthenticated = true

            print("Sign in with Apple successful")
            print("User ID: \(appleIDCredential.user)")
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
            errorMessage = "Sign in canceled"
        case .failed:
            errorMessage = "Sign in failed"
        case .invalidResponse:
            errorMessage = "Invalid response from Apple"
        case .notHandled:
            errorMessage = "Sign in not handled"
        case .unknown:
            errorMessage = "Unknown error occurred"
        case .notInteractive:
            errorMessage = "Sign in not available in non-interactive mode"
        @unknown default:
            errorMessage = "Unexpected error"
        }

        print("Sign in with Apple failed: \(errorMessage ?? "Unknown error")")
    }
}

// MARK: - ASAuthorizationControllerPresentationContextProviding

extension AppleSignInService: ASAuthorizationControllerPresentationContextProviding {
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first else {
            fatalError("No window found")
        }
        return window
    }
}
