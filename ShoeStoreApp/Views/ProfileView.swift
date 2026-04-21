//
//  ProfileView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI
import Auth0

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var expandedToken: String?

    private var authService: AuthService {
        viewModel.authService
    }

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 24) {
                        if authService.isAuthenticated {
                            // User Profile Section
                            VStack(spacing: 16) {
                                Image(systemName: "person.circle.fill")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.theme.primary)

                                if let name = authService.userProfile?.name {
                                    Text(name)
                                        .font(.title2)
                                        .fontWeight(.bold)
                                        .foregroundColor(.theme.text)
                                }

                                if let email = authService.userProfile?.email {
                                    Text(email)
                                        .font(.subheadline)
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding()

                            // Tokens Section
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Authentication Tokens")
                                    .font(.headline)
                                    .foregroundColor(.theme.text)
                                    .padding(.horizontal)

                                TokenRow(
                                    title: "ID Token",
                                    token: authService.idToken,
                                    isExpanded: expandedToken == "id",
                                    onTap: {
                                        expandedToken = expandedToken == "id" ? nil : "id"
                                    }
                                )

                                TokenRow(
                                    title: "Access Token",
                                    token: authService.accessToken,
                                    isExpanded: expandedToken == "access",
                                    onTap: {
                                        expandedToken = expandedToken == "access" ? nil : "access"
                                    }
                                )

                                TokenRow(
                                    title: "Refresh Token",
                                    token: authService.refreshToken,
                                    isExpanded: expandedToken == "refresh",
                                    onTap: {
                                        expandedToken = expandedToken == "refresh" ? nil : "refresh"
                                    }
                                )
                            }

                            // Logout Button
                            Button(action: {
                                authService.logout()
                            }) {
                                HStack {
                                    Image(systemName: "rectangle.portrait.and.arrow.right")
                                    Text("Logout")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 16)

                        } else {
                            // Not Authenticated
                            VStack(spacing: 24) {
                                Image(systemName: "lock.circle")
                                    .resizable()
                                    .frame(width: 100, height: 100)
                                    .foregroundColor(.theme.primary)

                                Text("Sign in to access your profile")
                                    .font(.headline)
                                    .foregroundColor(.theme.text)
                                    .multilineTextAlignment(.center)

                                Button(action: {
                                    authService.login { result in
                                        switch result {
                                        case .success:
                                            print("Login successful")
                                        case .failure(let error):
                                            print("Login error: \(error.localizedDescription)")
                                        }
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: "lock.open")
                                        Text("Login with Auth0")
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
                    .padding(.vertical, 24)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.large)
        }
    }
}

struct TokenRow: View {
    let title: String
    let token: String?
    let isExpanded: Bool
    let onTap: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Button(action: onTap) {
                HStack {
                    Text(title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.theme.text)

                    Spacer()

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(.theme.accent)
                }
            }

            if isExpanded {
                Text(token ?? "Not available")
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .lineLimit(nil)
                    .textSelection(.enabled)
            } else {
                Text(formatToken(token, maxLength: 50))
                    .font(.system(size: 11, design: .monospaced))
                    .foregroundColor(.gray)
                    .lineLimit(1)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .padding(.horizontal)
    }

    private func formatToken(_ token: String?, maxLength: Int) -> String {
        guard let token = token else { return "Not available" }
        if token.count > maxLength {
            return String(token.prefix(maxLength)) + "..."
        }
        return token
    }
}
