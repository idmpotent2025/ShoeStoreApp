//
//  CartItem.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation

struct CartItem: Identifiable, Codable {
    let id: UUID
    let product: Product
    var quantity: Int

    var subtotal: Double {
        product.price * Double(quantity)
    }

    init(product: Product, quantity: Int = 1) {
        self.id = UUID()
        self.product = product
        self.quantity = quantity
    }
}
