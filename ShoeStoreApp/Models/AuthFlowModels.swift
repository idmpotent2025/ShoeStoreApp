//
//  AuthFlowModels.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import UIKit

// MARK: - QR Code Login

struct QRCodeLogin: Identifiable {
    let id = UUID()
    let sessionId: String
    let qrCodeImage: UIImage?
    let expiresAt: Date
    var status: QRCodeStatus

    enum QRCodeStatus {
        case pending
        case scanned
        case authenticated
        case expired
    }

    var isExpired: Bool {
        return Date() > expiresAt
    }
}

// MARK: - CIBA Flow

struct CIBAFlow: Identifiable {
    let id = UUID()
    let authRequestId: String
    let deviceName: String
    let location: String
    let timestamp: Date
    var status: CIBAStatus

    enum CIBAStatus {
        case pending
        case notified
        case approved
        case denied
        case expired
    }

    var statusDescription: String {
        switch status {
        case .pending:
            return "Waiting for authentication request..."
        case .notified:
            return "Push notification sent to device"
        case .approved:
            return "Authentication approved"
        case .denied:
            return "Authentication denied"
        case .expired:
            return "Request expired"
        }
    }
}

// MARK: - Authentication Method

struct AuthenticationMethod: Identifiable {
    let id = UUID()
    let name: String
    let icon: String
    let description: String
    let isRealImplementation: Bool
    let action: () -> Void

    static func == (lhs: AuthenticationMethod, rhs: AuthenticationMethod) -> Bool {
        return lhs.id == rhs.id
    }
}

// MARK: - SSO Session

struct SSOSession: Identifiable {
    let id = UUID()
    let sessionToken: String
    let webPortalURL: URL
    let createdAt: Date
    var isActive: Bool

    var expiresAt: Date {
        return createdAt.addingTimeInterval(3600) // 1 hour
    }

    var isExpired: Bool {
        return Date() > expiresAt
    }
}
