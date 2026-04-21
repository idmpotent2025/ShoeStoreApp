//
//  Order.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation

struct Order: Identifiable, Codable {
    let id: UUID
    let date: Date
    let items: [CartItem]
    let total: Double
    let status: OrderStatus

    enum OrderStatus: String, Codable {
        case pending = "Pending"
        case processing = "Processing"
        case shipped = "Shipped"
        case delivered = "Delivered"
        case cancelled = "Cancelled"
    }

    var formattedTotal: String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        return formatter.string(from: NSNumber(value: total)) ?? "$\(total)"
    }

    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
}
