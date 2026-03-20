//
//  AuthenticationManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import Foundation
import SwiftUI

/// Manager for handling authentication state changes
@MainActor
class AuthenticationManager: ObservableObject {
    static let shared = AuthenticationManager()
    
    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    
    private let fcmManager = FCMTokenManager.shared
    
    private init() {
        // Check if user has valid token on init
        self.isLoggedIn = UserSession.shared.token != nil
    }

    /// Login success (called after API login)
    func loginSuccess(response: StaffLoginResponse) {
        print("ℹ️ [Auth] Login response language: \(String(describing: response.profile.language))")
        
        UserSession.shared.update(with: response)
      
        isLoggedIn = true
        APIManager.reset401State()
        
        //login success register FCM Token
        Task {
            await fcmManager.registerToken()
        }
        
        syncLanguageAfterLogin()
    }
    
    private func syncLanguageAfterLogin() {
        let currentAppLang = AppLanguageManager.shared.currentLanguage
        let code = currentAppLang.apiCode

        print("🌐 [Lang] Sync language after login using device selection: \(currentAppLang) -> code \(code)")
        print("🌐 [Lang] Calling /api/Home/SetLanguage with code \(code)")

        Task {
            do {
                try await APIService.setLanguage(code)
                print("✅ [Lang] SetLanguage(\(code)) success after login")
            } catch {
                print("❌ [Lang] SetLanguage(\(code)) failed after login: \(error)")
            }
        }
    }
    
    /// Manual logout (clear token and update login state)
    func logout() async {
        await fcmManager.deregisterToken()
        
        UserSession.shared.clear()
        isLoggedIn = false
    }
    
    /// Force logout user (clear token and update login state and FCMTokenManager and AppUserDefaults)
    func forceLogout() {
        UserSession.shared.clear()
        
        FCMTokenManager.shared.isTokenRegistered = false
        FCMTokenManager.shared.currentToken = nil
        AppUserDefaults.shared.clearFcmTokenData()
        AppUserDefaults.shared.isFcmTokenRegistered = false
        
        isLoggedIn = false
    }
}
