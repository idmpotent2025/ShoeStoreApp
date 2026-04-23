//
//  AppLockManager.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine
import LocalAuthentication

class AppLockManager: ObservableObject {
    static let shared = AppLockManager()

    @Published var isLocked: Bool = false
    @Published var authenticationError: String?

    private let preferencesManager = PreferencesManager.shared
    private var cancellables = Set<AnyCancellable>()
    private var wasInBackground = false
    private var isAuthenticating = false
    private var backgroundTimestamp: Date?
    private let lockThreshold: TimeInterval = 3.0 // Only lock if app was in background for more than 3 seconds

    private init() {
        // Observe FaceID lock preference changes
        preferencesManager.$useFaceIDLock
            .sink { [weak self] useLock in
                if useLock {
                    // If FaceID is enabled, lock the app
                    self?.lockApp()
                } else {
                    // If FaceID is disabled, unlock the app
                    self?.isLocked = false
                }
            }
            .store(in: &cancellables)

        // Set initial lock state
        if preferencesManager.useFaceIDLock {
            isLocked = true
        }
    }

    func lockApp() {
        if preferencesManager.useFaceIDLock {
            isLocked = true
            authenticationError = nil
        }
    }

    func unlockApp() {
        let context = LAContext()
        var error: NSError?

        authenticationError = nil
        isAuthenticating = true

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            DispatchQueue.main.async {
                self.authenticationError = "Biometric authentication not available"
                self.isAuthenticating = false
            }
            return
        }

        let biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to unlock the app"
        ) { [weak self] success, authError in
            DispatchQueue.main.async {
                self?.isAuthenticating = false
                if success {
                    self?.isLocked = false
                    self?.authenticationError = nil
                    self?.wasInBackground = false
                } else {
                    self?.authenticationError = "\(biometricType) authentication failed"
                }
            }
        }
    }

    func handleAppBecameActive() {
        // Only lock if we were actually in background and not currently authenticating
        // AND if enough time has passed (to avoid locking during auth flows)
        if preferencesManager.useFaceIDLock && wasInBackground && !isAuthenticating {
            if let timestamp = backgroundTimestamp {
                let timeInBackground = Date().timeIntervalSince(timestamp)
                // Only lock if app was in background for more than the threshold
                // This prevents locking during quick system transitions (like auth redirects)
                if timeInBackground > lockThreshold {
                    lockApp()
                }
            }
        }
        // Reset the flags after handling
        if !isAuthenticating {
            wasInBackground = false
            backgroundTimestamp = nil
        }
    }

    func handleAppWentToBackground() {
        // Mark that app went to background and record the timestamp
        if preferencesManager.useFaceIDLock {
            wasInBackground = true
            backgroundTimestamp = Date()
        }
    }
}
