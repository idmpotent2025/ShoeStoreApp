//
//  Color+Theme.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

extension Color {
    struct Theme {
        var primary: Color
        var accent: Color
        var background: Color
        var text: Color

        static var current: Theme {
            // Get dynamic background from ThemeManager
            let themeManager = ThemeManager.shared

            if let config = AppConfiguration.load() {
                return Theme(
                    primary: config.branding.primaryColorValue,
                    accent: config.branding.accentColorValue,
                    background: themeManager.backgroundColor,
                    text: Color(hex: "#1A1A1A")
                )
            } else {
                // Fallback to teal theme if config fails to load
                return Theme(
                    primary: Color(hex: "#003057"),
                    accent: Color(hex: "#0055A6"),
                    background: themeManager.backgroundColor,
                    text: Color(hex: "#1A1A1A")
                )
            }
        }
    }

    static var theme: Theme {
        Theme.current
    }
}
