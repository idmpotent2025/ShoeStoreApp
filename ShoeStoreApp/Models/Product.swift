//
//  Product.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation

enum ProductCategory: String, Codable, CaseIterable {
    case dresses = "Dresses"
    case petFood = "Pet Food"
    case burritos = "Burritos"
    case cpgGoods = "CPG Goods"

    var displayName: String {
        return self.rawValue
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
