//
//  UniversalLoginView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct UniversalLoginView: View {
    @ObservedObject var viewModel: UniversalLoginViewModel
    @ObservedObject var signUpViewModel: SignUpUniversalLoginViewModel

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Success/Logout Section
                    if viewModel.isAuthenticated {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(.green)
                                Text("Successfully authenticated!")
                                    .font(.headline)
                                    .foregroundColor(.green)
                            }
                            .padding()
                            .background(Color.green.opacity(0.1))
                            .cornerRadius(12)

                            Button(action: {
                                viewModel.logout()
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
                        }
                    }

                    // Features
                    if !viewModel.isAuthenticated {
                        VStack(spacing: 16) {
                            FeatureCard(
                                icon: "globe",
                                title: "Hosted Login Flow",
                                description: "Centralized authentication UI maintained by Auth0",
                                isLoading: viewModel.isLoading,
                                action: {
                                    viewModel.startUniversalLogin()
                                }
                            )

                            FeatureCard(
                                icon: "person.badge.plus.fill",
                                title: "Hosted SignUp Flow",
                                description: "Create new account with Universal Login",
                                isLoading: signUpViewModel.isLoading,
                                action: {
                                    signUpViewModel.startSignUp()
                                }
                            )

                            FeatureCard(
                                icon: "person.2.fill",
                                title: "Hosted Social Flow",
                                description: "Support for Google, Facebook, Apple, and more",
                                isLoading: viewModel.isLoading,
                                action: {
                                    viewModel.startSocialULogin()
                                }
                            )

                        }
                    }

                    // MFA Card - Always visible for testing step-up authentication
                    VStack(spacing: 16) {
                        FeatureCard(
                            icon: "shield.checkerboard",
                            title: "Hosted MFA Auth Flow",
                            description: viewModel.isAuthenticated
                                ? "Test step-up MFA authentication with existing session"
                                : "Built-in MFA with SMS, email, and authenticator apps",
                            isLoading: viewModel.isLoading,
                            action: {
                                viewModel.startMFALogin()
                            }
                        )
                    }

                    // Error Message
                    if let errorMessage = viewModel.errorMessage {
                        HStack {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.red)
                            Text(errorMessage)
                                .font(.subheadline)
                                .foregroundColor(.red)
                        }
                        .padding()
                        .background(Color.red.opacity(0.1))
                        .cornerRadius(8)
                    }
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Hosted UX")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct FeatureCard: View {
    let icon: String
    let title: String
    let description: String
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.theme.primary)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.theme.text)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                HStack {
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .theme.accent))
                        Text("Authenticating...")
                            .font(.caption)
                            .foregroundColor(.theme.accent)
                    } else {
                        Image(systemName: "arrow.right.circle.fill")
                            .foregroundColor(.theme.accent)
                        Text("Try Now")
                            .font(.caption)
                            .fontWeight(.semibold)
                            .foregroundColor(.theme.accent)
                    }
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#E8E8E8"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
        .disabled(isLoading)
    }
}
