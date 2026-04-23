//
//  ThemeManager.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class ThemeManager: ObservableObject {
    static let shared = ThemeManager()

    @Published var backgroundColor: Color

    private var cancellables = Set<AnyCancellable>()
    private let preferencesManager = PreferencesManager.shared

    private init() {
        // Initialize with current preference
        self.backgroundColor = preferencesManager.backgroundColorValue

        // Subscribe to preference changes
        preferencesManager.$backgroundColor
            .map { Color(hex: $0) }
            .assign(to: &$backgroundColor)
    }

    // Get the current theme with dynamic background color
    var currentTheme: Color.Theme {
        let config = AppConfiguration.load()
        return Color.Theme(
            primary: config?.branding.primaryColorValue ?? Color(hex: "#003057"),
            accent: config?.branding.accentColorValue ?? Color(hex: "#0055A6"),
            background: backgroundColor,
            text: Color(hex: "#1A1A1A")
        )
    }
}
