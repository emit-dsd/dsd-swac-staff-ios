//
//  SettingLanguageSelector.swift
//  dsd-swacs-staff
//
//  Created by Andy on 19/3/2026.
//
import SwiftUI

struct SettingLanguageSelector: View {
    @EnvironmentObject var languageManager: AppLanguageManager

    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                onSelect(.en)
            }) {
                Text("language_label_english".localized())
                    .appFont(.robotoBold, size: 14)
                    .foregroundColor(languageManager.currentLanguage == .en ? .Neutral200 : .Primary600)
//                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background(languageManager.currentLanguage == .en ? Color.Primary600 : Color.Neutral200)
            }
            .cornerRadius(100, corners: [.topLeft, .bottomLeft])
            .buttonStyle(PlainButtonStyle())
            
            Button(action: {
                onSelect(.zh_Hant)
            }) {
                Text("language_label_traditional_chinese".localized())
                    .appFont(.robotoBold, size: 14)
                    .foregroundColor( languageManager.currentLanguage == .zh_Hant ? .Neutral200 : .Primary600)
//                    .frame(width: 60)
                    .padding(.vertical, 8)
                    .padding(.horizontal, 16)
                    .background( languageManager.currentLanguage == .zh_Hant ? Color.Primary600 : Color.Neutral200)
            }
            .cornerRadius(100, corners: [.topRight, .bottomRight])
            .buttonStyle(PlainButtonStyle())
        }
    }

    private func onSelect(_ lang: AppLanguage) {
        let old = languageManager.currentLanguage
        guard old != lang else { return }

        languageManager.setLanguage(lang)

        Task {
            do {
                try await APIService.setLanguage(lang.apiCode)
                print("✅ [Lang-Setting] setLanguage(\(lang.apiCode)) success")
            } catch {
                print("❌ [Lang-Setting] setLanguage(\(lang.apiCode)) failed: \(error)")
            }
        }
    }
}
