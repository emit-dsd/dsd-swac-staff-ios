//
//  SiteDiaryListView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 28/10/2025.
//

import SwiftUI

struct SiteDiaryListView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    
    @StateObject private var viewModel: SiteDiaryListViewModel
    @State private var selectedStatus: SiteDiaryStatusFilter = .all
    @State private var showBottomSheet = false
    
    @State private var swacInfoHeight: CGFloat = 0
    @State private var savedScrollOffset: CGFloat = 0
    @State private var shouldSnapToTabBar = false
    
    init(swacNumber: String) {
        _viewModel = StateObject(wrappedValue: SiteDiaryListViewModel(swacNumber: swacNumber))
    }
    
    enum SiteDiaryStatusFilter: Int, CaseIterable {
        case all = 0
        case pendingDSDEndorsement = 1
        case pendingContractorEndorsement = 2
        case pendingDSDApproval = 3
        case archived = 5
        case rejected = 4
        
        var displayText: String {
            switch self {
            case .all:
                return "site_diary_filter_status_label_all".localized()
            case .pendingDSDEndorsement:
                return "site_diary_filter_status_label_pending_dsd_endorsement".localized()
            case .pendingContractorEndorsement:
                return "site_diary_filter_status_label_contractor_endorsement".localized()
            case .pendingDSDApproval:
                return "site_diary_filter_status_label_dsd_approval".localized()
            case .rejected:
                return "site_diary_filter_status_label_rejected".localized()
            case .archived:
                return "site_diary_filter_status_label_archived".localized()
            }
        }
    }
    
    // MARK: - Subviews
    
    var swacInfoView: some View {
        Group {
            if let swacDetail = viewModel.swacDetail {
                VStack(alignment: .leading, spacing: 12) {
                    swacTitleSection(swacDetail)
                    SWACInfoView(swacDetail: swacDetail)
                }
                .padding(.top, 16)
                .padding(.horizontal, 16)
                .background(
                    GeometryReader { geometry in
                        Color.clear
                            .onAppear {
                                swacInfoHeight = geometry.size.height
                            }
                            .onChange(of: geometry.size.height) { _, newHeight in
                                swacInfoHeight = newHeight + 16
                            }
                    }
                )
            }
        }
    }
    
    private func swacTitleSection(_ swacDetail: SWACDetail) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(swacDetail.number)
                .appFont(.robotoBold, size: 16)
                .foregroundColor(.Neutral500)
            Text(swacDetail.contractTitle)
                .appFont(.robotoBold, size: 18)
                .foregroundColor(.Neutral800)
                .lineLimit(1)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var SiteDiaryTabBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            if viewModel.isDateFilterActive {
                filterDateCountLabel
                    .padding(.top, 16)
            } else {
                statusChipsScrollView
                totalCountLabel
            }
        }
        .padding(.bottom, 2)
        .background(Color.white)
    }
    
    var statusChipsScrollView: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(alignment: .top, spacing: 8) {
                ForEach(SiteDiaryStatusFilter.allCases, id: \.self) { status in
                    Chip(
                        label: status.displayText,
                        isSelected: selectedStatus == status,
                        showIcon: false
                    ) {
                        print("🔵 [SCROLL] Current Offset: \(savedScrollOffset), Header Height: \(swacInfoHeight)")

                        if savedScrollOffset >= swacInfoHeight {
                            shouldSnapToTabBar = true
                            print("✅ [SCROLL] Will Snap to TabBar (Section Header)")
                        } else {
                            // 如果 Header 還在畫面上 -> 保持原位 (不動)
                            shouldSnapToTabBar = false
                            print("ℹ️ [SCROLL] Header visible, staying at current offset")
                        }
                        
                        selectedStatus = status
                        Task {
                            let stateValue = status == .all ? nil : status.rawValue
                            await viewModel.applyStateFilter(state: stateValue)
                        }
                    }
                }
            }
        }
        .padding(.vertical, 8)
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var totalCountLabel: some View {
        Text("site_diary_main_label_total_count".localized().replacingOccurrences(of: "{R1}", with: "\(viewModel.diaries.count)"))
            .appFont(.robotoRegular, size: 14)
            .foregroundColor(Color.Neutral500)
            .padding(4)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var filterDateCountLabel: some View {
        Text(makeFilterDateAttributedString())
            .padding(4)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    private func makeFilterDateAttributedString() -> AttributedString {
        let startDateStr = viewModel.startDate?.toAPIDateString() ?? ""
        let endDateStr = viewModel.endDate?.toAPIDateString() ?? ""
        
        let template = "site_diary_main_label_filter_show".localized()
        let fullText = template
            .replacingOccurrences(of: "{R1}", with: startDateStr)
            .replacingOccurrences(of: "{R2}", with: endDateStr)
        
        var attributedString = AttributedString(fullText)
        
        attributedString.foregroundColor = .Neutral500
        attributedString.font = .custom("Roboto", size: 14)
        
        func boldAllOccurrences(of searchString: String) {
            var searchRange = attributedString.startIndex..<attributedString.endIndex
            
            while let range = attributedString[searchRange].range(of: searchString) {
                attributedString[range].font = .custom("Roboto-Bold", size: 14)
                attributedString[range].foregroundColor = .Neutral800
                
                searchRange = range.upperBound..<attributedString.endIndex
            }
        }
        
        boldAllOccurrences(of: startDateStr)
        if startDateStr != endDateStr {
            boldAllOccurrences(of: endDateStr)
        }
        
        return attributedString
    }
    
    var mainContentView: some View {
        Group {
            if viewModel.isLoading && viewModel.swacDetail == nil {
                loadingView
            } else if viewModel.swacDetail != nil {
                diaryListView
            } else {
                largeLoadingView
            }
        }
    }
    
    var loadingView: some View {
        ProgressView()
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var largeLoadingView: some View {
        ProgressView()
            .scaleEffect(1.5)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    var diaryListView: some View {
        VStack {
            ScrollViewReader { proxy in
                GeometryReader { outerGeometry in
                    ScrollView {
                        VStack(spacing: 0) {
                            if !viewModel.isDateFilterActive {
                                swacInfoView
                            }
                            
                            diaryListSection(outerHeight: outerGeometry.size.height)
                        }
                        .background(
                            GeometryReader { innerGeometry in
                                Color.clear
                                    .onChange(of: innerGeometry.frame(in: .named("scroll")).minY) { oldValue, newValue in
                                        let offset = -newValue
                                        savedScrollOffset = offset
                                    }
                            }
                        )
                    }
                    .coordinateSpace(name: "scroll")
                    .refreshable {
                        await viewModel.refreshList()
                    }
                    .onChange(of: viewModel.diaries.count) { oldCount, newCount in
                        if newCount > 0 {
                            DispatchQueue.main.async {
                                if shouldSnapToTabBar {
                                    withAnimation(nil) {
                                        proxy.scrollTo("diary-list-section", anchor: .top)
                                    }
                                }
                                shouldSnapToTabBar = false
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    func diaryListSection(outerHeight: CGFloat) -> some View {
        LazyVStack(spacing: 8, pinnedViews: [.sectionHeaders]) {
            Section {
                diaryContentOrEmpty(minHeight: outerHeight)
                loadingMoreIndicator
            } header: {
                SiteDiaryTabBar
                    .id("diary-list-section")
            }
        }
    }
    
    @ViewBuilder
    func diaryContentOrEmpty(minHeight: CGFloat) -> some View {
        if viewModel.diaries.isEmpty {
            if viewModel.isRefreshing {
                loadingStateView
                    .frame(minHeight: minHeight, alignment: .top)
            } else {
                emptyStateView
                    .frame(minHeight: minHeight / 2, alignment: .top)
            }
        } else if viewModel.isRefreshing {
            loadingStateView
                .frame(minHeight: minHeight, alignment: .top)
        } else {
            diaryCardsView
        }
    }
    
    var emptyStateView: some View {
        VStack(spacing: 12) {
            Text("general_no_results".localized())
                .appFont(.robotoRegular, size: 16)
                .foregroundColor(.Neutral500)
            Spacer()
        }
        .padding(.top, 60)
    }
    
    var loadingStateView: some View {
        VStack(spacing: 12) {
            ProgressView()
                .scaleEffect(1.2)
            Spacer()
        }
        .padding(.top, 60)
        .frame(maxWidth: .infinity)
    }
    
    var diaryCardsView: some View {
        ForEach(Array(viewModel.diaries.enumerated()), id: \.element.id) { index, diary in
            diaryCardRow(diary: diary, index: index)
        }
    }
    
    private func diaryCardRow(diary: SiteDiary, index: Int) -> some View {
        SiteDiaryCard(siteDiary: diary)
            .id(diary.id)
            .onTapGesture {
                tabStore.appendToCurrentPath(
                    Screen.SiteDiaryDetailMain(
                        viewModel.swacNumber,
                        diary.id
                    )
                )
            }
            .contentShape(Rectangle())
            .padding(.horizontal, 16)
            .onAppear {
                if viewModel.hasReachedEnd(of: diary) {
                    Task {
                        await viewModel.loadMoreItems()
                    }
                }
            }
    }
    
    @ViewBuilder
    var loadingMoreIndicator: some View {
        if viewModel.isLoadingMore {
            HStack {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle())
                Text("general_loading_more".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.Neutral500)
            }
            .frame(maxWidth: .infinity)
            .padding()
        }
        
        if !viewModel.hasMorePages && !viewModel.diaries.isEmpty && !viewModel.isLoadingMore {
            Text("general_no_more_data".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(.Neutral500)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
        }
    }
    
    var floatingActionButton: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    tabStore.appendToCurrentPath(Screen.SiteDiaryNewEntry(viewModel.swacNumber))
                }) {
                    Image("icon-button-plus")
                        .foregroundColor(.white)
                        .padding()
                        .background(Color.Primary500)
                        .clipShape(Circle())
                        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 0)
                }
                .padding(.trailing, 16)
                .padding(.bottom, 24)
            }
        }
        .allowsHitTesting(true)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navBar
                mainContentView
            }
            
            if viewModel.swacDetail != nil && !viewModel.isLoading {
                floatingActionButton
            }
        }
        .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(380)]) {
            dateFilterBottomSheet
        }
        .task {
            await viewModel.loadData()
        }
        .background(Color.white)
    }
    
    var navBar: some View {
        CustomNavBarView(
            type: .searchBarWithFilterDate,
            searchPlaceholder: "site_diary_list_placeholder_search_site_diary".localized(),
            searchText: $viewModel.searchText,
            onFilterTapped: {
                showBottomSheet = true
            }
        )
    }
    
    var dateFilterBottomSheet: some View {
        CustomDateFilterBottomSheetView(
            isPresented: $showBottomSheet,
            mode: .dateRange,
            startDate: viewModel.startDate ?? Date(),
            endDate: viewModel.endDate ?? Date(),
            onApply: { result in
                if result.startDate == nil && result.endDate == nil {
                    Task {
                        shouldSnapToTabBar = false
                        await viewModel.clearAllFilters()
                        selectedStatus = .all
                    }
                } else if let start = result.startDate, let end = result.endDate {
                    Task {
                        shouldSnapToTabBar = false
                        await viewModel.applyDateFilter(startDate: start, endDate: end)
                        selectedStatus = .all
                    }
                }
                showBottomSheet = false
            }
        )
    }
}
