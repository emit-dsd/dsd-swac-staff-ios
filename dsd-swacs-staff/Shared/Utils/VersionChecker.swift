//
//  VersionChecker.swift
//  dsd-swacs-staff
//
//  Created by Andy on 23/3/2026.
//

import Foundation
import SwiftUI

@MainActor
class VersionChecker: ObservableObject {
    static let shared = VersionChecker()
    
    @Published var releaseNotes: ReleaseNotes?
    private let appTypeId = 1  // iOS_Staff
    private var isChecking = false

    private init() {
        print("🔧 [VersionChecker] Initialized (AppType: \(appTypeId))")
    }

    var currentVersion: String {
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "1.0.0"
        print("📱 [VersionChecker] Current version: \(version)")
        return version
    }

    func checkUpdate() async {
        print("🔍 [VersionChecker] Starting version check (isChecking: \(isChecking))")

        guard !isChecking else {
            print("⏳ [VersionChecker] Already checking, skipped")
            return
        }

        isChecking = true
        print("🚀 [VersionChecker] Executing API check...")

        defer {
            Task { @MainActor in
                self.isChecking = false
                print("✅ [VersionChecker] Version check completed")
            }
        }

        do {
            UserDefaults.standard.set(Date(), forKey: "LastVersionCheckTime")
            print("💾 [VersionChecker] Check time saved: \(Date())")

            let notes = try await APIService.getReleaseNotes(appTypeId: appTypeId)
            releaseNotes = notes
            print("📥 [VersionChecker] API success: \(notes.version)")

            let currentVer = currentVersion
            let serverVer = notes.version
            let needsUpdate = isVersionNewer(serverVersion: serverVer, currentVersion: currentVer)

            print("⚖️ [VersionChecker] \(serverVer) vs \(currentVer) = \(needsUpdate ? "Update needed" : "Up to date")")

            if needsUpdate {
                showUpdateAlert(notes: notes)
            }

        } catch {
            print("❌ [VersionChecker] API failed: \(error.localizedDescription)")
        }
    }

    public func isVersionNewer(serverVersion: String, currentVersion: String) -> Bool {
        let serverNumbers = parseVersionNumbers(serverVersion)
        let currentNumbers = parseVersionNumbers(currentVersion)

        let maxLength = max(serverNumbers.count, currentNumbers.count)
        for i in 0..<maxLength {
            let s = serverNumbers[safe: i] ?? 0
            let c = currentNumbers[safe: i] ?? 0

            if s > c { return true }
            if s < c { return false }
        }
        return false
    }

    private func parseVersionNumbers(_ version: String) -> [Int] {
        version
            .components(separatedBy: ".")
            .compactMap { Int($0.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789").inverted)) }
    }

    private func showUpdateAlert(notes: ReleaseNotes) {
        if AlertManager.shared.isShowing {
            return
        }
        
        let langManager = AppLanguageManager.shared
        let isEnglish = langManager.currentLanguage == .en
        let message = isEnglish ? notes.summaryEn : notes.summaryTc
        
        AlertManager.shared.show(
            title: "general_alertTitle_version_update".localized(),
            message: message,
            buttons: [
                CommonButtonModel(
                    title: "general_update".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    textColor: .white,
                    backgroundColor: .red,
                    action: {
                        if let safariUrl = URL(string: notes.url) {
                            UIApplication.shared.open(safariUrl)
                        } else {
                            print("❌ [VersionChecker] Invalid update URL: \(notes.url)")
                        }
                    }
                )
            ],
            autoCloseButtons: false
        )
        print("🚨 [VersionChecker] Alert via AlertManager (from checkUpdate)")
    }
}


extension Date {
    var timeAgo: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .full
        return formatter.localizedString(for: self, relativeTo: Date())
    }
}

extension Array {
    subscript(safe index: Int) -> Element? {
        indices.contains(index) ? self[index] : nil
    }
}
