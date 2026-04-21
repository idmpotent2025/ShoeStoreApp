//
//  AppConfiguration.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI

struct AppConfiguration: Codable {
    let branding: Branding
    let categories: [String: [Product]]

    // Computed property for backward compatibility
    var products: [Product] {
        return categories.values.flatMap { $0 }
    }

    // Custom coding keys to handle both formats
    enum CodingKeys: String, CodingKey {
        case branding
        case categories
        case products
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        branding = try container.decode(Branding.self, forKey: .branding)

        // Try to decode categories first, fallback to products array
        if let categoriesDict = try? container.decode([String: [Product]].self, forKey: .categories) {
            categories = categoriesDict
        } else if let productsArray = try? container.decode([Product].self, forKey: .products) {
            // Convert old format to new format
            categories = Dictionary(grouping: productsArray, by: { $0.category.rawValue })
        } else {
            categories = [:]
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(branding, forKey: .branding)
        try container.encode(categories, forKey: .categories)
    }

    struct Branding: Codable {
        let name: String
        let primaryColor: String
        let accentColor: String
        let backgroundColor: String

        var primaryColorValue: Color {
            Color(hex: primaryColor)
        }

        var accentColorValue: Color {
            Color(hex: accentColor)
        }

        var backgroundColorValue: Color {
            Color(hex: backgroundColor)
        }
    }

    static func load() -> AppConfiguration? {
        guard let url = Bundle.main.url(forResource: "Configuration", withExtension: "json"),
              let data = try? Data(contentsOf: url),
              let config = try? JSONDecoder().decode(AppConfiguration.self, from: data) else {
            print("Failed to load configuration file")
            return nil
        }
        return config
    }
}

// Helper extension to create Color from hex string
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
