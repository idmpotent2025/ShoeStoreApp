//
//  NativeAuthView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct NativeAuthView: View {
    @ObservedObject var appleSignInViewModel: NativeAppleSignInViewModel
    @ObservedObject var passkeysSignInViewModel: NativePasskeysSignInViewModel
    @ObservedObject var facebookSignInViewModel: NativeFacebookSignInViewModel
    @ObservedObject var emailOTPSignInViewModel: NativeEmailOTPSignInViewModel
    @ObservedObject var passwordSignInViewModel: NativePasswordSignInViewModel
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // Success/Logout Section
                    if isAuthenticated {
                        VStack(spacing: 16) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                    .foregroundColor(Color(hex: "#FFD700"))
                                Text("Successfully authenticated!")
                                    .font(.headline)
                                    .foregroundColor(Color(hex: "#FFD700"))
                            }
                            .padding()
                            .background(Color(hex: "#FFD700").opacity(0.2))
                            .cornerRadius(12)

                            if let email = currentEmail {
                                Text("Email: \(email)")
                                    .font(.subheadline)
                                    .foregroundColor(.gray)
                            }

                            Button(action: {
                                logout()
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

                    // Authentication Methods
                    if !isAuthenticated {
                        VStack(spacing: 16) {
                            // Sign in with Apple
                            AuthMethodCard(
                                icon: "apple.logo",
                                title: "Native Sign in with Apple",
                                description: "Use AppleID for secure login",
                                badge: "Real",
                                badgeColor: .blue,
                                isLoading: appleSignInViewModel.isLoading,
                                action: {
                                    appleSignInViewModel.signIn()
                                }
                            )

                            // SignIn With Passkey
                            AuthMethodCard(
                                icon: "key.fill",
                                title: "Native SignIn With Passkey",
                                description: "Login with Face ID or Touch ID",
                                badge: "Real",
                                badgeColor: .blue,
                                isLoading: passkeysSignInViewModel.isLoading,
                                action: {
                                    passkeysSignInViewModel.signIn()
                                }
                            )

                            

                            // Email OTP Login
                            AuthMethodCard(
                                icon: "envelope.fill",
                                title: "Native Email OTP",
                                description: "SignIn via Email OTP",
                                badge: "Real",
                                badgeColor: .blue,
                                isLoading: emailOTPSignInViewModel.isLoading,
                                action: {
                                    emailOTPSignInViewModel.startEmailOTPFlow()
                                }
                            )

                            // Password Login
                            AuthMethodCard(
                                icon: "lock.circle.fill",
                                title: "Native Password Login",
                                description: "Sign in with password",
                                badge: "Real",
                                badgeColor: .blue,
                                isLoading: passwordSignInViewModel.isLoading,
                                action: {
                                    passwordSignInViewModel.startPasswordFlow()
                                }
                            )

                            // Facebook Login
                            AuthMethodCard(
                                icon: "f.circle.fill",
                                title: "Native Facebook Login",
                                description: "Connect with your Facebook account",
                                badge: "Mock",
                                badgeColor: .blue,
                                isLoading: facebookSignInViewModel.isLoading,
                                action: {
                                    facebookSignInViewModel.signIn()
                                }
                            )
                        }
                    }

                    // Error Messages
                    if let errorMessage = currentErrorMessage {
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
            .navigationTitle("Native UX")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(Color.theme.background, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Image("AppIcon")
                        .resizable()
                        .frame(width: 28, height: 28)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                }
            }
            .sheet(isPresented: $emailOTPSignInViewModel.showEmailInput) {
                EmailInputSheet(viewModel: emailOTPSignInViewModel)
            }
            .sheet(isPresented: $emailOTPSignInViewModel.showOTPInput) {
                OTPInputSheet(viewModel: emailOTPSignInViewModel)
            }
            .sheet(isPresented: $passwordSignInViewModel.showPasswordInput) {
                PasswordLoginSheet(viewModel: passwordSignInViewModel)
            }
        }
    }

    // Computed properties to aggregate state from all view models
    private var isAuthenticated: Bool {
        appleSignInViewModel.isAuthenticated ||
        passkeysSignInViewModel.isAuthenticated ||
        facebookSignInViewModel.isAuthenticated ||
        emailOTPSignInViewModel.isAuthenticated ||
        passwordSignInViewModel.isAuthenticated
    }

    private var currentEmail: String? {
        appleSignInViewModel.userEmail ??
        passkeysSignInViewModel.userEmail ??
        facebookSignInViewModel.userEmail ??
        emailOTPSignInViewModel.userEmail ??
        passwordSignInViewModel.userEmail
    }

    private var currentErrorMessage: String? {
        appleSignInViewModel.errorMessage ??
        passkeysSignInViewModel.errorMessage ??
        facebookSignInViewModel.errorMessage ??
        emailOTPSignInViewModel.errorMessage ??
        passwordSignInViewModel.errorMessage
    }

    private var currentSuccessMessage: String? {
        appleSignInViewModel.successMessage ??
        passkeysSignInViewModel.successMessage ??
        facebookSignInViewModel.successMessage ??
        emailOTPSignInViewModel.successMessage ??
        passwordSignInViewModel.successMessage
    }

    private func logout() {
        // Clear AuthService state
        authService.isAuthenticated = false
        authService.userProfile = nil
        authService.idToken = nil
        authService.accessToken = nil
        authService.refreshToken = nil

        // Reset all view model states
        appleSignInViewModel.isAuthenticated = false
        appleSignInViewModel.userEmail = nil
        appleSignInViewModel.successMessage = nil
        appleSignInViewModel.errorMessage = nil

        passkeysSignInViewModel.isAuthenticated = false
        passkeysSignInViewModel.userEmail = nil
        passkeysSignInViewModel.successMessage = nil
        passkeysSignInViewModel.errorMessage = nil

        facebookSignInViewModel.isAuthenticated = false
        facebookSignInViewModel.userEmail = nil
        facebookSignInViewModel.successMessage = nil
        facebookSignInViewModel.errorMessage = nil

        emailOTPSignInViewModel.isAuthenticated = false
        emailOTPSignInViewModel.userEmail = nil
        emailOTPSignInViewModel.successMessage = nil
        emailOTPSignInViewModel.errorMessage = nil

        passwordSignInViewModel.isAuthenticated = false
        passwordSignInViewModel.userEmail = nil
        passwordSignInViewModel.successMessage = nil
        passwordSignInViewModel.errorMessage = nil
    }
}

struct AuthMethodCard: View {
    let icon: String
    let title: String
    let description: String
    let badge: String
    let badgeColor: Color
    let isLoading: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    Image(systemName: icon)
                        .font(.title)
                        .foregroundColor(.theme.primary)

                    Spacer()

                    Text(badge)
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(badgeColor)
                        .cornerRadius(4)
                }

                Text(title)
                    .font(.headline)
                    .foregroundColor(.theme.text)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)

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
