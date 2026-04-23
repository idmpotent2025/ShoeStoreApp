//
//  AppLockView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct AppLockView: View {
    @ObservedObject var appLockManager: AppLockManager

    var body: some View {
        ZStack {
            // Background blur effect
            Color.theme.background
                .edgesIgnoringSafeArea(.all)

            VStack(spacing: 30) {
                Spacer()

                // Lock Icon
                Image(systemName: "lock.fill")
                    .font(.system(size: 80))
                    .foregroundColor(.theme.primary)

                // Title
                Text("App Locked")
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.theme.text)

                // Subtitle
                Text("Authenticate to continue")
                    .font(.subheadline)
                    .foregroundColor(.gray)

                Spacer()

                // Unlock Button
                Button(action: {
                    appLockManager.unlockApp()
                }) {
                    HStack(spacing: 12) {
                        Image(systemName: "faceid")
                            .font(.title2)
                        Text("Unlock with Face ID")
                            .fontWeight(.semibold)
                    }
                    .frame(maxWidth: 300)
                    .padding()
                    .background(Color.theme.accent)
                    .foregroundColor(.white)
                    .cornerRadius(12)
                }
                .padding(.horizontal)

                // Error Message
                if let error = appLockManager.authenticationError {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal)
                        .padding(.top, 8)
                }

                Spacer()
            }
            .padding()
        }
    }
}
