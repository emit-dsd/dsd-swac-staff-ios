//
//  TokenManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

import Foundation
import Combine

final class TokenManager {
    static let shared = TokenManager()

    var token: String? {
        UserSession.shared.token
    }

    private init() {}

    func save(access: String) {
        UserSession.shared.token = access
    }

    func clearTokens() {
        UserSession.shared.token = nil
    }

    func hasValidToken() -> Bool {
        guard let token = UserSession.shared.token else { return false }
        return !token.isEmpty
    }
}
