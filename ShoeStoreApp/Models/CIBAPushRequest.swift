//
//  CIBAPushRequest.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation

struct CIBAPushRequest: Codable {
    let authRequestId: String
    let message: String?
    let location: String?
    let deviceName: String?
    let ipAddress: String?
    let timestamp: Date
    let expiresAt: Date
    let scope: String?

    enum CodingKeys: String, CodingKey {
        case authRequestId = "auth_req_id"
        case message
        case location
        case deviceName = "device_name"
        case ipAddress = "ip_address"
        case timestamp
        case expiresAt = "expires_at"
        case scope
    }

    var isExpired: Bool {
        return Date() > expiresAt
    }

    var timeRemaining: TimeInterval {
        return expiresAt.timeIntervalSinceNow
    }
}

struct CIBAPushPayload: Codable {
    let aps: APSPayload
    let cibaRequest: CIBAPushRequest

    enum CodingKeys: String, CodingKey {
        case aps
        case cibaRequest = "ciba_request"
    }
}

struct APSPayload: Codable {
    let alert: AlertPayload
    let sound: String?
    let badge: Int?
    let category: String?

    struct AlertPayload: Codable {
        let title: String
        let body: String
        let subtitle: String?
    }
}
