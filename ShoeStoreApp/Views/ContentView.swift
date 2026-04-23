//
//  ContentView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct ContentView: View {
    @StateObject private var cartViewModel = CartViewModel()
    @StateObject private var authService = AuthService()
    @StateObject private var qrCodeService = QRCodeService()
    @StateObject private var appleSignInViewModel: NativeAppleSignInViewModel
    @StateObject private var passkeysSignInViewModel: NativePasskeysSignInViewModel
    @StateObject private var facebookSignInViewModel: NativeFacebookSignInViewModel
    @StateObject private var emailOTPSignInViewModel: NativeEmailOTPSignInViewModel
    @StateObject private var passwordSignInViewModel: NativePasswordSignInViewModel
    @StateObject private var appLockManager = AppLockManager.shared

    @Environment(\.scenePhase) private var scenePhase

    init() {
        let authService = AuthService()
        _authService = StateObject(wrappedValue: authService)
        _cartViewModel = StateObject(wrappedValue: CartViewModel())
        _qrCodeService = StateObject(wrappedValue: QRCodeService())
        _appleSignInViewModel = StateObject(wrappedValue: NativeAppleSignInViewModel(authService: authService))
        _passkeysSignInViewModel = StateObject(wrappedValue: NativePasskeysSignInViewModel(authService: authService))
        _facebookSignInViewModel = StateObject(wrappedValue: NativeFacebookSignInViewModel(authService: authService))
        _emailOTPSignInViewModel = StateObject(wrappedValue: NativeEmailOTPSignInViewModel(authService: authService))
        _passwordSignInViewModel = StateObject(wrappedValue: NativePasswordSignInViewModel(authService: authService))
    }

    var body: some View {
        ZStack {
            TabView {
                ShopCartView()
                    .environmentObject(cartViewModel)
                    .tabItem {
                        Label("Shop", systemImage: "bag.fill")
                    }

                UniversalLoginView(
                    viewModel: UniversalLoginViewModel(authService: authService),
                    signUpViewModel: SignUpUniversalLoginViewModel(authService: authService)
                )
                .tabItem {
                    Label("Universal", systemImage: "lock.shield.fill")
                }

                NativeAuthView(
                    appleSignInViewModel: appleSignInViewModel,
                    passkeysSignInViewModel: passkeysSignInViewModel,
                    facebookSignInViewModel: facebookSignInViewModel,
                    emailOTPSignInViewModel: emailOTPSignInViewModel,
                    passwordSignInViewModel: passwordSignInViewModel
                )
                .environmentObject(authService)
                .tabItem {
                    Label("Native", systemImage: "touchid")
                }

                AdvancedFlowsView(
                    viewModel: AdvancedFlowsViewModel(qrCodeService: qrCodeService)
                )
                .tabItem {
                    Label("Multi-Channel", systemImage: "gearshape.2.fill")
                }

                ProfileView(
                    viewModel: ProfileViewModel(authService: authService)
                )
                .environmentObject(authService)
                .tabItem {
                    Label("Profile", systemImage: "person.circle.fill")
                }
            }
            .accentColor(.theme.accent)

            // App Lock Overlay
            if appLockManager.isLocked {
                AppLockView(appLockManager: appLockManager)
                    .transition(.opacity)
                    .zIndex(999)
            }
        }
        .onChange(of: scenePhase) { _, newPhase in
            if newPhase == .active {
                appLockManager.handleAppBecameActive()
            } else if newPhase == .background {
                // Only track .background, not .inactive
                // .inactive happens during system overlays (Sign In with Apple, Face ID, etc.)
                // .background happens when user truly leaves the app
                appLockManager.handleAppWentToBackground()
            }
        }
    }
}
