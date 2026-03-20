//
//  AppUserDefaults.swift
//  dsd-swacs-staff
//
//  Created by Andy on 22/10/2025.
//

import Foundation

final class AppUserDefaults {
    static let shared = AppUserDefaults()
    private let userDefaults = UserDefaults.standard

    private init() {}

    struct UserDefaultKey {
        static let authToken = "authToken"
        static let userProfile = "userProfile"
        static let pushToken = "pushToken"
        
        static let fcmToken = "fcm_current_token"
        static let fcmTokenRegistered = "fcm_token_registered"
    }
    
    func setValue(_ value: Any?, forKey key: String) {
        userDefaults.set(value, forKey: key)
    }

    func getValue(forKey key: String) -> Any? {
        userDefaults.value(forKey: key)
    }
    
    func setCodableValue<T: Codable>(_ value: T?, forKey key: String) {
        guard let value = value else {
            userDefaults.removeObject(forKey: key)
            return
        }
        if let encoded = try? JSONEncoder().encode(value) {
            userDefaults.set(encoded, forKey: key)
        }
    }
    
    func getCodableValue<T: Codable>(_ type: T.Type, forKey key: String) -> T? {
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let decoder = JSONDecoder()
        do {
            return try decoder.decode(type, from: data)
        } catch {
            print("⚠️ Decode \(key) Fail: \(error.localizedDescription)")
            return nil
        }
    }
    
    // MARK: - Auth Properties
    var authToken: String? {
        get { userDefaults.string(forKey: UserDefaultKey.authToken) }
        set { userDefaults.set(newValue, forKey: UserDefaultKey.authToken) }
    }

    var profile: StaffLoginResponse.UserProfile? {
        get { getCodableValue(StaffLoginResponse.UserProfile.self, forKey: UserDefaultKey.userProfile) }
        set { setCodableValue(newValue, forKey: UserDefaultKey.userProfile) }
    }
    
    // MARK: - FCM Token Properties
    /// Current FCM registration token
    var fcmToken: String? {
        get { userDefaults.string(forKey: UserDefaultKey.fcmToken) }
        set { userDefaults.set(newValue, forKey: UserDefaultKey.fcmToken) }
    }
    
    /// Whether FCM token is registered with backend
    var isFcmTokenRegistered: Bool {
        get { userDefaults.bool(forKey: UserDefaultKey.fcmTokenRegistered) }
        set { userDefaults.set(newValue, forKey: UserDefaultKey.fcmTokenRegistered) }
    }
    
    // MARK: - Clear Methods
    /// Clear all auth-related data
    func clearAuthData() {
        authToken = nil
        profile = nil
    }
    
    /// Clear all FCM token data
    func clearFcmTokenData() {
        fcmToken = nil
        isFcmTokenRegistered = false
    }
    
    /// Clear all app data (use with caution)
    func clearAllData() {
        clearAuthData()
        clearFcmTokenData()
    }
}
