//
//  FCMTokenManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 11/11/2025.
//

import Foundation
import FirebaseMessaging

/// Manages FCM Token registration, deregistration, and updates
/// Follows Firebase Cloud Messaging best practices for token management
@MainActor
class FCMTokenManager: ObservableObject {
    static let shared = FCMTokenManager()
    
    @Published var currentToken: String?
    @Published var isTokenRegistered: Bool = false
    
    private let defaults = AppUserDefaults.shared
    
    private init() {
        // Restore state from AppUserDefaults
        self.currentToken = defaults.fcmToken
        self.isTokenRegistered = defaults.isFcmTokenRegistered
    }
    
    /// Fetch current FCM token from Firebase Messaging
    /// - Returns: The current FCM registration token, or nil if unavailable
    func fetchCurrentToken() async -> String? {
        return await withCheckedContinuation { continuation in
            Messaging.messaging().token { token, error in
                if let error = error {
                    print("❌ Error fetching FCM token: \(error)")
                    continuation.resume(returning: nil)
                } else if let token = token {
                    print("✅ FCM Token fetched: \(token)")
                    Task { @MainActor in
                        self.currentToken = token
                        self.saveTokenLocally(token)
                    }
                    continuation.resume(returning: token)
                } else {
                    continuation.resume(returning: nil)
                }
            }
        }
    }
    
    /// Register FCM token to backend server
    /// Should be called after successful login
    func registerToken() async {
        guard let token = await fetchCurrentToken() else {
            print("❌ No FCM token available to register")
            return
        }
        
        do {
            // API returns empty response, just check for success (no throw = success)
            try await APIService.registerMobileToken(token)
            
            print("✅ FCM Token registered successfully")
            self.isTokenRegistered = true
            self.saveRegistrationStatus(true)
        } catch {
            print("❌ Error registering FCM token: \(error)")
            // Token not registered, keep status as false
        }
    }
    
    /// Deregister FCM token from backend server
    /// Should be called before logout or when user opts out of notifications
    func deregisterToken() async {
        // Check if we have a token to deregister
        guard currentToken != nil || defaults.fcmToken != nil else {
            print("⚠️ No token to deregister")
            return
        }
        
        do {
            // API returns empty response and doesn't require token parameter
            try await APIService.deregisterMobileToken()
            
            print("✅ FCM Token deregistered successfully")
            self.isTokenRegistered = false
            self.saveRegistrationStatus(false)
            self.clearToken()
        } catch {
            print("❌ Error deregistering FCM token: \(error)")
            // Even if API call fails, clear local token to prevent stale data
            self.clearToken()
        }
    }
    
    /// Handle FCM token refresh events
    /// Called from AppDelegate when Firebase generates a new token
    /// This occurs when:
    /// - App is launched for the first time
    /// - Token is invalidated or expired
    /// - App is reinstalled or data is cleared
    /// - Parameters:
    ///   - newToken: The newly generated FCM registration token
    func handleTokenRefresh(_ newToken: String) async {
        print("🔄 FCM Token refreshed: \(newToken)")
        
        // If user is logged in and token was previously registered, auto-register new token
        if AuthenticationManager.shared.isLoggedIn && isTokenRegistered {
            // First, deregister old token if it exists and is different
            if let oldToken = currentToken, oldToken != newToken {
                do {
                    try await APIService.deregisterMobileToken()
                    print("✅ Old token deregistered")
                } catch {
                    print("⚠️ Failed to deregister old token: \(error)")
                }
            }
            
            // Register new token
            currentToken = newToken
            saveTokenLocally(newToken)
            await registerToken()
        } else {
            // Save token locally, will register after user logs in
            currentToken = newToken
            saveTokenLocally(newToken)
        }
    }
    
    // MARK: - Private Methods
    
    /// Save token to local storage using AppUserDefaults
    /// - Parameter token: The FCM token to save
    private func saveTokenLocally(_ token: String) {
        defaults.fcmToken = token
    }
    
    /// Update token registration status in local storage
    /// - Parameter status: Whether the token is registered with backend
    private func saveRegistrationStatus(_ status: Bool) {
        defaults.isFcmTokenRegistered = status
    }
    
    /// Clear all token data from memory and local storage
    /// Called during logout or token deregistration
    private func clearToken() {
        currentToken = nil
        defaults.clearFcmTokenData()
    }
}
