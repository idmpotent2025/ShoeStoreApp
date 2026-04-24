//
//  PushNotificationService.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import UserNotifications
import UIKit
import Combine

@MainActor
class PushNotificationService: NSObject, ObservableObject {
    static let shared = PushNotificationService()

    @Published var deviceToken: String?
    @Published var currentCIBARequest: CIBAPushRequest?
    @Published var showCIBAApproval = false

    private let auth0Domain = "digitalkiosk.cic-demo-platform.auth0app.com"
    private var cancellables = Set<AnyCancellable>()

    private override init() {
        super.init()
    }

    // MARK: - Registration

    func registerForPushNotifications() {
        UNUserNotificationCenter.current().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            if let error = error {
                print("❌ Push notification authorization error: \(error.localizedDescription)")
                return
            }

            guard granted else {
                print("⚠️ Push notification permission denied")
                return
            }

            print("✅ Push notification permission granted")

            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }

    func handleDeviceToken(_ deviceToken: Data) {
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        self.deviceToken = token

        print("📱 Device Token: \(token)")

        // Register device token with Auth0
        Task {
            await registerDeviceWithAuth0(token: token)
        }
    }

    func handlePushNotificationError(_ error: Error) {
        print("❌ Failed to register for push notifications: \(error.localizedDescription)")
    }

    // MARK: - Auth0 Device Registration

    private func registerDeviceWithAuth0(token: String) async {
        // In production, you would call Auth0 Guardian enrollment API
        // POST https://{domain}/api/v2/guardian/enrollments

        guard let url = URL(string: "https://\(auth0Domain)/api/v2/guardian/enrollments") else {
            print("❌ Invalid Auth0 enrollment URL")
            return
        }

        // Get access token from AuthService
        // This is a simplified version - in production, you need a management API token

        let enrollmentData: [String: Any] = [
            "type": "pn",  // Push notification
            "name": UIDevice.current.name,
            "identifier": token,
            "phone_number": NSNull()
        ]

        do {
            var request = URLRequest(url: url)
            request.httpMethod = "POST"
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            // request.setValue("Bearer \(managementToken)", forHTTPHeaderField: "Authorization")
            request.httpBody = try JSONSerialization.data(withJSONObject: enrollmentData)

            print("📤 Registering device with Auth0 Guardian...")
            print("Device Token: \(token)")
            print("Device Name: \(UIDevice.current.name)")

            // For demo purposes, we'll just log this
            // In production, uncomment the actual API call:
            // let (data, response) = try await URLSession.shared.data(for: request)
            // Handle response...

        } catch {
            print("❌ Failed to register device with Auth0: \(error.localizedDescription)")
        }
    }

    // MARK: - CIBA Push Handling

    func handleCIBAPush(userInfo: [AnyHashable: Any]) {
        print("📨 Received CIBA push notification")
        print("Payload: \(userInfo)")

        do {
            _ = try JSONSerialization.data(withJSONObject: userInfo)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601

            // Try to decode CIBA request from different possible structures
            if let cibaData = userInfo["ciba_request"] as? [String: Any] {
                let cibaJsonData = try JSONSerialization.data(withJSONObject: cibaData)
                let cibaRequest = try decoder.decode(CIBAPushRequest.self, from: cibaJsonData)

                DispatchQueue.main.async {
                    self.currentCIBARequest = cibaRequest
                    self.showCIBAApproval = true
                }
            } else {
                // Fallback: Create a request from basic notification data
                let authRequestId = userInfo["auth_req_id"] as? String ?? UUID().uuidString
                let message = userInfo["message"] as? String
                let location = userInfo["location"] as? String

                let cibaRequest = CIBAPushRequest(
                    authRequestId: authRequestId,
                    message: message,
                    location: location,
                    deviceName: userInfo["device_name"] as? String,
                    ipAddress: userInfo["ip_address"] as? String,
                    timestamp: Date(),
                    expiresAt: Date().addingTimeInterval(300), // 5 minutes
                    scope: userInfo["scope"] as? String
                )

                DispatchQueue.main.async {
                    self.currentCIBARequest = cibaRequest
                    self.showCIBAApproval = true
                }
            }

        } catch {
            print("❌ Failed to parse CIBA request: \(error.localizedDescription)")
        }
    }

    // MARK: - CIBA Response

    func approveCIBARequest(_ request: CIBAPushRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            await sendCIBAResponse(request: request, approved: true, completion: completion)
        }
    }

    func denyCIBARequest(_ request: CIBAPushRequest, completion: @escaping (Result<Void, Error>) -> Void) {
        Task {
            await sendCIBAResponse(request: request, approved: false, completion: completion)
        }
    }

    private func sendCIBAResponse(request: CIBAPushRequest, approved: Bool, completion: @escaping (Result<Void, Error>) -> Void) async {
        // Auth0 CIBA response endpoint
        // POST https://{domain}/bc-authorize/callback

        guard let url = URL(string: "https://\(auth0Domain)/bc-authorize/callback") else {
            completion(.failure(NSError(domain: "PushNotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid URL"])))
            return
        }

        let responseData: [String: Any] = [
            "auth_req_id": request.authRequestId,
            "action": approved ? "approved" : "rejected",
            "timestamp": ISO8601DateFormatter().string(from: Date())
        ]

        do {
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            urlRequest.httpBody = try JSONSerialization.data(withJSONObject: responseData)

            print("📤 Sending CIBA response to Auth0...")
            print("Auth Request ID: \(request.authRequestId)")
            print("Action: \(approved ? "APPROVED" : "DENIED")")

            let (data, response) = try await URLSession.shared.data(for: urlRequest)

            guard let httpResponse = response as? HTTPURLResponse else {
                throw NSError(domain: "PushNotificationService", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid response"])
            }

            if (200...299).contains(httpResponse.statusCode) {
                print("✅ CIBA response sent successfully")
                DispatchQueue.main.async {
                    self.currentCIBARequest = nil
                    self.showCIBAApproval = false
                }
                completion(.success(()))
            } else {
                let errorMessage = String(data: data, encoding: .utf8) ?? "Unknown error"
                print("❌ CIBA response failed: \(httpResponse.statusCode) - \(errorMessage)")
                throw NSError(domain: "PushNotificationService", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: errorMessage])
            }

        } catch {
            print("❌ Failed to send CIBA response: \(error.localizedDescription)")
            completion(.failure(error))
        }
    }

    func clearCurrentRequest() {
        currentCIBARequest = nil
        showCIBAApproval = false
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension PushNotificationService: UNUserNotificationCenterDelegate {
    // Handle notification when app is in foreground
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let userInfo = notification.request.content.userInfo

        // Check if this is a CIBA push
        if userInfo["ciba_request"] != nil || userInfo["auth_req_id"] != nil {
            handleCIBAPush(userInfo: userInfo)
            completionHandler([.banner, .sound, .badge])
        } else {
            completionHandler([.banner, .sound, .badge])
        }
    }

    // Handle notification tap
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo

        // Check if this is a CIBA push
        if userInfo["ciba_request"] != nil || userInfo["auth_req_id"] != nil {
            handleCIBAPush(userInfo: userInfo)
        }

        completionHandler()
    }
}
