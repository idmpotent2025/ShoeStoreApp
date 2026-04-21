//
//  ProfileViewModel.swift
//  ShoeStoreApp
//
//  Created by Claude Code
//

import Foundation
import SwiftUI
import Combine

class ProfileViewModel: ObservableObject {
    @Published var authService: AuthService

    init(authService: AuthService) {
        self.authService = authService
    }

    func login() {
        authService.login { result in
            switch result {
            case .success:
                print("Login successful")
            case .failure(let error):
                print("Login failed: \(error.localizedDescription)")
            }
        }
    }

    func logout() {
        authService.logout()
    }

    func formatToken(_ token: String?, maxLength: Int = 50) -> String {
        guard let token = token else { return "Not available" }
        if token.count > maxLength {
            return String(token.prefix(maxLength)) + "..."
        }
        return token
    }
}
