//
//  ScreanResultView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/8/2025.
//

import SwiftUI

struct ScreanResultView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    
    //    let swac: SWAC
    let inspectAccessCodeResponse: InspectAccessCodeResponse?
    let errorMessage: String?
    let isValid: Bool
    
    var backgroundColor: Color {
        isValid ? Color.green : Color.red
    }
    
    var resultIconName: String {
        isValid ? "scan-result-tick" : "scan-result-fail"
    }
    
    var resultText: String {
        isValid ? "scan_qr_code_label_verify_success_msg".localized()
        : errorMessage ?? "scan_qr_code_label_verify_fail_msg".localized()
    }
    
    var timeTextColor: Color {
        isValid ? .Primary800 : .red
    }
    
    var body: some View {
        ZStack(alignment: .top) {
            
            backgroundColor.ignoresSafeArea(edges: .top)
            
            VStack(spacing: 0) {
                Spacer()
                VStack(spacing: 24) {
                    Image(resultIconName)
                        .resizable()
                        .frame(width: 64, height: 64)
                    
                    Text(resultText)
                        .appFont(.robotoBold, size: 24)
                        .multilineTextAlignment(.center)
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)

                VStack(spacing: 0) {
                    VStack(alignment: .leading, spacing: 24) {
                        if isValid, let response = inspectAccessCodeResponse {
                            Text("scan_qr_code_label_swac_info".localized())
                                .appFont(.robotoBold, size: 18)
                                .foregroundColor(Color.Neutral800)
                            
                            HStack(alignment: .top, spacing: 24) {
                                InfoRowView(title: "scan_qr_code_label_swac_no".localized(), value: response.swac )
                                InfoRowView(title: "scan_qr_code_label_contractor".localized(), value: response.contractor)
                            }
                            
                            HStack(alignment: .top, spacing: 24) {
                                InfoRowView(title: "scan_qr_code_label_working_team_member".localized(), value: response.workingTeamMember)
                                InfoRowView(title: "scan_qr_code_label_role".localized(), value: response.memberRole)
                            }
                            
                            HStack(alignment: .top, spacing: 24) {
                                InfoRowView(title: "scan_qr_code_label_startTime".localized(), value: response.startTime, valueColor: timeTextColor)
                                InfoRowView(title: "scan_qr_code_label_endTime".localized(), value: response.finishTime, valueColor: timeTextColor)
                            }
                        }
                        VStack(alignment: .leading, spacing: 8) {
                            CommonButton(title: "scan_qr_code_button_continue_scan".localized(), style: .outlined, enabled: true, maxWidth: .infinity) {
                                tabStore.popLastOnCurrentPath()
                            }
                            
                            CommonButton(title: "general_done".localized(),style: .contained, enabled: true, maxWidth: .infinity) {
                                tabStore.resetHomePath()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 24)
                    .background(Color.white)
                    .cornerRadius(24, corners: [.topLeft, .topRight])
                }
            }
        }
    }
}

#if DEBUG
#Preview {
    ScreanResultView(
        inspectAccessCodeResponse: InspectAccessCodeResponse(
            swac: "0096",
            contractor: "香港特區政府",
            workingTeamMember: "方紹能",
            startTime: "2025-10-22 08:35",
            finishTime: "2025-11-21 18:40",
            memberRole: "registered safety officer / safety supervisor / general worker / certified worker for confined space works",
            location: "[translate:過渡性房屋 - 雅匯 1A號 Yen Chow St, Sham Shui Po, 香港]"
        ), errorMessage: nil, isValid: true
    )
}

#Preview("Invalid Result") {
    ScreanResultView(
        inspectAccessCodeResponse: nil, errorMessage: "access code not found", isValid: false
    )
}
#endif
