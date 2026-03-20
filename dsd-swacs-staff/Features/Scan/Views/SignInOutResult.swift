//
//  SignInOutResult.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/10/2025.
//

import SwiftUI

struct SignInOutResult: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    
    let staffSignInOutResponse: StaffSignInOutResponse
    let scanMode: ScanMode

    var resultTitle: String {
        switch scanMode {
        case .signIn:
            return "scan_qr_code_label_sign_in_title".localized()
        case .signOut:
            return "scan_qr_code_label_sign_out_title".localized()
        case .verify:
            return  ""
        }
    }
  
    var resultIconName: String {
        switch scanMode {
        case .signIn:
           return "icon-sign-in-result"
        case .signOut:
            return "icon-sign-out-result"
        case .verify:
            return  ""
        }
    }

    var resultText: String {
        switch scanMode {
        case .signIn:
           return "scan_qr_code_label_sign_in_successful".localized()
        case .signOut:
            return "scan_qr_code_label_sign_out_successful".localized()
        case .verify:
            return  ""
        }
    }

    var body: some View {
        
        VStack(spacing: 0){
            CustomNavBarView(type: .backOnly, title: resultTitle)
            VStack(spacing: 0){
                ScrollView{
                    VStack(alignment: .leading, spacing: 24) {
                        HStack(alignment: .center) {
                            Image(resultIconName)
                                .resizable()
                                .scaledToFit()
                                .frame(width: UIScreen.main.bounds.width * (320 / 393))
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                        
                        HStack(alignment: .center) {
                            Text(resultText)
                                .appFont(.robotoBold, size: 18)
                                .foregroundColor(Color.Neutral800)
                        }
                        .frame(maxWidth: .infinity, alignment: .center)
                      
                        
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(alignment: .top, spacing: 24) {
                                InfoRowView(title: "scan_qr_code_label_swac_no".localized(), value: staffSignInOutResponse.swac)
                                InfoRowView(title: "scan_qr_code_label_contractor".localized(), value: staffSignInOutResponse.company)
                            }
                            
                            HStack(alignment: .top, spacing: 24) {
                                InfoRowView(title: "scan_qr_code_label_working_team_member".localized(), value: staffSignInOutResponse.member)
                                InfoRowView(title: "scan_qr_code_label_role".localized(), value: staffSignInOutResponse.memberRole)
                            }
                        }
                        .padding(.vertical, 24)
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                .contentMargins(.horizontal, 24, for: .scrollContent)
                .contentMargins(.vertical, 24, for: .scrollContent)

                
                VStack(alignment: .leading, spacing: 8) {
                    CommonButton(title: "scan_qr_code_button_continue_scan".localized(), style: .outlined, enabled: true, maxWidth: .infinity) {
                        tabStore.popLastOnCurrentPath()
                    }
                    
                    CommonButton(title: "general_done".localized(),style: .contained, enabled: true, maxWidth: .infinity) {
                        tabStore.resetHomePath()
                    }
                }
                .padding(.vertical, 12)
                .padding(.horizontal, 24)
            }
            .background(.white)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.white)
    }
}


#if DEBUG
#Preview {
    SignInOutResult(staffSignInOutResponse: StaffSignInOutResponse(
        swac: "0096",
        company: "香港特區政府",
        member: "方紹能",
        memberRole: "註冊安全主任 / 安全督導員 / 一般工程人員 / 密閉空間核准工人"
    ), scanMode: .signOut)
}
#endif
