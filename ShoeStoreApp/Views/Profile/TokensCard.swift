//
//  TokensCard.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct TokensCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var expandedToken: String?

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Text("Authentication Tokens")
                    .font(.headline)
                    .foregroundColor(.theme.text)

                Spacer()

                // Refresh Button
                Button(action: {
                    viewModel.refreshTokens()
                }) {
                    HStack(spacing: 6) {
                        if viewModel.isRefreshing {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .theme.accent))
                                .scaleEffect(0.8)
                        } else {
                            Image(systemName: "arrow.clockwise")
                                .foregroundColor(.theme.accent)
                        }
                        Text(viewModel.isRefreshing ? "Refreshing..." : "Refresh")
                            .font(.caption)
                            .foregroundColor(.theme.accent)
                    }
                }
                .disabled(viewModel.isRefreshing || !viewModel.hasTokens)
            }
            .padding(.horizontal)
            .padding(.top)

            if viewModel.hasTokens {
                // ID Token
                if let idToken = viewModel.idToken {
                    TokenAccordion(
                        title: "ID Token",
                        token: idToken,
                        isExpanded: expandedToken == "id",
                        onTap: {
                            withAnimation {
                                expandedToken = expandedToken == "id" ? nil : "id"
                            }
                        },
                        onCopy: {
                            viewModel.copyToClipboard(idToken, tokenType: "ID Token")
                        }
                    )
                }

                // Access Token
                if let accessToken = viewModel.accessToken {
                    TokenAccordion(
                        title: "Access Token",
                        token: accessToken,
                        isExpanded: expandedToken == "access",
                        onTap: {
                            withAnimation {
                                expandedToken = expandedToken == "access" ? nil : "access"
                            }
                        },
                        onCopy: {
                            viewModel.copyToClipboard(accessToken, tokenType: "Access Token")
                        }
                    )
                }

                // Refresh Token
                if let refreshToken = viewModel.refreshToken {
                    TokenAccordion(
                        title: "Refresh Token",
                        token: refreshToken,
                        isExpanded: expandedToken == "refresh",
                        onTap: {
                            withAnimation {
                                expandedToken = expandedToken == "refresh" ? nil : "refresh"
                            }
                        },
                        onCopy: {
                            viewModel.copyToClipboard(refreshToken, tokenType: "Refresh Token")
                        }
                    )
                }

                // Success/Error Messages
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
            } else {
                // No Tokens State
                VStack(spacing: 12) {
                    Image(systemName: "key.slash")
                        .font(.system(size: 40))
                        .foregroundColor(.gray.opacity(0.5))

                    Text("No tokens available")
                        .font(.subheadline)
                        .foregroundColor(.gray)

                    Text("Sign in to view your authentication tokens")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 32)
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
        .padding(.bottom)
    }
}

struct TokenAccordion: View {
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
                            .font(.system(size: 15, weight: .semibold))
                            .foregroundColor(.theme.text)

                        Text("\(token.count) characters")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up.circle.fill" : "chevron.down.circle")
                        .foregroundColor(.theme.accent)
                        .font(.title3)
                }
            }

            // Token Content (when expanded)
            if isExpanded {
                VStack(alignment: .leading, spacing: 12) {
                    // Token Text
                    ScrollView(.horizontal, showsIndicators: false) {
                        Text(token)
                            .font(.system(size: 10, design: .monospaced))
                            .foregroundColor(.gray)
                            .lineLimit(nil)
                            .textSelection(.enabled)
                            .padding(.vertical, 8)
                    }
                    .frame(maxHeight: 120)
                    .background(Color.gray.opacity(0.05))
                    .cornerRadius(6)

                    // Copy Button
                    Button(action: onCopy) {
                        HStack {
                            Image(systemName: "doc.on.doc.fill")
                            Text("Copy to Clipboard")
                                .fontWeight(.medium)
                        }
                        .font(.caption)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(Color.theme.accent.opacity(0.1))
                        .foregroundColor(.theme.accent)
                        .cornerRadius(8)
                    }
                }
            } else {
                // Preview (when collapsed)
                Text(formatToken(token, maxLength: 60))
                    .font(.system(size: 10, design: .monospaced))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color.gray.opacity(0.03))
        .cornerRadius(8)
        .padding(.horizontal)
    }

    private func formatToken(_ token: String, maxLength: Int) -> String {
        if token.count > maxLength {
            return String(token.prefix(maxLength)) + "..."
        }
        return token
    }
}
