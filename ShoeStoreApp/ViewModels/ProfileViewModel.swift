//
//  ProfileViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication
import Auth0

class ProfileViewModel: ObservableObject {
    // Lock state
    @Published var isLocked: Bool = true

    // Token state
    @Published var idToken: String?
    @Published var accessToken: String?
    @Published var refreshToken: String?

    // User profile
    @Published var userProfile: [String: Any] = [:]

    // Settings - delegated to PreferencesManager
    @Published var useFaceIDLock: Bool
    @Published var selectedCategory: ProductCategory
    @Published var backgroundColor: Color
    @Published var brandLabel: String
    @Published var brandFontStyle: BrandFontStyle

    // UI state
    @Published var copiedMessage: String?
    @Published var isRefreshing = false
    @Published var refreshError: String?
    @Published var biometricError: String?

    private let authService: AuthService
    private let preferencesManager = PreferencesManager.shared
    private let themeManager = ThemeManager.shared
    private var credentialsManager: CredentialsManager
    private var cancellables = Set<AnyCancellable>()

    init(authService: AuthService) {
        self.authService = authService
        self.credentialsManager = CredentialsManager(authentication: Auth0.authentication())

        // Initialize settings from PreferencesManager
        self.useFaceIDLock = preferencesManager.useFaceIDLock
        self.selectedCategory = preferencesManager.selectedCategory
        self.backgroundColor = preferencesManager.backgroundColorValue
        self.brandLabel = preferencesManager.brandLabel
        self.brandFontStyle = preferencesManager.brandFontStyle

        // Set initial lock state based on FaceID preference
        self.isLocked = preferencesManager.useFaceIDLock

        // Observe tokens from auth service
        authService.$idToken
            .assign(to: &$idToken)

        authService.$accessToken
            .assign(to: &$accessToken)

        authService.$refreshToken
            .assign(to: &$refreshToken)

        // Observe settings from PreferencesManager
        preferencesManager.$useFaceIDLock
            .sink { [weak self] useLock in
                self?.useFaceIDLock = useLock
                // If FaceID lock is turned off, unlock immediately
                if !useLock {
                    self?.isLocked = false
                }
            }
            .store(in: &cancellables)

        preferencesManager.$selectedCategory
            .sink { [weak self] category in
                self?.selectedCategory = category
            }
            .store(in: &cancellables)

        preferencesManager.$brandLabel
            .sink { [weak self] label in
                self?.brandLabel = label
            }
            .store(in: &cancellables)

        themeManager.$backgroundColor
            .sink { [weak self] color in
                self?.backgroundColor = color
            }
            .store(in: &cancellables)

        preferencesManager.$brandFontStyle
            .sink { [weak self] fontStyle in
                self?.brandFontStyle = fontStyle
            }
            .store(in: &cancellables)

        // Extract user profile data from ID token
        authService.$userProfile
            .sink { [weak self] profile in
                self?.extractProfileData(from: profile)
            }
            .store(in: &cancellables)
    }

    // MARK: - User Profile

    var hasProfile: Bool {
        return authService.isAuthenticated && !userProfile.isEmpty
    }

    var userName: String {
        return (userProfile["name"] as? String) ?? "Unknown User"
    }

    var userEmail: String {
        return (userProfile["email"] as? String) ?? "No email"
    }

    var userPicture: String? {
        return userProfile["picture"] as? String
    }

    private func extractProfileData(from profile: UserInfo?) {
        guard let profile = profile else {
            userProfile = [:]
            return
        }

        var profileData: [String: Any] = [:]
        profileData["name"] = profile.name
        profileData["email"] = profile.email
        profileData["picture"] = profile.picture?.absoluteString
        profileData["sub"] = profile.sub

        // Add custom claims if available
        if let customClaims = profile.customClaims {
            for (key, value) in customClaims {
                profileData[key] = value
            }
        }

        self.userProfile = profileData
    }

    // MARK: - Token Management

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

    func refreshTokens() {
        isRefreshing = true
        refreshError = nil

        guard let refreshToken = authService.refreshToken else {
            DispatchQueue.main.async {
                self.isRefreshing = false
                self.refreshError = "No refresh token available"
            }
            return
        }

        Auth0
            .authentication()
            .renew(withRefreshToken: refreshToken, scope: "openid profile email offline_access")
            .start { [weak self] result in
                DispatchQueue.main.async {
                    self?.isRefreshing = false

                    switch result {
                    case .success(let credentials):
                        self?.authService.idToken = credentials.idToken
                        self?.authService.accessToken = credentials.accessToken

                        if let newRefreshToken = credentials.refreshToken {
                            self?.authService.refreshToken = newRefreshToken
                        }

                        _ = self?.credentialsManager.store(credentials: credentials)

                        self?.copiedMessage = "Tokens refreshed successfully!"

                        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                            self?.copiedMessage = nil
                        }

                    case .failure(let error):
                        self?.refreshError = "Failed to refresh tokens: \(error.localizedDescription)"
                    }
                }
            }
    }

    // MARK: - FaceID Lock

    func unlockWithBiometrics() {
        let context = LAContext()
        var error: NSError?

        biometricError = nil

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async {
                self.biometricError = "Biometric authentication not available"
            }
            return
        }

        let biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to view your profile"
        ) { [weak self] success, authError in
            DispatchQueue.main.async {
                if success {
                    self?.isLocked = false
                    self?.biometricError = nil
                } else {
                    self?.biometricError = "\(biometricType) authentication failed"
                }
            }
        }
    }

    func lock() {
        if useFaceIDLock {
            isLocked = true
        }
    }

    // MARK: - Settings Management

    func updateFaceIDLock(_ enabled: Bool) {
        preferencesManager.useFaceIDLock = enabled
        if enabled {
            isLocked = true
        } else {
            isLocked = false
        }
    }

    func updateCategory(_ category: ProductCategory) {
        preferencesManager.selectedCategory = category
    }

    func updateBackgroundColor(_ colorHex: String) {
        preferencesManager.backgroundColor = colorHex
    }

    func updateBrandLabel(_ label: String) {
        preferencesManager.brandLabel = label
    }

    func updateBrandFontStyle(_ fontStyle: BrandFontStyle) {
        preferencesManager.brandFontStyle = fontStyle
    }
}
