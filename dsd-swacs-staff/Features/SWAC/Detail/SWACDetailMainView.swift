//
//  SWACDetailMainView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/8/2025.
//

import SwiftUI

struct SWACDetailMainView: View {
    @EnvironmentObject var alertManager: AlertManager
    @StateObject private var viewModel: SWACDetailViewModel
    @StateObject private var attendanceViewModel: SWACDetailAttendanceViewModel
    @State private var selectedTab: SWACDetailTab = .profile
    @State private var showDateFilter = false
    @State private var showRemarkSheet = false
    @State private var isApproveAction = true
    
    // Initialize with SWAC number
    init(swacNumber: String) {
        print("SWACDetailMainView init with number: \(swacNumber)")
        _viewModel = StateObject(wrappedValue: SWACDetailViewModel(swacNumber: swacNumber))
        _attendanceViewModel = StateObject(wrappedValue: SWACDetailAttendanceViewModel(
            swacNumber: swacNumber,
            selectedDate: Date()
        ))
    }
    
    enum SWACDetailTab: String, CaseIterable {
        case profile = "swac_detail_tab_button_profile"
        case attendance = "swac_detail_tab_button_attendance"
    }
    
    private var availableTabs: [SWACDetailTab] {
        guard let swacDetail = viewModel.swacDetail else {
            return [.profile]  // 默認只顯示 profile
        }
        
        // 只有 approved 狀態才顯示 attendance tab
        if swacDetail.status == .approved {
            return SWACDetailTab.allCases
        } else {
            return [.profile]
        }
    }
    
    private var navBarType: NavBarType {
        switch selectedTab {
        case .profile:
            return .backOnly
        case .attendance:
            return .filterDate
        }
    }
    
    var segmentBar: some View {
        HStack(spacing: 0) {
            ForEach(availableTabs, id: \.self) { tab in
                SegmentControlButton(
                    title: tab.rawValue.localized(),
                    isSelected: selectedTab.rawValue == tab.rawValue,
                    action: { selectedTab = tab }
                )
            }
        }
        .padding(.horizontal, 16)
    }
    
    var bottomView: some View {
        VStack(alignment: .leading, spacing: 12) {
            CommonButton(
                title: "swac_detail_button_approve".localized(),
                style: .contained,
                enabled: true,
                maxWidth: .infinity
            ) {
                isApproveAction = true
                showRemarkSheet = true
            }
            
            CommonButton(
                title: "swac_detail_button_reject".localized(),
                style: .outlined,
                enabled: true,
                maxWidth: .infinity,
                textColor: .red,
                backgroundColor: .red
            ) {
                isApproveAction = false
                showRemarkSheet = true
            }
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    private func showSuccessAlert(isApprove: Bool) {
        alertManager.show(
            title: isApprove ? "swac_detail_alertTitle_vetting_passed".localized() : "swac_detail_alertTitlevetting_failed_hint".localized(),
            message: isApprove ? "swac_detail_alertMessage_vetting_passed_hint".localized() : "swac_detail_alertMessage_vetting_failed_hint".localized(), // 可以換成您需要的文案 key
            image: isApprove ? "icon-alert-success" : "icon-alert-fail",
            buttons: [
                CommonButtonModel(
                    title: "general_back".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        
                    }
                )
            ]
        )
    }

    var body: some View {
        VStack(spacing: 0) {
            // Navigation bar
            CustomNavBarView(
                type: navBarType,
                title: viewModel.swacDetail?.contractor ?? "",
                onFilterTapped: {
                    showDateFilter = true
                }
            )
            
            // Content area
            ZStack {
                if viewModel.isLoading {
                    VStack {
//                        ProgressView()
//                            .scaleEffect(1.5)
//                        Text("Loading SWAC details...")
//                            .appFont(.robotoRegular, size: 14)
//                            .foregroundColor(.Neutral500)
//                            .padding(.top, 16)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let swacDetail = viewModel.swacDetail {
                    VStack(spacing: 0) {
                        VStack(alignment: .leading, spacing: 12) {
                            segmentBar
                            
                            // Tab Content
                            Group {
                                switch selectedTab {
                                case .profile:
                                    SWACDetailProfileView(swacDetail: swacDetail)
                                        .background(.clear)
                                case .attendance:
                                    SWACDetailAttendanceView(viewModel: attendanceViewModel)
                                }
                            }
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                        }
                        .padding(.top, 12)
                        .padding(.bottom, 0)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                        .background(selectedTab == .profile ? Color.Neutral100 : Color.white)
                        
                        if selectedTab == .profile && swacDetail.status == .vetting {
                            bottomView
                        }
                    }
                    if viewModel.isSubmitting || viewModel.isLoading {
                        ZStack {
                            Color.white.opacity(0.6) // 半透明白色背景，防誤觸並降低對比
                                .ignoresSafeArea()
                            
                            ProgressView()
                                .scaleEffect(1.5)
                        }
                    }
                } else {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.white)
        .commonBottomSheet(isPresented: $showDateFilter, detents: [.height(306)]) {
            CustomDateFilterBottomSheetView(
                isPresented: $showDateFilter,
                mode: .singleDate,
                singleDate: attendanceViewModel.selectedDate,
                onApply: { result in
                    if result.singleDate == nil{
                        Task {
                            await attendanceViewModel.updateDate(Date())
                        }
                    } else if let date = result.singleDate {
                        Task {
                            await attendanceViewModel.updateDate(date)
                        }
                    }
                }
            )
        }
        .commonBottomSheet(isPresented: $showRemarkSheet, detents: [.height(320)]) {
            SafetyVettingRemarkBottomSheetView(
                isPresented: $showRemarkSheet,
                isApprove: $isApproveAction,
                onConfirm: { remarks in
                    Task {
                        let success = await viewModel.submitSafetyVetting(isApprove: isApproveAction, remarks: remarks)
                        if success {
                            showSuccessAlert(isApprove: isApproveAction)
                        }
                    }
                }
            )
        }
        .task {
            print("Task triggered, calling fetchDetail")
            await viewModel.fetchDetail()
        }
    }
}

#if DEBUG
#Preview {
    SWACDetailMainView(swacNumber: "0092")
}
#endif
