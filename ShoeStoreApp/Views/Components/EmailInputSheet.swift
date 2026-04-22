//
//  EmailInputSheet.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct EmailInputSheet: View {
    @ObservedObject var viewModel: NativeEmailOTPSignInViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    Image(systemName: "envelope.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.theme.primary)

                    Text("Email OTP Authentication")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("Enter your email address to receive a verification code")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email Address")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("you@example.com", text: $viewModel.email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .padding()
                            .background(Color(hex: "#E8E8E8"))
                            .cornerRadius(12)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.sendOTP()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Sending...")
                                    .fontWeight(.semibold)
                            } else {
                                Image(systemName: "paperplane.fill")
                                Text("Send Code")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading || viewModel.email.isEmpty)
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
            .navigationTitle("Email OTP")
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
