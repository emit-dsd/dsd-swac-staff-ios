//
//  IncidentReportListView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 9/2/2026.
//

import SwiftUI

struct IncidentReportListView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    
    @StateObject private var viewModel = IncidentReportListViewModel()
    
    // UI State
    @State private var showBottomSheet = false
    @State private var startDate = Date()
    @State private var endDate = Date()
    
    private func handleItemClick(_ report: IncidentReport) {
        tabStore.appendToCurrentPath(Screen.IncidentReportDetail(report.id, .fromList))
        print("Tapped Incident ID: \(report.id)")
    }
    
    // MARK: - Subviews
    
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
        
        if !viewModel.hasMorePages && !viewModel.incidentReport.isEmpty && !viewModel.isLoadingMore {
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
                     tabStore.appendToCurrentPath(Screen.IncidentReport)
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
    
    var navBar: some View {
        CustomNavBarView(
            type: .backOnly,
            title: "incident_report_list_label_tiltle".localized()
        )
    }
    
    var loadingView: some View {
        VStack {
            ProgressView()
                .scaleEffect(1.5)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Content Views
    
    var mainContentView: some View {
        Group {
            if viewModel.isLoading && viewModel.incidentReport.isEmpty {
                loadingView
            } else {
                mainContent
            }
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 0) {
            
            // Header Info
            VStack(alignment: .leading, spacing: 8) {
                Text("incident_report_list_label_header".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(Color.Neutral800)
                Text("incident_report_list_label_total_count".localized().replacingOccurrences(of: "{R1}", with: "\(viewModel.incidentReport.count)"))
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Neutral500)
            }
            .padding(.horizontal, 16)
            .padding(.top, 16)
            .padding(.bottom, 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            if viewModel.incidentReport.isEmpty {
                // Empty State
                VStack(spacing: 12) {
                    Text("general_no_results".localized())
                        .appFont(.robotoRegular, size: 16)
                        .foregroundColor(.Neutral500)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 60)
                
            } else {
                // List Data
                ScrollView {
                    LazyVStack(spacing: 8) {
                        ForEach(viewModel.incidentReport) { report in
                            IncidentReportCard(report: report)
                                .onTapGesture {
                                    handleItemClick(report)
                                }
                                .onAppear {
                                    // 偵測是否滑動到底部
                                    if viewModel.hasReachedEnd(of: report) {
                                        Task {
                                            await viewModel.loadMoreItems()
                                        }
                                    }
                                }
                        }
                        
                        loadingMoreIndicator
                    }
                    .padding(.horizontal, 16)
                    .padding(.bottom, 80) // Padding for FAB
                }
                .refreshable {
                    await viewModel.refreshList()
                }
            }
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                navBar
                mainContentView
            }
            
            if !viewModel.isLoading || !viewModel.incidentReport.isEmpty {
                floatingActionButton
            }
        }
        .task {
            await viewModel.loadData()
        }
        .onReceive(NotificationCenter.default.publisher(for: .incidentReportListReload)) { _ in
            Task {
                await viewModel.refreshList()
            }
        }
        .background(Color.white)
    }
}

#if DEBUG
#Preview {
    IncidentReportListView()
}
#endif
