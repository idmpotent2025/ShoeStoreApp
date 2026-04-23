//
//  AdvancedFlowsView.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import SwiftUI

struct AdvancedFlowsView: View {
    @ObservedObject var viewModel: AdvancedFlowsViewModel
    @State private var showQRCodeSheet = false
    @State private var showCIBASheet = false
    @State private var showSSOSheet = false

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // QR Code Login
                    WorkflowCard(
                        icon: "qrcode",
                        title: "QR Code Login",
                        description: "Scan QR code to authenticate on another device",
                        action: {
                            showQRCodeSheet = true
                            viewModel.generateQRCode()
                        }
                    )

                    // CIBA Flow
                    WorkflowCard(
                        icon: "bell.badge.fill",
                        title: "CIBA Flow",
                        description: "Client-Initiated Backchannel Authentication with push notifications",
                        action: {
                            showCIBASheet = true
                            viewModel.initiateCIBAFlow()
                        }
                    )

                    // Native2WebSSO
                    WorkflowCard(
                        icon: "arrow.left.arrow.right.circle.fill",
                        title: "Native2WebSSO",
                        description: "Seamless session transfer from native app to web",
                        action: {
                            showSSOSheet = true
                            viewModel.initiateNative2WebSSO()
                        }
                    )
                }
                .padding()
            }
            .background(Color.theme.background.ignoresSafeArea())
            .navigationTitle("Multi-Channel")
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showQRCodeSheet) {
                QRCodeLoginSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showCIBASheet) {
                CIBAFlowSheet(viewModel: viewModel)
            }
            .sheet(isPresented: $showSSOSheet) {
                Native2WebSSOSheet(viewModel: viewModel)
            }
        }
    }
}

struct WorkflowCard: View {
    let icon: String
    let title: String
    let description: String
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 12) {
                Image(systemName: icon)
                    .font(.title)
                    .foregroundColor(.theme.primary)

                Text(title)
                    .font(.headline)
                    .foregroundColor(.theme.text)

                Text(description)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .lineLimit(2)

                HStack {
                    Image(systemName: "arrow.right.circle.fill")
                        .foregroundColor(.theme.accent)
                    Text("Try Now")
                        .font(.caption)
                        .fontWeight(.semibold)
                        .foregroundColor(.theme.accent)
                }
                .padding(.top, 4)
            }
            .padding()
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(Color(hex: "#E8E8E8"))
            .cornerRadius(12)
            .shadow(color: Color.black.opacity(0.05), radius: 4, x: 0, y: 2)
        }
    }
}

// MARK: - QR Code Login Sheet

struct QRCodeLoginSheet: View {
    @ObservedObject var viewModel: AdvancedFlowsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    if let qrLogin = viewModel.qrCodeLogin {
                        VStack(spacing: 16) {
                            Text("Scan to Login")
                                .font(.title2)
                                .fontWeight(.bold)

                            if let qrImage = qrLogin.qrCodeImage {
                                Image(uiImage: qrImage)
                                    .interpolation(.none)
                                    .resizable()
                                    .frame(width: 250, height: 250)
                                    .background(Color(hex: "#E8E8E8"))
                                    .cornerRadius(12)
                            }

                            VStack(spacing: 8) {
                                Text("Session ID")
                                    .font(.caption)
                                    .foregroundColor(.gray)
                                Text(qrLogin.sessionId)
                                    .font(.system(size: 10, design: .monospaced))
                                    .foregroundColor(.theme.text)
                                    .lineLimit(1)
                            }

                            StatusBadge(status: qrLogin.status)

                            if qrLogin.status == .pending {
                                Button(action: {
                                    viewModel.simulateQRCodeScan()
                                }) {
                                    Text("Simulate Scan")
                                        .font(.subheadline)
                                        .foregroundColor(.theme.accent)
                                }
                            }
                        }
                    } else {
                        ProgressView("Generating QR Code...")
                    }
                }
                .padding()
            }
            .navigationTitle("QR Code Login")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        viewModel.reset()
                    }
                }
            }
        }
    }
}

struct StatusBadge: View {
    let status: QRCodeLogin.QRCodeStatus

    var statusText: String {
        switch status {
        case .pending: return "Pending"
        case .scanned: return "Scanned"
        case .authenticated: return "Authenticated"
        case .expired: return "Expired"
        }
    }

    var statusColor: Color {
        switch status {
        case .pending: return .orange
        case .scanned: return .blue
        case .authenticated: return .green
        case .expired: return .red
        }
    }

