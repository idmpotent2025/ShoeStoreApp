//
//  CIBAApprovalView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI
import LocalAuthentication

struct CIBAApprovalView: View {
    @ObservedObject var pushService: PushNotificationService
    @Environment(\.dismiss) var dismiss
    @State private var isAuthenticating = false
    @State private var errorMessage: String?
    @State private var showSuccess = false

    var request: CIBAPushRequest? {
        pushService.currentCIBARequest
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                if let request = request {
                    ScrollView {
                        VStack(spacing: 24) {
                            // Icon
                            Image(systemName: "lock.shield.fill")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.theme.primary)
                                .padding(.top, 20)

                            // Title
                            Text("Authentication Request")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.text)

                            // Message
                            if let message = request.message {
                                Text(message)
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            } else {
                                Text("A login attempt is requesting your approval")
                                    .font(.body)
                                    .foregroundColor(.gray)
                                    .multilineTextAlignment(.center)
                                    .padding(.horizontal)
                            }

                            // Details Card
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Request Details")
                                    .font(.headline)
                                    .foregroundColor(.theme.text)

                                Divider()

                                if let location = request.location {
                                    DetailRow(icon: "location.fill", label: "Location", value: location)
                                }

                                if let deviceName = request.deviceName {
                                    DetailRow(icon: "desktopcomputer", label: "Device", value: deviceName)
                                }

                                if let ipAddress = request.ipAddress {
                                    DetailRow(icon: "network", label: "IP Address", value: ipAddress)
                                }

                                DetailRow(
                                    icon: "clock.fill",
                                    label: "Time",
                                    value: formatDate(request.timestamp)
                                )

                                if !request.isExpired {
                                    DetailRow(
                                        icon: "hourglass",
                                        label: "Expires In",
                                        value: formatTimeRemaining(request.timeRemaining)
                                    )
                                }
                            }
                            .padding()
                            .background(Color.white)
                            .cornerRadius(12)
                            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
                            .padding(.horizontal)

                            // Warning if expired
                            if request.isExpired {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
                                        .foregroundColor(.orange)
                                    Text("This request has expired")
                                        .font(.subheadline)
                                        .foregroundColor(.orange)
                                }
                                .padding()
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }

                            // Error Message
                            if let error = errorMessage {
                                HStack {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundColor(.red)
                                    Text(error)
                                        .font(.subheadline)
                                        .foregroundColor(.red)
                                }
                                .padding()
                                .background(Color.red.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }

                            // Success Message
                            if showSuccess {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Authentication approved successfully!")
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }

                            Spacer()

                            // Action Buttons
                            if !request.isExpired && !isAuthenticating && !showSuccess {
                                VStack(spacing: 12) {
                                    // Approve Button
                                    Button(action: {
                                        authenticateAndApprove()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "faceid")
                                                .font(.title3)
                                            Text("Approve with Face ID")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }

                                    // Deny Button
                                    Button(action: {
                                        denyRequest()
                                    }) {
                                        HStack(spacing: 12) {
                                            Image(systemName: "xmark.circle.fill")
                                            Text("Deny Request")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                                .padding(.horizontal)
                            }

                            if isAuthenticating {
                                HStack {
                                    ProgressView()
                                        .progressViewStyle(CircularProgressViewStyle(tint: .theme.accent))
                                    Text("Authenticating...")
                                        .foregroundColor(.theme.accent)
                                }
                                .padding()
                            }
                        }
                        .padding(.bottom, 32)
                    }
                } else {
                    Text("No authentication request")
                        .foregroundColor(.gray)
                }
            }
            .navigationTitle("Authentication")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        pushService.clearCurrentRequest()
                        dismiss()
                    }
                }
            }
        }
    }

    // MARK: - Actions

    private func authenticateAndApprove() {
        guard let request = request else { return }

        isAuthenticating = true
        errorMessage = nil

        let context = LAContext()
        var error: NSError?

        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            self.errorMessage = "Biometric authentication not available"
            self.isAuthenticating = false
            return
        }

        let biometricType = context.biometryType == .faceID ? "Face ID" : "Touch ID"

        context.evaluatePolicy(
            .deviceOwnerAuthenticationWithBiometrics,
            localizedReason: "Authenticate to approve login request"
        ) { success, authError in
            DispatchQueue.main.async {
                if success {
                    // Biometric authentication successful, now approve with Auth0
                    pushService.approveCIBARequest(request) { result in
                        DispatchQueue.main.async {
                            self.isAuthenticating = false

                            switch result {
                            case .success:
                                self.showSuccess = true
                                // Dismiss after a delay
                                DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                                    dismiss()
                                }
                            case .failure(let error):
                                self.errorMessage = "Failed to approve: \(error.localizedDescription)"
                            }
                        }
                    }
                } else {
                    self.isAuthenticating = false
                    self.errorMessage = "\(biometricType) authentication failed"
                }
            }
        }
    }

    private func denyRequest() {
        guard let request = request else { return }

        isAuthenticating = true
        errorMessage = nil

        pushService.denyCIBARequest(request) { result in
            DispatchQueue.main.async {
                self.isAuthenticating = false

                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    self.errorMessage = "Failed to deny: \(error.localizedDescription)"
                }
            }
        }
    }

    // MARK: - Helpers

    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func formatTimeRemaining(_ timeInterval: TimeInterval) -> String {
        let minutes = Int(timeInterval) / 60
        let seconds = Int(timeInterval) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.theme.accent)
                .font(.body)
                .frame(width: 24)

            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.caption)
                    .foregroundColor(.gray)
                Text(value)
                    .font(.subheadline)
                    .fontWeight(.medium)
                    .foregroundColor(.theme.text)
            }

            Spacer()
        }
    }
}
