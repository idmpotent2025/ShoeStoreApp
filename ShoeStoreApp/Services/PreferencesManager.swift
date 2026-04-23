//
//  PreferencesManager.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class PreferencesManager: ObservableObject {
    static let shared = PreferencesManager()

    // Published properties for reactive updates
    @Published var useFaceIDLock: Bool {
        didSet {
            UserDefaults.standard.set(useFaceIDLock, forKey: Keys.useFaceIDLock)
        }
    }

    @Published var selectedCategory: ProductCategory {
        didSet {
            UserDefaults.standard.set(selectedCategory.rawValue, forKey: Keys.selectedCategory)
        }
    }

    @Published var backgroundColor: String {
        didSet {
            UserDefaults.standard.set(backgroundColor, forKey: Keys.backgroundColor)
        }
    }

    @Published var brandLabel: String {
        didSet {
            UserDefaults.standard.set(brandLabel, forKey: Keys.brandLabel)
        }
    }

    @Published var brandFontStyle: BrandFontStyle {
        didSet {
            UserDefaults.standard.set(brandFontStyle.rawValue, forKey: Keys.brandFontStyle)
        }
    }

    // UserDefaults keys
    private enum Keys {
        static let useFaceIDLock = "useFaceIDLock"
        static let selectedCategory = "selectedProductCategory"
        static let backgroundColor = "appBackgroundColor"
        static let brandLabel = "brandLabel"
        static let brandFontStyle = "brandFontStyle"
    }

    private init() {
        // Load saved preferences or use defaults
        self.useFaceIDLock = UserDefaults.standard.bool(forKey: Keys.useFaceIDLock)

        if let savedCategory = UserDefaults.standard.string(forKey: Keys.selectedCategory),
           let category = ProductCategory(rawValue: savedCategory) {
            self.selectedCategory = category
        } else {
            self.selectedCategory = .dresses
        }

        if let savedColor = UserDefaults.standard.string(forKey: Keys.backgroundColor) {
            self.backgroundColor = savedColor
        } else {
            // Default from configuration
            if let config = AppConfiguration.load() {
                self.backgroundColor = config.branding.backgroundColor
            } else {
                self.backgroundColor = "#3A7D7D"
            }
        }

        if let savedLabel = UserDefaults.standard.string(forKey: Keys.brandLabel) {
            self.brandLabel = savedLabel
        } else {
            // Default from configuration
            if let config = AppConfiguration.load() {
                self.brandLabel = config.branding.name
            } else {
                self.brandLabel = "Shoe Store"
            }
        }

        if let savedFontStyle = UserDefaults.standard.string(forKey: Keys.brandFontStyle),
           let fontStyle = BrandFontStyle(rawValue: savedFontStyle) {
            self.brandFontStyle = fontStyle
        } else {
            self.brandFontStyle = .system
        }
    }

    // Convenience computed property for SwiftUI Color
    var backgroundColorValue: Color {
        Color(hex: backgroundColor)
    }

    // Reset to defaults
    func resetToDefaults() {
        useFaceIDLock = false
        selectedCategory = .dresses
        brandFontStyle = .system

        if let config = AppConfiguration.load() {
            backgroundColor = config.branding.backgroundColor
            brandLabel = config.branding.name
        } else {
            backgroundColor = "#3A7D7D"
            brandLabel = "Shoe Store"
        }
    }
}
