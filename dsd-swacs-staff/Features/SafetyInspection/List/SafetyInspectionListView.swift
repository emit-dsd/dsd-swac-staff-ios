//
//  SafetyInspectionListView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 20/11/2025.
//

import SwiftUI

struct SafetyInspectionListView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore

    @StateObject private var viewModel: SafetyInspectionListViewModel

    let canSubmitSafetyInspectionReport: Bool
    
    @State private var selectedStatus: SafetyInspectionStatusFilter = .all
    @State private var showBottomSheet = false
    @State private var startDate = Date()
    @State private var endDate = Date()

    init(swacNumber: String, canSubmitSafetyInspectionReport: Bool) {
        _viewModel = StateObject(wrappedValue: SafetyInspectionListViewModel(swacNumber: swacNumber))
        self.canSubmitSafetyInspectionReport = canSubmitSafetyInspectionReport
    }

    // MARK: - Status Filter Enum

    enum SafetyInspectionStatusFilter: String, CaseIterable {
        case all = "all"
        case draft = "draft"
        case closed = "closed"
        case pendingClose = "pendingClose"
       
        var displayText: String {
            switch self {
            case .all:
                return "safety_inspection_status_label_all".localized()
            case .pendingClose:
                return "safety_inspection_status_label_pending_close".localized()
            case .closed:
                return "safety_inspection_status_label_closed".localized()
            case .draft:
                return "safety_inspection_status_label_draft".localized()
            }
        }

        var isClosedValue: Bool? {
            switch self {
            case .all:
                return nil 
            case .pendingClose:
                return false
            case .closed:
                return true
            case .draft:
                return nil
            }
        }
    }

    var filteredInspections: [SafetyInspectionItem] {
        switch selectedStatus {
        case .all:
            return viewModel.safetyInspectionItemList
        case .pendingClose:
            return viewModel.safetyInspectionItemList.filter { $0.status == .pendingClose }
        case .closed:
            return viewModel.safetyInspectionItemList.filter { $0.status == .closed }
        case .draft:
            return viewModel.safetyInspectionItemList.filter { $0.status == .draft }
        }
    }

    // MARK: - Subviews

    var loadingMoreIndicator: some View {
        Group {
            if viewModel.isLoadingMore {
                HStack {
                    ProgressView()
                    Text("general_loading_more".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                }
                .frame(maxWidth: .infinity)
                .padding()
            } else if !viewModel.hasMorePages && !viewModel.safetyInspectionItemList.isEmpty {
                Text("general_no_more_data".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.Neutral500)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
            }
        }
    }

    var swacInfoView: some View {
        Group {
            if let swacDetail = viewModel.swacDetail {
                VStack(alignment: .leading, spacing: 8) {
                    Text(swacDetail.number)
                        .appFont(.robotoBold, size: 16)
                        .foregroundColor(.Neutral500)
                    Text(swacDetail.contractTitle)
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(.Neutral800)
                        .lineLimit(1)
                }
                .padding(.horizontal, 16)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }
    
    var SafetyInspectionTabBar: some View {
        VStack(alignment: .leading, spacing: 4) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 8) {
                    ForEach(SafetyInspectionStatusFilter.allCases, id: \.self) { status in
                        Chip(
                            label: status.displayText,
                            isSelected: selectedStatus == status,
                            showIcon: false
                        ) {
                            selectedStatus = status
                            Task {
                                await viewModel.loadData(reset: true, filter: status)
                            }
                        }
                    }
                }
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .background(Color.white)
    }
    
    private func handleItemClick(_ item: SafetyInspectionItem, isEdit: Bool) {
        if let draftId = item.draftUUID {
            if let fullDraft = DraftManager.shared.loadAll().first(where: { $0.id == draftId }) {
                tabStore.appendToCurrentPath(Screen.SafetyInspectionEdit(fullDraft, .partA))
            }
        } else if let apiId = item.apiId {
            switch item.status {
            case .pendingClose:
                let part: SafetyInspectionPart = isEdit ? .partB : .partA
                tabStore.appendToCurrentPath(Screen.SafetyInspectionDetail(viewModel.swacNumber, apiId, part))
            case .closed:
                tabStore.appendToCurrentPath(Screen.SafetyInspectionDetail(viewModel.swacNumber, apiId, .full))
            case .draft:
                break
            }
        }
    }

    private func canEditPartB(_ item: SafetyInspectionItem) -> Bool {
        guard item.status == .pendingClose else { return false }

        let currentUserId = UserSession.shared.profile?.id ?? ""
        return item.submittedBy.caseInsensitiveCompare(currentUserId) == .orderedSame
    }

    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavBarView(
                    type: .backOnly
//                    searchPlaceholder: "safety_inspection_list_placeholder_search_report".localized(),
//                    onFilterTapped: {
//                        showBottomSheet = true
//                    }
                )
                
                ZStack {
                    if viewModel.isLoading && viewModel.swacDetail == nil {
                        ProgressView()
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if viewModel.swacDetail != nil {
                        VStack {
                            VStack(alignment: .leading, spacing: 8) {
                                swacInfoView
                                Text(
                                    "safety_inspection_main_label_total_count"
                                        .localized()
                                        .replacingOccurrences(of: "{R1}", with: "\(filteredInspections.count)")
                                )
                                .appFont(.robotoRegular, size: 14)
                                .foregroundColor(Color.Neutral500)
                                .padding(.horizontal, 16)
                                .frame(maxWidth: .infinity, alignment: .topLeading)

                                SafetyInspectionTabBar
                            }
                            .padding(.top, 16)
//                            .padding(.bottom, 16)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            
                            ScrollView {
                                if filteredInspections.isEmpty {
                                    VStack(spacing: 12) {
                                        Text("general_no_results".localized())
                                            .appFont(.robotoRegular, size: 16)
                                            .foregroundColor(.Neutral500)
                                    }
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 40)
                                } else {
                                    LazyVStack(spacing: 8) {
                                        ForEach(filteredInspections) { inspection in
                                            SafetyInspectionCard(
                                                inspection: inspection,
                                                canEdit: canEditPartB(inspection),
                                                onViewCliecked: { _ in handleItemClick(inspection, isEdit: false) },
                                                onEditClicked: { _ in handleItemClick(inspection, isEdit: true) },
                                                onDraftEditClicked: { _ in handleItemClick(inspection, isEdit: true) }
                                            )
//                                            .onTapGesture { handleItemClick(inspection, isEdit: false) }
                                            .onAppear {
                                                if viewModel.hasReachedEnd(of: inspection) {
                                                    Task {
                                                        await viewModel.loadMoreItems()
                                                    }
                                                }
                                            }
                                            .contentShape(Rectangle())
                                        }

                                        loadingMoreIndicator
                                    }
                                } 
                            }
                            .contentMargins(.horizontal, 16, for: .scrollContent)
                            .contentMargins(.vertical, 16, for: .scrollContent)
                            .refreshable {
                                await viewModel.refreshList()
                            }
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                        .background(Color.white)
                    } else {
                        ProgressView()
                            .scaleEffect(1.5)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    }
                }
            }
            
            // Floating Action Button
            if viewModel.swacDetail != nil && !viewModel.isLoading && canSubmitSafetyInspectionReport {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            tabStore.appendToCurrentPath(Screen.SafetyInspectionNewEntry(viewModel.swacNumber, .partA))
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
        }
        .task {
            await viewModel.loadData(reset: true)
        }
        .onDisappear {
            viewModel.cancelCurrentTask()
        }
        .background(Color.white)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    SafetyInspectionListView(swacNumber: "001D", canSubmitSafetyInspectionReport: true)
        .environmentObject(TabNavigationStore())
        .environmentObject(AppLanguageManager.shared)
        .environmentObject(AlertManager.shared)
}

#Preview("List") {
    ScrollView {
        LazyVStack(spacing: 8) {
            ForEach(SafetyInspectionItem.examples) { inspection in
                SafetyInspectionCard(
                    inspection:inspection,
                    canEdit: true,
                    onViewCliecked: { inspection in
                       
                    },onEditClicked: { inspection in
                      
                    },onDraftEditClicked: { inspection in
                       
                    }
                )
            }
        }
        .padding()
    }
    .background(Color.Neutral100)
}
#endif
