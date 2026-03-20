//
//  AppLanguageManager.strings
//  dsd-swacs-staff
//
//  Created by Andy on 13/8/2025.
//  


import Foundation
import Combine
import Localize_Swift

enum AppLanguage: String, CaseIterable, Equatable {
    case en = "en"
    case zh_Hant = "zh-Hant"
    
    var displayName: String {
        switch self {
        case .en: return "English"
        case .zh_Hant: return "中文"
        }
    }
    
    /// Mapping to backend code: 1 = EN, 2 = 繁中, 3 = 簡中
    var apiCode: Int {
        switch self {
        case .en:      return 1
        case .zh_Hant: return 2
        // case .zh_Hans: return 3
        }
    }

    init(apiCode: Int) {
        switch apiCode {
        case 1: self = .en
        case 2: self = .zh_Hant
        // case 3: self = .zh_Hans
        default: self = .en
        }
    }
}

@MainActor
final class AppLanguageManager: ObservableObject {
    static let shared = AppLanguageManager()
    
    @Published private(set) var currentLanguage: AppLanguage
    
    private var cancellable: AnyCancellable?
    private let userDefaultsKey = "SelectedLanguageKey"
    
    private init() {
        // Try to read the saved language from UserDefaults
        if let savedLangCode = UserDefaults.standard.string(forKey: userDefaultsKey),
           let savedLanguage = AppLanguage(rawValue: savedLangCode) {
            currentLanguage = savedLanguage
            // Sync with Localize-Swift
            Localize.setCurrentLanguage(savedLanguage.rawValue)
        } else {
            // If not saved before, use system language or default
            let langCode = Localize.currentLanguage()
            currentLanguage = AppLanguage(rawValue: langCode) ?? .en
        }
        
        // Listen to Localize-Swift language change notifications
        cancellable = NotificationCenter.default
            .publisher(for: Notification.Name(LCLLanguageChangeNotification))
            .sink { [weak self] _ in
                guard let self = self else { return }
                let newLangCode = Localize.currentLanguage()
                let newLang = AppLanguage(rawValue: newLangCode) ?? .en
                if newLang != self.currentLanguage {
                    self.currentLanguage = newLang
                    // Save the new language to UserDefaults
                    UserDefaults.standard.set(newLang.rawValue, forKey: self.userDefaultsKey)
                }
            }
    }
    
    func setLanguage(_ language: AppLanguage) {
        Localize.setCurrentLanguage(language.rawValue)
        currentLanguage = language
        // Save the selected language setting to UserDefaults
        UserDefaults.standard.set(language.rawValue, forKey: userDefaultsKey)
    }
}
