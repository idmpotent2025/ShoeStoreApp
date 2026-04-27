//
//  AdvancedFlowsViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine

class AdvancedFlowsViewModel: ObservableObject {
    @Published var qrCodeLogin: QRCodeLogin?
    @Published var cibaFlow: CIBAFlow?
    @Published var ssoSession: SSOSession?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let qrCodeService: QRCodeService
    private var cancellables = Set<AnyCancellable>()

    init(qrCodeService: QRCodeService) {
        self.qrCodeService = qrCodeService
    }

    // MARK: - QR Code Login

    func generateQRCode() {
        isLoading = true
        errorMessage = nil

        let sessionId = UUID().uuidString
        let expiresAt = Date().addingTimeInterval(300) // 5 minutes

        if let qrImage = qrCodeService.generateLoginQRCode(sessionId: sessionId, expiresAt: expiresAt) {
            qrCodeLogin = QRCodeLogin(
                sessionId: sessionId,
                qrCodeImage: qrImage,
                expiresAt: expiresAt,
                status: .pending
            )
        } else {
            errorMessage = "Failed to generate QR code"
        }

        isLoading = false
    }

    func simulateQRCodeScan() {
        guard var currentQR = qrCodeLogin else { return }

        currentQR.status = .scanned

        // Simulate authentication after scan
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            self?.qrCodeLogin?.status = .authenticated
        }
    }

    // MARK: - CIBA Flow

    func initiateCIBAFlow() {
        isLoading = true
        errorMessage = nil

        let authRequestId = UUID().uuidString
        cibaFlow = CIBAFlow(
            authRequestId: authRequestId,
            deviceName: "iPhone 14 Pro",
            location: "San Francisco, CA",
            timestamp: Date(),
            status: .pending
        )

        // Simulate sending push notification
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
            self?.cibaFlow?.status = .notified
            self?.isLoading = false
        }
    }

    func approveCIBARequest() {
        cibaFlow?.status = .approved
    }

    func denyCIBARequest() {
        cibaFlow?.status = .denied
    }

    // MARK: - Native2WebSSO

    /// Initiates Native-to-Web SSO flow by generating a session URL with token
    ///
    /// To use with real Auth0 authentication:
    /// 1. Inject AuthService into this ViewModel
    /// 2. Check if user is authenticated: authService.isAuthenticated
    /// 3. Use actual token: let sessionToken = authService.accessToken ?? authService.idToken
    /// 4. The webapp will validate the JWT signature using Auth0 JWKS
    func initiateNative2WebSSO() {
        isLoading = true
        errorMessage = nil

        // TODO: Replace with actual access token from AuthService
        // let sessionToken = authService.accessToken ?? authService.idToken ?? ""
        // For demo purposes, using UUID as placeholder
        let sessionToken = UUID().uuidString

        // Updated URL to match new webapp structure
        // Change this to your Vercel deployment URL in production
        let baseURL = "https://demo.identityarchitect.app" // or "http://localhost:3000" for local testing
        guard let webURL = URL(string: "\(baseURL)/flows/native2web/sso?sessionToken=\(sessionToken)") else {
            errorMessage = "Invalid URL"
            isLoading = false
            return
        }

        ssoSession = SSOSession(
            sessionToken: sessionToken,
            webPortalURL: webURL,
            createdAt: Date(),
            isActive: true
        )

        isLoading = false
    }

    func endSSOSession() {
        ssoSession?.isActive = false
    }

    // MARK: - Reset

    func reset() {
        qrCodeLogin = nil
        cibaFlow = nil
        ssoSession = nil
        errorMessage = nil
    }
}
