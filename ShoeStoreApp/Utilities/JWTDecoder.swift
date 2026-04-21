//
//  JWTDecoder.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation

struct JWTDecoder {
    static func decode(_ jwt: String) -> [String: Any]? {
        let segments = jwt.components(separatedBy: ".")
        guard segments.count > 1 else {
            return nil
        }

        // Get the payload (second segment)
        let payloadSegment = segments[1]

        // Add padding if needed
        var base64 = payloadSegment
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")

        let paddingLength = 4 - base64.count % 4
        if paddingLength < 4 {
            base64.append(contentsOf: String(repeating: "=", count: paddingLength))
        }

        // Decode base64
        guard let data = Data(base64Encoded: base64),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            return nil
        }

        return json
    }

    static func extractClaims(from jwt: String) -> TokenClaims? {
        guard let payload = decode(jwt) else {
            return nil
        }

        return TokenClaims(
            subject: payload["sub"] as? String,
            issuer: payload["iss"] as? String,
            audience: payload["aud"] as? String,
            expiresAt: payload["exp"] as? TimeInterval,
            issuedAt: payload["iat"] as? TimeInterval,
            email: payload["email"] as? String,
            emailVerified: payload["email_verified"] as? Bool,
            name: payload["name"] as? String,
            nickname: payload["nickname"] as? String,
            picture: payload["picture"] as? String,
            updatedAt: payload["updated_at"] as? String
        )
    }

    static func formatTokenForDisplay(_ token: String, maxLength: Int = 100) -> String {
        if token.count <= maxLength {
            return token
        }
        let start = token.prefix(maxLength / 2)
        let end = token.suffix(maxLength / 2)
        return "\(start)...\(end)"
    }

    static func tokenExpirationDate(from jwt: String) -> Date? {
        guard let payload = decode(jwt),
              let exp = payload["exp"] as? TimeInterval else {
            return nil
        }
        return Date(timeIntervalSince1970: exp)
    }

    static func isTokenExpired(_ jwt: String) -> Bool {
        guard let expirationDate = tokenExpirationDate(from: jwt) else {
            return true
        }
        return expirationDate < Date()
    }
}

// MARK: - Token Claims Model

struct TokenClaims {
    let subject: String?
    let issuer: String?
    let audience: String?
    let expiresAt: TimeInterval?
    let issuedAt: TimeInterval?
    let email: String?
    let emailVerified: Bool?
    let name: String?
    let nickname: String?
    let picture: String?
    let updatedAt: String?

    var expirationDate: Date? {
        guard let exp = expiresAt else { return nil }
        return Date(timeIntervalSince1970: exp)
    }

    var issuedAtDate: Date? {
        guard let iat = issuedAt else { return nil }
        return Date(timeIntervalSince1970: iat)
    }

    var isExpired: Bool {
        guard let expDate = expirationDate else { return true }
        return expDate < Date()
    }

    var timeUntilExpiration: TimeInterval? {
        guard let expDate = expirationDate else { return nil }
        return expDate.timeIntervalSince(Date())
    }
}
