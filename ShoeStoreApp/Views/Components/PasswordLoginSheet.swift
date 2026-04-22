//
//  PasswordLoginSheet.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct PasswordLoginSheet: View {
    @ObservedObject var viewModel: NativePasswordSignInViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    Image(systemName: "lock.circle.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.theme.primary)

                    Text("Password Login")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Sign in with your credentials")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email or Username")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("you@example.com", text: $viewModel.usernameOrEmail)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(hex: "#E8E8E8"))
                            .cornerRadius(12)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Password")
                            .font(.caption)
                            .foregroundColor(.gray)

                        SecureField("Enter your password", text: $viewModel.password)
                            .padding()
                            .background(Color(hex: "#E8E8E8"))
                            .cornerRadius(12)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.signIn()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Signing In...")
                                    .fontWeight(.semibold)
                            } else {
                                Image(systemName: "arrow.right.circle.fill")
                                Text("Sign In")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading || viewModel.usernameOrEmail.isEmpty || viewModel.password.isEmpty)
                    .padding(.horizontal)

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
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationTitle("Sign In")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                        viewModel.reset()
                    }
                }
            }
        }
    }
}
