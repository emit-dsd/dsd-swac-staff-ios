//
//  SiteDiaryDetailCommentView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 30/10/2025.
//

import SwiftUI

struct SiteDiaryDetailCommentView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    @Binding var selectedTab: SiteDiaryDetailMainView.SiteDiaryDetailTab
    @StateObject private var keyboardResponder = KeyboardResponder()
    @State private var showBottomSheet = false
    
    let mockSiteRecordComment = mockSiteRecordComments
    let swacDetail: SWACDetail
    let siteDiary : SiteDiary
    
    func successAlert() {
        alertManager.show(
            title: "site_diary_detail_alertTitle_send_back".localized(),
            message: "site_diary_detail_alertMessage_send_back".localized(),
            image: "icon-alert-success",
            buttons: [
                CommonButtonModel(
                    title: "general_back".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        //TODO: API
                        selectedTab = .diary
                    }
                )
            ]
        )
    }
    
    var body: some View {
        VStack {
            if mockSiteRecordComment.count == 0 {
                VStack(alignment: .center, spacing: 16) {
                    Image("icon-empty-box")
                      .frame(width: 48, height: 48)
                    Text("site_diary_detail_label_current_empty".localized())
                        .appFont(.robotoBold, size: 16)
                      .multilineTextAlignment(.center)
                      .foregroundColor(Color.Neutral300)
                      .frame(maxWidth: .infinity, alignment: .top)
                }
                .padding(.horizontal, 0)
                .padding(.vertical, 24)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
              
            } else {
                ScrollView{
                    VStack(spacing: 16) {
                           ForEach(mockSiteRecordComments) { comment in
                               SiteRecordCommentChatView(comment: comment)
                           }
                       }
                }
                .contentMargins(.vertical, 8, for: .scrollContent)
                .contentMargins(.horizontal, 16, for: .scrollContent)
            }
         
            VStack(alignment: .leading, spacing: 12) {
                CommonButton(
                    title: "site_diary_detail_button_send_back".localized() ,
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    textColor: .red,
                    backgroundColor: .red
                ) {
                    showBottomSheet = true
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 16)
            .padding(.bottom, 48)
            .background(Color.white)
            .cornerRadius(24)
            .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 0)
        }
        .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(320)]) {
            CustomCommentBottomSheetView(
                isPresented: $showBottomSheet,
                onSend: { text in
                    successAlert()
                    print("Send:", text)
                }
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom)
      
    }
}
