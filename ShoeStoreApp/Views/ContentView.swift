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

    init() {
        let authService = AuthService()
        _authService = StateObject(wrappedValue: authService)
        _cartViewModel = StateObject(wrappedValue: CartViewModel())
        _qrCodeService = StateObject(wrappedValue: QRCodeService())
        _appleSignInViewModel = StateObject(wrappedValue: NativeAppleSignInViewModel(authService: authService))
        _passkeysSignInViewModel = StateObject(wrappedValue: NativePasskeysSignInViewModel(authService: authService))
        _facebookSignInViewModel = StateObject(wrappedValue: NativeFacebookSignInViewModel(authService: authService))
        _emailOTPSignInViewModel = StateObject(wrappedValue: NativeEmailOTPSignInViewModel(authService: authService))
    }

    var body: some View {
        TabView {
            ShopCartView()
                .environmentObject(cartViewModel)
                .tabItem {
                    Label("Shop", systemImage: "bag.fill")
                }
                .badge(cartViewModel.totalItems)

            UniversalLoginView(
                viewModel: UniversalLoginViewModel(authService: authService)
            )
            .tabItem {
                Label("Universal", systemImage: "lock.shield.fill")
            }

            NativeAuthView(
                appleSignInViewModel: appleSignInViewModel,
                passkeysSignInViewModel: passkeysSignInViewModel,
                facebookSignInViewModel: facebookSignInViewModel,
                emailOTPSignInViewModel: emailOTPSignInViewModel
            )
            .environmentObject(authService)
            .tabItem {
                Label("Native", systemImage: "touchid")
            }

            AdvancedFlowsView(
                viewModel: AdvancedFlowsViewModel(qrCodeService: qrCodeService)
            )
            .tabItem {
                Label("Advanced", systemImage: "gearshape.2.fill")
            }

            TokensView(
                viewModel: TokensViewModel(authService: authService)
            )
            .environmentObject(authService)
            .tabItem {
                Label("Tokens", systemImage: "key.fill")
            }
        }
        .accentColor(.theme.accent)
    }
}
