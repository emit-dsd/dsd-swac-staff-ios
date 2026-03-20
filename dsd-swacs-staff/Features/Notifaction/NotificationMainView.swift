//
//  NotificationMainView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 8/8/2025.
//

import SwiftUI

struct NotificationMainView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    @EnvironmentObject var notificationManager: NotificationManager
    
    @StateObject private var viewModel = NotificationMainViewModel()
    @State private var showBottomSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Navigation Bar
//            CustomNavBarView(
//                type: .searchBarWithFilter,
//                searchPlaceholder: "notification_placeholder_search".localized(),
//                onFilterTapped: { showBottomSheet = true }
//            )
            
            CustomNavBarView(type:.backOnly)
            
            // Content
            contentView
        }
        .background(Color.white)
        .task {
            await viewModel.fetchNotifications()
        }
        .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(380)]) {
            dateFilterSheet
        }
    }
    
    // MARK: - Subviews
    private var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {
            headerView
            mainContent
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    private var headerView: some View {
        HStack {
            Text("notification_label_notification".localized())
                .appFont(.robotoBold, size: 18)
                .foregroundColor(.Neutral800)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            Text(totalCountText)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(.Neutral500)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
    }
    
    private var totalCountText: String {
        "notification_label_total_count".localized()
            .replacingOccurrences(of: "{R1}", with: "\(viewModel.totalCount)")
    }
    
    @ViewBuilder
    private var mainContent: some View {
        if viewModel.isLoading && viewModel.notifications.isEmpty {
            loadingView
        } else if viewModel.filteredNotifications.isEmpty {
            emptyView
        } else {
            notificationScrollView
        }
    }
    
    private var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
//            Image(systemName: "bell.slash")
//                .font(.system(size: 60))
//                .foregroundColor(.gray)
            Text("notification_label_no_notification".localized())
                .appFont(.robotoBold, size: 16)
                .foregroundColor(Color.Neutral500)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    private var notificationScrollView: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                NotificationListView(
                    items: viewModel.filteredNotifications,
                    onMarkAsRead: { notification in
                        await viewModel.markAsRead(notification)
                        await notificationManager.fetchUnreadCount()
                    }
                )
                loadMoreSection
            }
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 16, for: .scrollContent)
        .refreshable {
            await viewModel.refreshNotifications()
        }
    }
    
    @ViewBuilder
    private var loadMoreSection: some View {
        if viewModel.hasMorePages {
            Color.clear
                .frame(height: 50)
                .onAppear {
                    Task {
                        await viewModel.loadMoreNotifications()
                    }
                }
        }
        
        if viewModel.isLoadingMore {
            ProgressView().padding()
        }
        
        if !viewModel.hasMorePages && !viewModel.filteredNotifications.isEmpty && !viewModel.isLoadingMore {
            Text("general_no_more_data".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(.Neutral500)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
    }
    
    private var dateFilterSheet: some View {
        CustomDateFilterBottomSheetView(
            isPresented: $showBottomSheet,
            mode: .dateRange,
            startDate: viewModel.startDate ?? Date(),
            endDate: viewModel.endDate ?? Date(),
            onApply: { result in
                if let start = result.startDate, let end = result.endDate {
                    viewModel.applyDateFilter(start: start, end: end)
                }
            }
        )
    }
}

#if DEBUG
#Preview {
    NotificationMainView()
        .environmentObject(TabNavigationStore())
}
#endif
