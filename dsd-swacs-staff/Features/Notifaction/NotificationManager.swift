//
//  NotificationManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 13/11/2025.
//

import Foundation
import SwiftUI

@MainActor
class NotificationManager: ObservableObject {

    static let shared = NotificationManager()

    @Published var unreadCount: Int = 0
    @Published var isLoading: Bool = false
    
    private init() {}
    
    
    /// 獲取未讀通知數量
    func fetchUnreadCount() async {
        // 避免重複請求
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let count = try await APIService.getUnreadNotificationCount()
            self.unreadCount = count
        } catch {
            print("❌ Failed to fetch notification count: \(error)")
            self.unreadCount = 0
        }
    }
}

