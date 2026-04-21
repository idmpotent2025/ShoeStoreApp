//
//  QRCodeService.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import Combine
import CoreImage
import UIKit
import AVFoundation

class QRCodeService: NSObject, ObservableObject {
    @Published var generatedQRCode: UIImage?
    @Published var scannedCode: String?
    @Published var isScanning = false
    @Published var errorMessage: String?

    // Generate QR code from string
    func generateQRCode(from string: String) -> UIImage? {
        let data = string.data(using: .utf8)

        guard let filter = CIFilter(name: "CIQRCodeGenerator") else {
            errorMessage = "Failed to create QR code filter"
            return nil
        }

        filter.setValue(data, forKey: "inputMessage")
        filter.setValue("H", forKey: "inputCorrectionLevel")

        guard let outputImage = filter.outputImage else {
            errorMessage = "Failed to generate QR code"
            return nil
        }

        // Scale up the QR code for better quality
        let transform = CGAffineTransform(scaleX: 10, y: 10)
        let scaledImage = outputImage.transformed(by: transform)

        let context = CIContext()
        guard let cgImage = context.createCGImage(scaledImage, from: scaledImage.extent) else {
            errorMessage = "Failed to create QR code image"
            return nil
        }

        let qrImage = UIImage(cgImage: cgImage)
        generatedQRCode = qrImage
        return qrImage
    }

    // Generate QR code with embedded data
    func generateLoginQRCode(sessionId: String, expiresAt: Date) -> UIImage? {
        let loginData = [
            "sessionId": sessionId,
            "expiresAt": ISO8601DateFormatter().string(from: expiresAt),
            "type": "login"
        ]

        guard let jsonData = try? JSONSerialization.data(withJSONObject: loginData),
              let jsonString = String(data: jsonData, encoding: .utf8) else {
            errorMessage = "Failed to encode QR data"
            return nil
        }

        return generateQRCode(from: jsonString)
    }

    // Simulate QR code scan (for demo purposes)
    func simulateQRCodeScan(completion: @escaping (String) -> Void) {
        isScanning = true

        // Simulate scanning delay
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) { [weak self] in
            let mockSessionId = UUID().uuidString
            self?.scannedCode = mockSessionId
            self?.isScanning = false
            completion(mockSessionId)
        }
    }

    func reset() {
        generatedQRCode = nil
        scannedCode = nil
        isScanning = false
        errorMessage = nil
    }
}

// MARK: - AVCaptureMetadataOutputObjectsDelegate

extension QRCodeService: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput,
                       didOutput metadataObjects: [AVMetadataObject],
                       from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first as? AVMetadataMachineReadableCodeObject,
           let stringValue = metadataObject.stringValue {
            scannedCode = stringValue
            isScanning = false
        }
    }
}
