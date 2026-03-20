//
//  SWACDetailWorkerInfoView.swift
//  dsd-swacs-staff
//

import SwiftUI

struct SWACDetailWorkerInfoView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    @StateObject private var viewModel: SWACDetailWorkerInfoViewModel
    
    let attendance: Attendance
    
    init(attendance: Attendance) {
        self.attendance = attendance
        _viewModel = StateObject(wrappedValue: SWACDetailWorkerInfoViewModel(
            memberID: attendance.memberID,
            memberName: attendance.member
        ))
    }
    
    // MARK: - attendanceInfoView
    
    var attendanceInfoView: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .top, spacing: 24) {
                InfoRowView(
                    title: "staff_card_label_name".localized(),
                    value: attendance.member
                )
                InfoRowView(
                    title: "staff_card_label_role".localized(),
                    value: attendance.memberRole
                )
            }
            
            HStack(alignment: .top, spacing: 24) {
                InfoRowView(
                    title: "staff_card_label_mobile_phone_number".localized(),
                    value: viewModel.isLoadingWorkerInfo ? "" : viewModel.phoneNumber
                )
            }
        }
    }
    
    // MARK: - headerView
    
    var headerView: some View {
        Text("swac_detail_worker_info_label_sign_in_out_record".localized())
            .appFont(.robotoBold, size: 18)
            .foregroundColor(.Neutral800)
    }
    
    // MARK: - attendanceList
    var attendanceList: some View {
        LazyVStack(spacing: 12) {
            if viewModel.isLoadingRecords && viewModel.attendanceRecords.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            }
            else if !viewModel.isLoadingRecords && viewModel.attendanceRecords.isEmpty {
                Text("attendance_detail_label_no_record".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.Neutral500)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            }
            else {
                ForEach(viewModel.attendanceRecords, id: \.uniqueID) { attendance in
                    let isLastItem = attendance.id == viewModel.attendanceRecords.last?.id
                    
                    WorkerInfoRecord(attendance: attendance)
                        .onAppear {
                            if isLastItem {
                                Task {
                                    await viewModel.loadMoreRecords()
                                }
                            }
                        }
                }
                
                if viewModel.isLoadingMore {
                    HStack(spacing: 12) {
                        ProgressView()
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                }
                
                if !viewModel.hasMorePages && !viewModel.attendanceRecords.isEmpty && !viewModel.isLoadingMore {
                    Text("general_no_more_data".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                }
            }
        }
        .padding(.bottom, 32)
    }
    
    // MARK: - bottomButton
    var bottomButton: some View {
        VStack(spacing: 0) {
            CommonButton(
                title: "swac_detail_worker_info_label_dial_staff".localized(),
                style: .contained,
                enabled: viewModel.canMakePhoneCall,
                maxWidth: .infinity,
                icon: Image("icon-phone")
            ) {
                viewModel.makePhoneCall()
            }
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
        }
        .background(Color.white)
    }
    
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(
                type: .backOnly,
                title: "swac_detail_worker_info_label_staff_detail".localized()
            )
            
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        attendanceInfoView
                        
                        VStack(alignment: .leading, spacing: 12) {
                            headerView
                            attendanceList
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 24)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                }
                .refreshable {
                    await viewModel.refreshData()
                }
                bottomButton
            }
            .background(Color.white)
        }
        .task {
            await viewModel.loadInitialData()
        }
        .onDisappear {
            viewModel.cancelCurrentTasks()
        }
        .background(Color.white)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    SWACDetailWorkerInfoView(attendance: Attendance.signedInExample)
        .environmentObject(TabNavigationStore())
}
#endif
