//
//  LoginMainViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 5/11/2025.
//

import SwiftUI

@MainActor
final class LoginViewModel: ObservableObject {
    @Published var loginName: String = ""
    @Published var loginPw: String = ""
    
    private let authManager = AuthenticationManager.shared
    
    func performLogin() async {
        do {
            let response = try await APIService.staffLogin(loginName: loginName.trimmingCharacters(in: .whitespacesAndNewlines), password: loginPw.trimmingCharacters(in: .whitespacesAndNewlines))
            authManager.loginSuccess(response: response)
        } catch {
            print("❌ Login failed: \(error)")
        }
    }
}
