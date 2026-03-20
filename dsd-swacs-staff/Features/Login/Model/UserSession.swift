//
//  UserSession.swift
//  dsd-swacs-staff
//
//  Created by Andy on 22/10/2025.
//
import Foundation

final class UserSession: ObservableObject {
    static let shared = UserSession()

    @Published var token: String?
    @Published var profile: StaffLoginResponse.UserProfile?

    private init() {
        token = AppUserDefaults.shared.authToken
        profile = AppUserDefaults.shared.profile
    }

    func update(with response: StaffLoginResponse) {
        token = response.token
        profile = response.profile
        
        AppUserDefaults.shared.authToken = response.token
        AppUserDefaults.shared.profile = response.profile
    }

    func clear() {
        token = nil
        profile = nil
        
        AppUserDefaults.shared.clearAuthData()
    }
}
