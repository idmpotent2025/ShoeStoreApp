//
//  ForgotPasswordSheet.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct ForgotPasswordSheet: View {
    @ObservedObject var viewModel: UniversalLoginViewModel
    @Environment(\.dismiss) var dismiss
    @State private var email = ""

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 60))
                    .foregroundColor(.theme.primary)
                    .padding(.top, 40)

                Text("Reset Your Password")
                    .font(.title2)
                    .fontWeight(.bold)

                Text("Enter your email address and we'll send you a link to reset your password.")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                VStack(alignment: .leading, spacing: 8) {
                    Text("Email Address")
                        .font(.subheadline)
                        .fontWeight(.semibold)

                    TextField("Enter your email", text: $email)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .textContentType(.emailAddress)
                        .autocapitalization(.none)
                        .keyboardType(.emailAddress)
                }
                .padding(.horizontal)
                .padding(.top, 20)

                Button(action: {
                    viewModel.sendPasswordResetEmail(email: email)
                }) {
                    HStack {
                        if viewModel.isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        }
                        Text("Send Reset Link")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(email.isEmpty ? Color.gray : Color.theme.primary)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .disabled(email.isEmpty || viewModel.isLoading)
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

                Spacer()
            }
            .navigationTitle("Forgot Password")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}
