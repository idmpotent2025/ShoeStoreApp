//
//  TokensView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct TokensView: View {
    @ObservedObject var viewModel: TokensViewModel
    @EnvironmentObject var authService: AuthService
    @State private var expandedToken: String?

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                ScrollView {
                    if viewModel.hasTokens {
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Authentication Tokens")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.text)
                                .padding(.horizontal)
                                .padding(.top, 16)

                            Text("View and copy your authentication tokens")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .padding(.horizontal)

                            // ID Token
                            if let idToken = viewModel.idToken {
                                TokenCard(
                                    title: "ID Token",
                                    token: idToken,
                                    isExpanded: expandedToken == "id",
                                    onTap: {
                                        expandedToken = expandedToken == "id" ? nil : "id"
                                    },
                                    onCopy: {
                                        viewModel.copyToClipboard(idToken, tokenType: "ID Token")
                                    }
                                )
                            }

                            // Access Token
                            if let accessToken = viewModel.accessToken {
                                TokenCard(
                                    title: "Access Token",
                                    token: accessToken,
                                    isExpanded: expandedToken == "access",
                                    onTap: {
                                        expandedToken = expandedToken == "access" ? nil : "access"
                                    },
                                    onCopy: {
                                        viewModel.copyToClipboard(accessToken, tokenType: "Access Token")
                                    }
                                )
                            }

                            // Refresh Token
                            if let refreshToken = viewModel.refreshToken {
                                TokenCard(
                                    title: "Refresh Token",
                                    token: refreshToken,
                                    isExpanded: expandedToken == "refresh",
                                    onTap: {
                                        expandedToken = expandedToken == "refresh" ? nil : "refresh"
                                    },
                                    onCopy: {
                                        viewModel.copyToClipboard(refreshToken, tokenType: "Refresh Token")
                                    }
                                )
                            }

                            // Unlock with FaceID button
                            Button(action: {
                                viewModel.unlockWithBiometrics()
                            }) {
                                HStack {
                                    if viewModel.isRefreshing {
                                        ProgressView()
                                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                        Text("Refreshing...")
                                            .fontWeight(.semibold)
                                    } else {
                                        Image(systemName: "faceid")
                                        Text("Unlock With FaceID")
                                            .fontWeight(.semibold)
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .disabled(viewModel.isRefreshing)
                            .padding(.horizontal)
                            .padding(.top, 8)

                            // Copy success message
                            if let message = viewModel.copiedMessage {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text(message)
                                        .font(.subheadline)
                                        .foregroundColor(.green)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                                .padding(.horizontal)
                            }

                            // Refresh error message
                            if let error = viewModel.refreshError {
                                HStack {
                                    Image(systemName: "exclamationmark.triangle.fill")
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
                        }
                        .padding(.bottom, 32)
                    } else {
                        // Not authenticated state
                        VStack(spacing: 24) {
                            Image(systemName: "key.slash")
                                .resizable()
                                .frame(width: 80, height: 80)
                                .foregroundColor(.theme.primary)

                            Text("Authentication Required")
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.theme.text)

                            Text("Sign in to view your authentication tokens")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)

                            Button(action: {
                                authService.login { _ in }
                            }) {
                                HStack {
                                    Image(systemName: "lock.open")
                                    Text("Sign In")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                        }
                        .padding(.top, 60)
                    }
                }
            }
            .navigationTitle("Tokens")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct TokenCard: View {
    let title: String
    let token: String
    let isExpanded: Bool
    let onTap: () -> Void
    let onCopy: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            Button(action: onTap) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.theme.text)

                        Text("\(token.count) characters")
                            .font(.caption)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.theme.accent)
                }
            }

            // Token content
            if isExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(token)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                            .lineLimit(nil)
                            .textSelection(.enabled)
                    }
                    .frame(maxHeight: 150)

                    Button(action: onCopy) {
                        HStack {
                            Image(systemName: "doc.on.doc")
                            Text("Copy to Clipboard")
                        }
                        .font(.caption)
                        .foregroundColor(.theme.accent)
                    }
                }
            } else {
                Text(formatToken(token, maxLength: 60))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }

    private func formatToken(_ token: String, maxLength: Int) -> String {
        if token.count > maxLength {
            return String(token.prefix(maxLength)) + "..."
        }
        return token
    }
}
