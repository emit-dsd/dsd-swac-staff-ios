//
//  SettingView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 25/8/2025.
//

import SwiftUI
import UserNotifications
import SwiftUI


struct SettingView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var authManager: AuthenticationManager
    @ObservedObject var userSession = UserSession.shared
    @StateObject var tabStore = TabNavigationStore()
    @State private var isTabBarHidden: Bool = false
    @State private var showAlert = false
    
//    let user: StaffLoginResponse.UserProfile? = userSession.profile

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var appBuildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var body: some View {
        VStack(spacing: 0){
            CustomNavBarView(type: .none,title: "setting_title_account_setting".localized())
            
            ScrollView{
                VStack(alignment: .leading, spacing: 24) {
                    
                    if let user = userSession.profile {
                        VStack(alignment: .leading, spacing: 0) {
                            Text("setting_label_my_profile".localized())
                                .appFont(.robotoBold, size: 18)
                                .foregroundColor(Color.Neutral800)
                                .frame(maxWidth: .infinity, alignment: .topLeading)
                                .padding(.horizontal, 8)
                                .padding(.top, 16)
                                .padding(.bottom, 8)
                            
                            
                            VStack(alignment: .leading, spacing: 12) {
                                InfoRowView(title: "setting_label_login_id".localized(), value: user.id)
                                InfoRowView(title: "setting_label_email_address".localized(),
                                            value: user.email)
                                InfoRowView(title: "setting_label_nameEng".localized(), value: user.nameEng)
                                
                                if let nameChi = user.nameChi {
                                    InfoRowView(title: "setting_label_nameChi".localized(), value: nameChi)
                                }
                              
                                HStack(alignment: .top, spacing: 8) {
                                    InfoRowView(title: "setting_label_division".localized(), value: user.division)
                                    InfoRowView(title: "setting_label_post".localized(), value: user.post)
                                }
                                
                                HStack(alignment: .top, spacing: 8) {
                                    if let officePhone = user.officePhone {
                                        InfoRowView(title: "setting_label_office_phone_number".localized(), value:officePhone)
                                    }
                                    InfoRowView(title: "setting_label_mobile_phone_number".localized(), value: user.mobile)
                                }
                            }
                            .padding(16)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .background(Color.Neutral200)
                            .cornerRadius(16)
                        }
                    }
                  
                    VStack(alignment: .leading, spacing: 16) {
                        VStack(alignment: .leading, spacing: 10) {
                            HStack(alignment: .center, spacing: 8) {
                                Image("setting-language-icon")
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                Text("setting_label_language".localized())
                                    .appFont(.robotoBold, size: 16)
                                    .multilineTextAlignment(.center)
                                    .foregroundColor(Color.Primary800)
                                Spacer()
                                SettingLanguageSelector()
                            }
                            .padding(0)
                            .frame(maxWidth: .infinity, alignment: .leading)
                        }
                        .padding(.horizontal, 16)
                        .padding(.vertical, 12)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(.white)
                        .cornerRadius(16)
                        .overlay(
                            RoundedRectangle(cornerRadius: 16)
                                .inset(by: 0.5)
                                .stroke(Color.Neutral300, lineWidth: 1)
                        )
                        
                        Button(action: {
                            alertManager.show(
                                title: "setting_alertTitle_logout".localized(),
                                message: "setting_alertMessage_logout_msg".localized(),
                                buttons: [
                                    CommonButtonModel(
                                        title: "setting_button_logout".localized(),
                                        style: .contained,
                                        enabled: true,
                                        maxWidth: .infinity,
                                        textColor: .white,
                                        backgroundColor: .red,
                                        action: {
                                            Task {
                                                await authManager.logout()
                                            }
                                        }
                                    ),
                                    CommonButtonModel(
                                        title: "setting_button_cancel".localized(),
                                        style: .outlined,
                                        enabled: true,
                                        maxWidth: .infinity,
                                        action: {
                                            
                                        }
                                    )
                                ]
                            )
                        }) {
                            VStack(alignment: .leading, spacing: 10) {
                                HStack(alignment: .center, spacing: 8) {
                                    Image("setting-logout-icon")
                                        .resizable()
                                        .frame(width: 24, height: 24)
                                    
                                    Text("setting_button_logout".localized())
                                        .appFont(.robotoBold, size: 16)
                                        .multilineTextAlignment(.center)
                                        .foregroundColor(Color.Primary800)
                                    
                                }
                                .padding(0)
                                .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(.white)
                            .cornerRadius(16)
                            .overlay(
                                RoundedRectangle(cornerRadius: 16)
                                    .inset(by: 0.5)
                                    .stroke(Color.Neutral300, lineWidth: 1)
                            )
                        }
                       
                        
                        Text("setting_label_version".localized() + " \(appVersion) (\(appBuildNumber))")
                            .appFont(.robotoRegular, size: 14)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Neutral500)
                            .frame(maxWidth: .infinity, alignment: .top)
                        
                    }
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity,  alignment: .topLeading)
                
#if DEBUG
//                VStack(spacing: 10) {
//                    Text("DEBUG".localized())
//                        .appFont(.robotoRegular, size: 14)
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(Color.Neutral500)
//                        .frame(maxWidth: .infinity, alignment: .top)
//                    
//                    
//                    Button("允許通知權限") {
//                        requestNotificationPermission()
//                    }
//                    Button("10 秒後顯示通知") {
//                        scheduleLocalNotification()
//                    }
//                    
//                    
//                }.frame(maxWidth: .infinity)
#endif
                
            }
        }
        .background(Color.white)
    }
}

func requestNotificationPermission() {
    UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound]) { granted, error in
        if granted {
            print("通知權限已允許")
        } else {
            print("通知權限未允許")
        }
    }
}

func scheduleLocalNotification() {
    let content = UNMutableNotificationContent()
    content.title = "測試通知"
    content.body = "這是一則 10 秒後出現的本地推播"

    let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
    let request = UNNotificationRequest(identifier: "testLocalNotification", content: content, trigger: trigger)

    UNUserNotificationCenter.current().add(request) { error in
        if let error = error {
            print("安排通知失敗: \(error.localizedDescription)")
        } else {
            print("通知已安排")
        }
    }
}

struct Setting_Previews: PreviewProvider {
    static var previews: some View {
        SettingView()
            .environmentObject(TabNavigationStore())
            .environmentObject(AppLanguageManager.shared)
    }
}
