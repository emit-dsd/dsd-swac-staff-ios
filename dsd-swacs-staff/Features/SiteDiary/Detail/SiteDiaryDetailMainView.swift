//
//  SiteDiaryDetailMainView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

struct SiteDiaryDetailMainView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    @Environment(\.dismiss) var dismiss
    
    @State private var selectedTab: SiteDiaryDetailTab = .diary
    @StateObject private var viewModel: SiteDiaryDetailViewModel
    
    init(swacNumber: String, diaryId: Int) {
        _viewModel = StateObject(wrappedValue: SiteDiaryDetailViewModel(
            swacNumber: swacNumber,
            diaryId: diaryId
        ))
    }
    
    enum SiteDiaryDetailTab: String, CaseIterable {
        case diary = "site_diary_detail_tab_button_diary"
        case comment = "site_diary_detail_tab_button_comment"
    }
    
    // MARK: - Subviews
    var segmentBar: some View {
        HStack(spacing: 0) {
            ForEach(SiteDiaryDetailTab.allCases, id: \.self) { tab in
                SegmentControlButton(
                    title: tab.rawValue.localized(),
                    isSelected: selectedTab.rawValue == tab.rawValue,
                    action: { selectedTab = tab }
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    var bottomActionButtons: some View {
        VStack(alignment: .leading, spacing: 12) {
            approveButton
            rejectButton
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .padding(.bottom, 16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    var approveButton: some View {
        CommonButton(
            title: "swac_detail_button_approve".localized(),
            style: .contained,
            enabled: true,
            maxWidth: .infinity
        ) {
            // TODO: Handle approve action
        }
    }
    
    var rejectButton: some View {
        CommonButton(
            title: "swac_detail_button_reject".localized(),
            style: .outlined,
            enabled: true,
            maxWidth: .infinity,
            textColor: .red,
            backgroundColor: .red
        ) {
            // TODO: Handle reject action
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var mainContentView: some View {
        Group {
            if viewModel.isLoading && viewModel.diary == nil {
                loadingView
            } else if let swacDetail = viewModel.swacDetail, let diary = viewModel.diary {
                diaryContentView(swacDetail: swacDetail, diary: diary)
//                diaryWithTabContentView(swacDetail: swacDetail, diary: diary)
            } else if let error = viewModel.errorMessage {
                errorView(message: error)
            } else {
                loadingView
            }
        }
    }
    
    private func diaryWithTabContentView(swacDetail: SWACDetail, diary: SiteDiary) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            segmentBar
            
            Group {
                switch selectedTab {
                case .diary:
                    SiteDiaryDetailDiaryView(
                        viewModel: viewModel,
                        swacDetail: swacDetail,
                        siteDiary: diary
                    )
                case .comment:
                    SiteDiaryDetailCommentView(
                        selectedTab: $selectedTab,
                        swacDetail: swacDetail,
                        siteDiary: diary
                    )
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
//            Spacer()
            
//            if shouldShowBottomView(diary: diary) {
//                bottomActionButtons
//            }
        }
        .padding(.top, 8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    private func diaryContentView(swacDetail: SWACDetail, diary: SiteDiary) -> some View {
        VStack(alignment: .leading, spacing: 0) {
            SiteDiaryDetailDiaryView(
                viewModel: viewModel,
                swacDetail: swacDetail,
                siteDiary: diary
            )
            
//            Spacer()
            
//            if shouldShowBottomView(diary: diary) {
//                bottomActionButtons
//            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Text("Error")
                .appFont(.robotoBold, size: 18)
                .foregroundColor(.Neutral800)
            
            Text(message)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(.Neutral500)
                .multilineTextAlignment(.center)
            
            CommonButton(
                title: "Retry",
                style: .contained,
                enabled: true,
                maxWidth: 200
            ) {
                Task {
                    await viewModel.loadData()
                }
            }
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavBarView(
                    type: .backOnly,
                    title: "site_diary_detail_title".localized()
                )
                
                mainContentView
            }
            .background(Color.white)
        }
        .task {
            await viewModel.loadData()
        }
    }
    
    // MARK: - Helper Methods
    private func shouldShowBottomView(diary: SiteDiary) -> Bool {
        // Show buttons if diary is pending for DSD approval
        return diary.status == .pendingDSDEndorsement
    }
}

#if DEBUG
#Preview {
    SiteDiaryDetailMainView(swacNumber: "001D", diaryId: 3)
        .environmentObject(TabNavigationStore())
}
#endif
