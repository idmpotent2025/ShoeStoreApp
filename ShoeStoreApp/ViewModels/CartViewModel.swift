//
//  CartViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class CartViewModel: ObservableObject {
    @Published var cartItems: [CartItem] = []
    @Published var orderHistory: [Order] = []

    var totalItems: Int {
        cartItems.reduce(0) { $0 + $1.quantity }
    }

    var subtotal: Double {
        cartItems.reduce(0) { $0 + $1.subtotal }
    }

    var formattedSubtotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: subtotal)) ?? "$\(subtotal)"
    }

    init() {
        loadMockOrderHistory()
    }

    func addToCart(product: Product) {
        if let index = cartItems.firstIndex(where: { $0.product.id == product.id }) {
            cartItems[index].quantity += 1
        } else {
            let newItem = CartItem(product: product, quantity: 1)
            cartItems.append(newItem)
        }
    }

    func removeFromCart(item: CartItem) {
        cartItems.removeAll { $0.id == item.id }
    }

    func updateQuantity(item: CartItem, newQuantity: Int) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if newQuantity > 0 {
                cartItems[index].quantity = newQuantity
            } else {
                cartItems.remove(at: index)
            }
        }
    }

    func incrementQuantity(item: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            cartItems[index].quantity += 1
        }
    }

    func decrementQuantity(item: CartItem) {
        if let index = cartItems.firstIndex(where: { $0.id == item.id }) {
            if cartItems[index].quantity > 1 {
                cartItems[index].quantity -= 1
            } else {
                cartItems.remove(at: index)
            }
        }
    }

    func checkout() {
        let newOrder = Order(
            id: UUID(),
            date: Date(),
            items: cartItems,
            total: subtotal,
            status: .pending
        )
        orderHistory.insert(newOrder, at: 0)
        cartItems.removeAll()
    }

    private func loadMockOrderHistory() {
        // Create some mock order history
        let mockProduct1 = Product(id: "mock1", name: "Previous Order Item 1", price: 99.99, description: "Mock item", imageUrl: "", category: .dresses)
        let mockProduct2 = Product(id: "mock2", name: "Previous Order Item 2", price: 149.99, description: "Mock item", imageUrl: "", category: .dresses)

        let mockOrder1 = Order(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 7), // 7 days ago
            items: [
                CartItem(product: mockProduct1, quantity: 1),
                CartItem(product: mockProduct2, quantity: 2)
            ],
            total: 399.97,
            status: .delivered
        )

        let mockOrder2 = Order(
            id: UUID(),
            date: Date().addingTimeInterval(-86400 * 14), // 14 days ago
            items: [
                CartItem(product: mockProduct1, quantity: 3)
            ],
            total: 299.97,
            status: .delivered
        )

        orderHistory = [mockOrder1, mockOrder2]
    }
}
