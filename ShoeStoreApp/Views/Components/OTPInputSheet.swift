//
//  OTPInputSheet.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct OTPInputSheet: View {
    @ObservedObject var viewModel: NativeEmailOTPSignInViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    Image(systemName: "lock.shield.fill")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .foregroundColor(.theme.primary)

                    Text("Enter Verification Code")
                        .font(.title2)
                        .fontWeight(.bold)

                    Text("We sent a code to \(viewModel.email)")
                        .font(.subheadline)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Verification Code")
                            .font(.caption)
                            .foregroundColor(.gray)

                        TextField("000000", text: $viewModel.otpCode)
                            .keyboardType(.numberPad)
                            .padding()
                            .background(Color(hex: "#E8E8E8"))
                            .cornerRadius(12)
                            .font(.system(size: 24, weight: .semibold, design: .monospaced))
                            .multilineTextAlignment(.center)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.verifyOTP()
                    }) {
                        HStack {
                            if viewModel.isLoading {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                Text("Verifying...")
                                    .fontWeight(.semibold)
                            } else {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Verify Code")
                                    .fontWeight(.semibold)
                            }
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.theme.accent)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(viewModel.isLoading || viewModel.otpCode.isEmpty)
                    .padding(.horizontal)

                    Button(action: {
                        viewModel.sendOTP()
                    }) {
                        Text("Resend Code")
                            .font(.subheadline)
                            .foregroundColor(.theme.accent)
                    }
                    .disabled(viewModel.isLoading)

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
            .navigationTitle("Verify Code")
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
