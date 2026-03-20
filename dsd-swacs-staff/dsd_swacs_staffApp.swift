//
//  dsd_swacs_staffApp.swift
//  dsd-swacs-staff
//
//  Created by Andy on 31/7/2025.
//

import SwiftUI
import FirebaseCore


@main
struct dsd_swacs_staffApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var alertManager = AlertManager.shared
    @StateObject private var languageManager = AppLanguageManager.shared
    
    init() {
        if UserDefaults.standard.string(forKey: "SelectedLanguageKey") == nil {
            AppLanguageManager.shared.setLanguage(.en)
        }
    }
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(authManager)
                .environmentObject(notificationManager)
                .environmentObject(alertManager)
                .environmentObject(languageManager)
                .apiErrorAlert()
                .networkErrorAlert()
                .globalLoadingOverlay()
                .globalAlertOverlay(alertManager: alertManager)
        }
    }
}
