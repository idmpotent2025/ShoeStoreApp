//
//  ProfileView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var viewModel: ProfileViewModel
    @EnvironmentObject var authService: AuthService

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                ScrollView {
                    VStack(spacing: 20) {
                        // FaceID Lock Toggle - At Top
                        FaceIDToggleCard(viewModel: viewModel)
                            .padding(.top, 16)

                        // User Profile Card
                        UserProfileCard(viewModel: viewModel)

                        // Tokens Card - Always visible
                        TokensCard(viewModel: viewModel)

                        // Settings Card - Theme settings only
                        ThemeSettingsCard(viewModel: viewModel)

                        // Product Category Picker - At Bottom
                        CategoryPickerCard(viewModel: viewModel)

                        // Logout Button (only if authenticated)
                        if authService.isAuthenticated {
                            Button(action: {
                                authService.logout()
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
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }

                        // Login Button (only if not authenticated)
                        if !authService.isAuthenticated {
                            Button(action: {
                                authService.login { _ in }
                            }) {
                                HStack {
                                    Image(systemName: "lock.open")
                                    Text("Login with Auth0")
                                        .fontWeight(.semibold)
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.theme.accent)
                                .foregroundColor(.white)
                                .cornerRadius(12)
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    .padding(.bottom, 32)
                }
            }
            .navigationTitle("Profile")
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
        }
    }
}

// MARK: - FaceID Toggle Card
struct FaceIDToggleCard: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Toggle(isOn: Binding(
                get: { viewModel.useFaceIDLock },
                set: { viewModel.updateFaceIDLock($0) }
            )) {
                HStack(spacing: 12) {
                    Image(systemName: "faceid")
                        .foregroundColor(.theme.accent)
                        .font(.title2)

                    VStack(alignment: .leading, spacing: 2) {
                        Text("Use Face ID to Lock App")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.theme.text)

                        Text("Require biometric authentication when app becomes active")
                            .font(.caption2)
                            .foregroundColor(.gray)
                    }
                }
            }
            .toggleStyle(SwitchToggleStyle(tint: .theme.accent))
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Theme Settings Card
struct ThemeSettingsCard: View {
    @ObservedObject var viewModel: ProfileViewModel
    @State private var showColorPicker = false
    @State private var selectedColor: Color

    init(viewModel: ProfileViewModel) {
        self.viewModel = viewModel
        _selectedColor = State(initialValue: viewModel.backgroundColor)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header
            Text("Theme Settings")
                .font(.headline)
                .foregroundColor(.theme.text)
                .padding(.horizontal)
                .padding(.top)

            // Background Color
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "paintpalette.fill")
                        .foregroundColor(.theme.accent)
                        .font(.title3)

                    Text("Background Color")
                        .font(.subheadline)
                        .foregroundColor(.theme.text)

                    Spacer()

                    // Color Preview
                    Circle()
                        .fill(selectedColor)
                        .frame(width: 30, height: 30)
                        .overlay(
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .onTapGesture {
                            showColorPicker.toggle()
                        }
                }

                if showColorPicker {
                    ColorPicker("Select Color", selection: $selectedColor, supportsOpacity: false)
                        .labelsHidden()
                        .padding(.leading, 40)
                        .onChange(of: selectedColor) { _, newColor in
                            let hex = newColor.toHex()
                            viewModel.updateBackgroundColor(hex)
                        }
                }
            }
            .padding(.horizontal)

            Divider()

            // Brand Font Style
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "textformat.size")
                        .foregroundColor(.theme.accent)
                        .font(.title3)

                    Text("Brand Font Style")
                        .font(.subheadline)
                        .foregroundColor(.theme.text)

                    Spacer()

                    Picker("Font Style", selection: Binding(
                        get: { viewModel.brandFontStyle },
                        set: { viewModel.updateBrandFontStyle($0) }
                    )) {
                        ForEach(BrandFontStyle.allCases, id: \.self) { fontStyle in
                            Text(fontStyle.displayName).tag(fontStyle)
                        }
                    }
                    .pickerStyle(MenuPickerStyle())
                }
            }
            .padding(.horizontal)
            .padding(.bottom)
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}

// MARK: - Category Picker Card
struct CategoryPickerCard: View {
    @ObservedObject var viewModel: ProfileViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Shop Preferences")
                .font(.headline)
                .foregroundColor(.theme.text)

            // Product Category
            HStack {
                Image(systemName: "bag.fill")
                    .foregroundColor(.theme.accent)
                    .font(.title3)

                Text("Product Category")
                    .font(.subheadline)
                    .foregroundColor(.theme.text)

                Spacer()

                Picker("Category", selection: Binding(
                    get: { viewModel.selectedCategory },
                    set: { viewModel.updateCategory($0) }
                )) {
                    ForEach(ProductCategory.allCases, id: \.self) { category in
                        Text(category.displayName).tag(category)
                    }
                }
                .pickerStyle(MenuPickerStyle())
            }

            Divider()

            // Brand Label
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "textformat")
                        .foregroundColor(.theme.accent)
                        .font(.title3)

                    Text("Brand Label")
                        .font(.subheadline)
                        .foregroundColor(.theme.text)
                }

                TextField("Enter brand name", text: Binding(
                    get: { viewModel.brandLabel },
                    set: { viewModel.updateBrandLabel($0) }
                ))
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .padding(.leading, 40)
            }
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(Color.white)
        .cornerRadius(12)
        .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        .padding(.horizontal)
    }
}
