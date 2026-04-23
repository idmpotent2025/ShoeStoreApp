//
//  SettingsCard.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct SettingsCard: View {
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
            Text("Settings")
                .font(.headline)
                .foregroundColor(.theme.text)
                .padding(.horizontal)
                .padding(.top)

            // FaceID Lock Toggle
            VStack(alignment: .leading, spacing: 8) {
                Text("Security")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

                Toggle(isOn: Binding(
                    get: { viewModel.useFaceIDLock },
                    set: { viewModel.updateFaceIDLock($0) }
                )) {
                    HStack {
                        Image(systemName: "faceid")
                            .foregroundColor(.theme.accent)
                            .font(.title3)

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Use Face ID to Lock")
                                .font(.subheadline)
                                .foregroundColor(.theme.text)

                            Text("Require biometric authentication to view profile")
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .toggleStyle(SwitchToggleStyle(tint: .theme.accent))
            }
            .padding(.horizontal)

            Divider()

            // Product Category Picker
            VStack(alignment: .leading, spacing: 8) {
                Text("Shop Preferences")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

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
            }
            .padding(.horizontal)

            Divider()

            // Theme Settings
            VStack(alignment: .leading, spacing: 12) {
                Text("Theme")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundColor(.gray)

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
                            .onChange(of: selectedColor) { newColor in
                                let hex = newColor.toHex()
                                viewModel.updateBackgroundColor(hex)
                            }
                    }
                }

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

// Helper extension to convert Color to hex
extension Color {
    func toHex() -> String {
        guard let components = UIColor(self).cgColor.components else {
            return "#000000"
        }

        let r = Int(components[0] * 255.0)
        let g = Int(components[1] * 255.0)
        let b = Int(components[2] * 255.0)

        return String(format: "#%02X%02X%02X", r, g, b)
    }
}
