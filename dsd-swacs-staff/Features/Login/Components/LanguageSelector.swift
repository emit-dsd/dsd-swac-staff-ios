import SwiftUI
import Localize_Swift

struct LanguageSelector: View {
//    @EnvironmentObject private var localizationManager: LocalizationManager
    @EnvironmentObject var languageManager: AppLanguageManager
    
    var body: some View {
        HStack(spacing: 0) {
            Button(action: {
                languageManager.setLanguage(.en)
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
                languageManager.setLanguage(.zh_Hant)
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
}

struct LanguageSelector_Previews: PreviewProvider {
    static var previews: some View {
        LanguageSelector()
            .environmentObject(AppLanguageManager.shared)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
