//
//  SWACMainView.swift
//  SiteWorkApp
//
//  Created by User on 17/7/2025.
//

import SwiftUI

struct SWACMainView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    @EnvironmentObject var notificationManager: NotificationManager
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var viewModel = SWACViewModel()
    
    // MARK: - SWAC Tab Bar
    var SWACTabBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(SWACViewModel.SWACStatusFilter.allCases, id: \.self) { status in
                    let displayText = status.localizationKey.localized()
                    Chip(
                        label: displayText,
                        isSelected: viewModel.selectedStatus == status,
                        showIcon: false
                    ) {
                        viewModel.selectedStatus = status
                    }
                }
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    func notificationMain() {
        tabStore.appendToCurrentPath(Screen.notificationMain)
    }
    
    private func performAction(for item: SWACListItem) {
        guard let selectedStatus = viewModel.selectedStatus,
              let actionTitleKey = selectedStatus.actionTitleKey else { return }
        
        let titleKey: String
        let messageKey: String
        let confirmKey: String
        switch selectedStatus {
        case .approval:
            titleKey = "start_work_alertTitle_approve_msg"
            messageKey = "start_work_alertMessage_approve_msg"
            confirmKey = "start_work_button_confirm_approve"
        case .endorsement:
            titleKey = "start_work_alertTitle_endorse_msg"
            messageKey = "start_work_alertMessage_endorse_msg"
            confirmKey = "start_work_button_confirm_endorse"
        case .reject:
            titleKey = "start_work_alertTitle_reject_msg"
            messageKey = "start_work_alertMessage_reject_msg"
            confirmKey = "start_work_button_confirm_reject"
        case .safetyVetting:
            return
        }
        
        alertManager.show(
            title: titleKey.localized(),
            message: messageKey.localized(),
            buttons: [
                CommonButtonModel(
                    title: confirmKey.localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    textColor: .white,
                    backgroundColor: .red,
                    action: {
                        Task {
                            switch selectedStatus {
                            case .approval:
                                await viewModel.approveEntry(item: item)
                            case .endorsement:
                                await viewModel.endorseRegistration(item: item)
                            case .reject:
                                await viewModel.rejectEntry(item: item)
                            case .safetyVetting:
                                break
                            }
                        }
                    }
                ),
                CommonButtonModel(
                    title: "general_cancel".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        
                    }
                )
            ]
        )
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar with search binding
            CustomNavBarView(
                type: .searchBarWithnotification,
                searchPlaceholder: "swac_main_placeholder_swac".localized(),
                searchText: $viewModel.searchText,
                onNotificationTapped: notificationMain
            )
            
            ZStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 8) {
                    // Title
                    HStack {
                        Text("swac_main_title_main".localized())
                            .appFont(.robotoBold, size: 18)
                            .foregroundColor(.Neutral800)
                        
                        Spacer()
                    }
                    .padding(.horizontal, 16)
                    
                    // Status filter tabs (with animation)
                    if !viewModel.isSearchActive {
                        SWACTabBar
                            .transition(.move(edge: .top).combined(with: .opacity))
                    }
                    
                    // Total count with search indicator
                    HStack {
                        Spacer()
                        Text("swac_main_label_total_count".localized().replacingOccurrences(
                            of: "{R1}",
                            with: (viewModel.selectedStatus == nil && !viewModel.isSearchActive) ? "-" : "\(viewModel.swacList.count)"
                        ))
                        .appFont(.robotoRegular, size: 14)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(.Neutral500)
                    }
                    .padding(.horizontal, 16)
                    
                    // Content
                    contentView
                }
                .padding(.top, 24)
                .background(Color.white)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: viewModel.isSearchActive)
        .animation(.easeInOut(duration: 0.3), value: viewModel.selectedStatus)
        .task(id: viewModel.selectedStatus) {
            guard tabStore.tabSelection == .swac else { return }
            if !viewModel.isSearchActive {
                await viewModel.fetchSWACList(reset: true)
            }
            await notificationManager.fetchUnreadCount()
        }
        .onDisappear {
            viewModel.cancelCurrentTask()
        }
        .background(Color.white)
    }
    
    // MARK: - Content View
    @ViewBuilder
    private var contentView: some View {
        if viewModel.shouldShowEmptyPrompt {
            emptyPromptView
        } else if viewModel.isLoading && viewModel.swacList.isEmpty {
            ProgressView()
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        } else if viewModel.swacList.isEmpty {
            emptyView
        } else {
            listView
        }
    }
    
    // MARK: - List View
    private var listView: some View {
        ScrollView {
            LazyVStack(spacing: 8) {
                ForEach(viewModel.swacList, id: \.uniqueID) { swac in
                    if !viewModel.isSearchActive && viewModel.selectedStatus?.actionTitleKey != nil {
                        CSWRCard(
                            swac: swac,
                            actionTitle: viewModel.selectedStatus!.actionTitleKey!.localized(),
                            actionButtonStyle: viewModel.selectedStatus == .reject ? .outlined : .contained,
                            onActionButtonTapped: { swac in
                                performAction(for: swac)
                            }
                        )
                        .onTapGesture {
                            tabStore.appendToCurrentPath(Screen.swacDetail(swac.number))
                        }
                        .onAppear {
                            if viewModel.hasReachedEnd(of: swac) {
                                Task {
                                    await viewModel.loadMoreItems()
                                }
                            }
                        }
                    }else {
                        SWACCard(
                            swac: swac,
                            showActionButton: false,
                            showCSWRStatus: false
                        )
                        .onTapGesture {
                            tabStore.appendToCurrentPath(Screen.swacDetail(swac.number))
                        }
                        .onAppear {
                            if viewModel.hasReachedEnd(of: swac) {
                                Task {
                                    await viewModel.loadMoreItems()
                                }
                            }
                        }
                    }
                }
                
                if viewModel.isLoadingMore {
                    ProgressView()
                        .frame(maxWidth: .infinity)
                        .padding()
                }
                
                if !viewModel.hasMorePages && !viewModel.swacList.isEmpty && !viewModel.isLoadingMore {
                    Text("general_no_more_data".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
            .padding(.bottom, 32)
        }
        .refreshable {
            await viewModel.refreshList()
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 32, for: .scrollContent)
    }
    
    // MARK: - Empty Prompt View (No Filter Selected)
    private var emptyPromptView: some View {
        VStack(alignment: .center, spacing: 16){
            Image("icon-inbox")
                .frame(width: 64, height: 64)
            Text("swac_main_label_empty_prompt_title".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(.Neutral300)
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 150)
        .padding(.vertical, 50)
    }
    
    // MARK: - Empty View (No Results)
    private var emptyView: some View {
        VStack(spacing: 12) {
            Text("general_no_results".localized())
                .appFont(.robotoBold, size: 16)
                .foregroundColor(.Neutral500)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }
}

#if DEBUG
#Preview {
    SWACMainView()
        .environmentObject(TabNavigationStore())
}
#endif
