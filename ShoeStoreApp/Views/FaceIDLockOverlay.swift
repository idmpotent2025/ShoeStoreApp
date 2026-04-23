//
//  FaceIDLockOverlay.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct FaceIDLockOverlay: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(spacing: 24) {
            Spacer()

            // Lock Icon
            Image(systemName: "lock.fill")
                .resizable()
                .frame(width: 60, height: 80)
                .foregroundColor(.theme.primary)

            Text("Profile Locked")
                .font(.title2)
                .fontWeight(.bold)
                .foregroundColor(.theme.text)

            Text("Unlock with biometrics to view your profile")
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            // Unlock Button
            Button(action: {
                viewModel.unlockWithBiometrics()
            }) {
                HStack {
                    Image(systemName: "faceid")
                    Text("Unlock with Face ID")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: 280)
                .padding()
                .background(Color.theme.accent)
                .foregroundColor(.white)
                .cornerRadius(12)
            }
            .padding(.top, 16)

            // Error Message
            if let error = viewModel.biometricError {
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

            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.theme.background.edgesIgnoringSafeArea(.all))
    }
}