    var body: some View {
        Text(statusText)
            .font(.caption)
            .fontWeight(.semibold)
            .foregroundColor(.white)
            .padding(.horizontal, 12)
            .padding(.vertical, 6)
            .background(statusColor)
            .cornerRadius(8)
    }
}

// MARK: - CIBA Flow Sheet

struct CIBAFlowSheet: View {
    @ObservedObject var viewModel: AdvancedFlowsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    if let cibaFlow = viewModel.cibaFlow {
                        VStack(spacing: 20) {
                            Image(systemName: "bell.badge.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.theme.primary)

                            Text("CIBA Authentication")
                                .font(.title2)
                                .fontWeight(.bold)

                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Request ID", value: cibaFlow.authRequestId)
                                InfoRow(label: "Device", value: cibaFlow.deviceName)
                                InfoRow(label: "Location", value: cibaFlow.location)
                                InfoRow(label: "Status", value: cibaFlow.statusDescription)
                            }
                            .padding()
                            .background(Color(hex: "#E8E8E8"))
                            .cornerRadius(12)

                            if cibaFlow.status == .notified {
                                VStack(spacing: 12) {
                                    Button(action: {
                                        viewModel.approveCIBARequest()
                                    }) {
                                        HStack {
                                            Image(systemName: "checkmark.circle.fill")
                                            Text("Approve Request")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }

                                    Button(action: {
                                        viewModel.denyCIBARequest()
                                    }) {
                                        HStack {
                                            Image(systemName: "xmark.circle.fill")
                                            Text("Deny Request")
                                                .fontWeight(.semibold)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.red)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                    }
                                }
                            } else if cibaFlow.status == .approved {
                                HStack {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.green)
                                    Text("Authentication Approved!")
                                        .foregroundColor(.green)
                                        .fontWeight(.semibold)
                                }
                                .padding()
                                .background(Color.green.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                    } else {
                        ProgressView("Initiating CIBA flow...")
                    }
                }
                .padding()
            }
            .navigationTitle("CIBA Flow")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        viewModel.reset()
                    }
                }
            }
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.caption)
                .foregroundColor(.gray)
            Spacer()
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.theme.text)
                .lineLimit(1)
        }
    }
}

// MARK: - Native2WebSSO Sheet

struct Native2WebSSOSheet: View {
    @ObservedObject var viewModel: AdvancedFlowsViewModel
    @Environment(\.dismiss) var dismiss

    var body: some View {
        NavigationView {
            ZStack {
                Color.theme.background.edgesIgnoringSafeArea(.all)

                VStack(spacing: 24) {
                    if let ssoSession = viewModel.ssoSession {
                        VStack(spacing: 20) {
                            Image(systemName: "arrow.left.arrow.right.circle.fill")
                                .resizable()
                                .frame(width: 60, height: 60)
                                .foregroundColor(.theme.primary)

                            Text("Native2Web SSO")
                                .font(.title2)
                                .fontWeight(.bold)

                            Text("Seamlessly transfer your authenticated session from this native app to the web portal")
                                .font(.subheadline)
                                .foregroundColor(.gray)
                                .multilineTextAlignment(.center)

                            VStack(alignment: .leading, spacing: 12) {
                                InfoRow(label: "Session Token", value: String(ssoSession.sessionToken.prefix(20)) + "...")
                                InfoRow(label: "Portal URL", value: ssoSession.webPortalURL.host ?? "")
                                InfoRow(label: "Status", value: ssoSession.isActive ? "Active" : "Inactive")
                            }
                            .padding()
                            .background(Color(hex: "#E8E8E8"))
                            .cornerRadius(12)

                            if ssoSession.isActive {
                                Button(action: {
                                    // In a real implementation, this would open ASWebAuthenticationSession
                                    viewModel.endSSOSession()
                                }) {
                                    HStack {
                                        Image(systemName: "safari.fill")
                                        Text("Open Web Portal with SSO")
                                            .fontWeight(.semibold)
                                    }
                                    .frame(maxWidth: .infinity)
                                    .padding()
                                    .background(Color.theme.accent)
                                    .foregroundColor(.white)
                                    .cornerRadius(12)
                                }
                            } else {
                                Text("Session ended")
                                    .foregroundColor(.gray)
                            }
                        }
                    } else {
                        ProgressView("Initiating SSO session...")
                    }
                }
                .padding()
            }
            .navigationTitle("Native2Web SSO")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                        viewModel.reset()
                    }
                }
            }
        }
    }
}
