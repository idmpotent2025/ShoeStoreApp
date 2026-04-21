//
//  Product.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation

enum ProductCategory: String, Codable, CaseIterable {
    case dresses
    case petFood
    case burritos
    case cpgGoods

    var displayName: String {
        switch self {
        case .dresses:
            return "Dresses"
        case .petFood:
            return "Pet Food"
        case .burritos:
            return "Burritos"
        case .cpgGoods:
            return "CPG Goods"
        }
    }
}

struct Product: Identifiable, Codable, Hashable {
    let id: String
    let name: String
    let price: Double
    let description: String
    let imageUrl: String
    let category: ProductCategory

    var formattedPrice: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: price)) ?? "$\(price)"
    }
}
