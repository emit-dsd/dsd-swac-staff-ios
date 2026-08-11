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
    
    @Environment(\.scenePhase) private var scenePhase
    
    @StateObject private var authManager = AuthenticationManager.shared
    @StateObject private var notificationManager = NotificationManager.shared
    @StateObject private var alertManager = AlertManager.shared
    @StateObject private var languageManager = AppLanguageManager.shared
    @StateObject private var versionChecker = VersionChecker.shared
    
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
                .environmentObject(versionChecker)
                .apiErrorAlert()
                .networkErrorAlert()
                .globalLoadingOverlay()
                .globalAlertOverlay(alertManager: alertManager)
                .task {
                    await versionChecker.checkUpdate()
                }
        }
        .onChange(of: scenePhase) { oldPhase, newPhase in
            print("🌗 [App] ScenePhase change: \(oldPhase) -> \(newPhase)")
            if newPhase == .active {
                print("🏠 [App] Became active → check version")
                Task {
                    await versionChecker.checkUpdate()
                }
            }
        }
    }
}
