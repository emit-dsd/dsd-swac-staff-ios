//
//  LoginMainView.swift
//  DSD_SWACS
//
//  Created by Andy on 25/7/2025.
//

import SwiftUI

struct LoginMainView: View {
//    @AppStorage("isLoggedIn") var isLoggedIn: Bool = false
    @EnvironmentObject var authManager: AuthenticationManager
    @EnvironmentObject var languageManager: AppLanguageManager
    @StateObject private var viewModel = LoginViewModel()
    
    init() {
#if DEBUG
    let vm = LoginViewModel()
    vm.loginName = "swacs_asl_1"
    vm.loginPw = "Pass424101"
    _viewModel = StateObject(wrappedValue: vm)
#else
    _viewModel = StateObject(wrappedValue: LoginViewModel())
#endif
    }
    
    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    }
    
    private var appBuildNumber: String {
        Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "Unknown"
    }
    
    var body: some View {
        
        VStack(alignment: .center, spacing: 0){
            VStack(spacing:0) {
                Image("login-background")
                    .resizable()
                    .frame(minWidth: 405,minHeight: 202)
                    .aspectRatio(405/202, contentMode: .fit)
                
                VStack(alignment: .center, spacing: 24) {
                    HeaderView()
                    
                    LanguageSelector()
                    
                    CustomInputView(
                        title: "login_label_login_name".localized(),
                        text: $viewModel.loginName,
                        placeholder: "login_label_login_name".localized(),
                        mode: .default
                    )
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    
                    CustomInputView(
                        title: "login_label_password".localized(),
                        text: $viewModel.loginPw,
                        placeholder: "login_label_password".localized(),
                        mode: .default,
                        isSecure: true
                    )
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                    CommonButton(title:"login_button_login".localized(),
                                 style: .contained,
                                 enabled: !viewModel.loginName.isEmpty && !viewModel.loginPw.isEmpty ,
                                 maxWidth: .infinity, action:  {
                        Task {
                            await viewModel.performLogin()
                        }
                    })
                    
                    Spacer()
                    
                    VStack(alignment: .leading, spacing: 8) {
                        Text("login_label_copyright".localized())
                            .appFont(.robotoRegular, size: 14)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Neutral500)
                            .frame(maxWidth: .infinity, alignment: .top)
                        
                        Text("login_label_version".localized() + " \(appVersion) (\(appBuildNumber))")
                            .appFont(.robotoRegular, size: 14)
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color.Neutral500)
                            .frame(maxWidth: .infinity, alignment: .top)
                    }
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    
                }
                .padding(.horizontal, 24)
                .padding(.top, 36)
                .padding(.bottom, 100)
                .frame(maxWidth:.infinity, maxHeight: .infinity, alignment: .top)
                .background(Color.white)
                
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges:.top)
        .ignoresSafeArea(edges:.bottom)
    }
}



struct Login_Previews: PreviewProvider {
    static var previews: some View {
        LoginMainView()
            .environmentObject(AppLanguageManager.shared)
    }
}
