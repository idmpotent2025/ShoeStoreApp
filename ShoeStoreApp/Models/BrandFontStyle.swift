//
//  BrandFontStyle.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

enum BrandFontStyle: String, CaseIterable {
    case system = "system"
    case rounded = "rounded"
    case serif = "serif"
    case monospaced = "monospaced"

    var displayName: String {
        switch self {
        case .system:
            return "System"
        case .rounded:
            return "Rounded"
        case .serif:
            return "Serif"
        case .monospaced:
            return "Monospaced"
        }
    }

    func font(size: CGFloat, weight: Font.Weight = .bold) -> Font {
        switch self {
        case .system:
            return .system(size: size, weight: weight)
        case .rounded:
            return .system(size: size, weight: weight, design: .rounded)
        case .serif:
            return .system(size: size, weight: weight, design: .serif)
        case .monospaced:
            return .system(size: size, weight: weight, design: .monospaced)
        }
    }
}
