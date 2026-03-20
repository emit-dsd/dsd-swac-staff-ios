//
//  SafetyInspectionMainView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 20/11/2025.
//

import SwiftUI

struct SafetyInspectionMainView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    @State private var showAlert = false
    
    @StateObject private var viewModel = SafetyInspectionMainViewModel()
    
    func notificationMain() {
        tabStore.appendToCurrentPath(Screen.notificationMain)
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(
                type: .searchBarWithnotification,
                searchPlaceholder: "safety_inspection_main_placeholder_swac".localized(),
                searchText: $viewModel.searchText,
                onNotificationTapped: notificationMain
            )
            
            ZStack {
                if viewModel.isLoading && viewModel.swacList.isEmpty {
                    VStack {
                        ProgressView()
                            .scaleEffect(1.5)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(alignment: .leading, spacing: 24) {
                        HStack {
                            Text("safety_inspection_main_label_select_swac".localized())
                                .appFont(.robotoBold, size: 18)
                                .foregroundColor(.Neutral800)
                            
                            Text("safety_inspection_main_label_total_count".localized().replacingOccurrences(of: "{R1}", with: "\(viewModel.swacList.count)"))
                                .appFont(.robotoRegular, size: 14)
                                .multilineTextAlignment(.trailing)
                                .foregroundColor(Color.Neutral500)
                                .frame(maxWidth: .infinity, alignment: .topTrailing)
                        }
                        .padding(.horizontal, 16)
                        
                        if viewModel.isLoading && viewModel.swacList.isEmpty {
                            VStack {
                                ProgressView()
                                    .scaleEffect(1.5)
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else if viewModel.swacList.isEmpty {
                            VStack(spacing: 12) {
                                Text("general_no_results".localized())
                                    .appFont(.robotoBold, size: 16)
                                    .foregroundColor(.Neutral500)
                            }
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 60)
                        } else {
                            ScrollView {
                                LazyVStack(spacing: 8) {
                                    ForEach(viewModel.swacList, id: \.uniqueID) { swac in
                                        SafetyInspectionSWACCard(swac: swac)
                                            .onTapGesture {
                                                tabStore.appendToCurrentPath(
                                                    Screen.SafetyInspectionList(
                                                        swac.number,
                                                        swac.canSubmitSafetyInspectionReport
                                                    )
                                                )
                                            }
                                            .onAppear {
                                                if swac.id == viewModel.swacList.last?.id {
                                                    Task {
                                                        await viewModel.loadMoreItems()
                                                    }
                                                }
                                            }
                                    }
                                    
                                    if viewModel.isLoadingMore {
                                        ProgressView()
                                            .frame(maxWidth: .infinity)
                                            .padding(.vertical, 16)
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
                    }
                    .padding(.top, 24)
                    .background(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                }
            }
            .background(Color.white)
        }
        .task {
            guard tabStore.tabSelection == .checklist, viewModel.swacList.isEmpty else { return }
            await viewModel.fetchSWACList(reset: true)
        }
        .onDisappear {
            viewModel.cancelCurrentTask()
        }
        .background(Color.white)
    }
}

#if DEBUG
#Preview {
    SafetyInspectionMainView()
        .environmentObject(TabNavigationStore())
        .environmentObject(NotificationManager.shared)
        .environmentObject(AppLanguageManager.shared)
        .environmentObject(AlertManager.shared)
}
#endif
