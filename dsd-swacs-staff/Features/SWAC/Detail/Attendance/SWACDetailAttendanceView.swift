//
//  SWACDetailAttendanceView.swift
//  dsd-swacs-staff
//

import SwiftUI

struct SWACDetailAttendanceView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    @ObservedObject var viewModel: SWACDetailAttendanceViewModel
    
    init(viewModel: SWACDetailAttendanceViewModel) {
        self.viewModel = viewModel
    }
    
    init(swacNumber: String) {
        self.viewModel = SWACDetailAttendanceViewModel(
            swacNumber: swacNumber,
            selectedDate: Date()
        )
    }
    
    var attendanceInfoView: some View {
        let memberTotalCount = viewModel.memberTotalCount
        let signedOutMemberCount = viewModel.signedOutMemberCount

        return VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(spacing: 6) {
                    Text("\(memberTotalCount)")
                        .appFont(.robotoBold, size: 24)
                        .foregroundColor(Color.Primary500)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .top)
                    Text("swac_detail_label_signed_in".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(Color.Neutral500)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                Divider().frame(height: 47)
                
                VStack(spacing: 6) {
                    Text("\(signedOutMemberCount)/\(memberTotalCount)")
                        .appFont(.robotoBold, size: 24)
                        .foregroundColor(signedOutMemberCount == memberTotalCount ? .Primary500 : Color.notificationRed)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .top)
                    
                    Text("swac_detail_label_signed_out".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(Color.Neutral500)
                        .multilineTextAlignment(.center)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: Color.Primary100, location: 0.00),
                    Gradient.Stop(color: .white, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.5)
            )
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(Color.Neutral200, lineWidth: 1)
        )
    }
    
    var headerView: some View {
        let calendar = Calendar.current
        let isToday = calendar.isDateInToday(viewModel.selectedDate)
        
        let dateText: String = {
            let baseDate = viewModel.selectedDate.toString(format: "yyyy-MM-dd")
            if isToday {
                return baseDate + " (\("attendance_detail_label_today".localized()))"
            } else {
                return baseDate
            }
        }()
        
        return HStack {
            Text(dateText)
                .appFont(.robotoBold, size: 18)
                .foregroundColor(.Neutral800)
            
            Text("attendance_detail_label_total_count".localized().replacingOccurrences(of: "{R1}", with: "\(viewModel.totalCount)"))
                .appFont(.robotoRegular, size: 14)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.Neutral500)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
    }

    var attendanceList: some View {
        LazyVStack(spacing: 8) {
            if viewModel.isLoading && viewModel.attendanceRecords.isEmpty {
                ProgressView()
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 40)
            }
            else if !viewModel.isLoading && viewModel.attendanceRecords.isEmpty {
                VStack {
                    Text("attendance_detail_label_no_record".localized())
                        .appFont(.robotoBold, size: 14)
                        .foregroundColor(Color.Neutral500)
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 40)
            }
            else {
                ForEach(viewModel.attendanceRecords, id: \.uniqueID) { attendance in
                    let isLastItem = attendance.id == viewModel.attendanceRecords.last?.id
                    
                    StaffCard(attendance: attendance)
                        .onTapGesture {
                            tabStore.appendToCurrentPath(Screen.swacWorkerInfo(attendance))
                        }
                        .contentShape(Rectangle())
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
    }
    
    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    attendanceInfoView
                    VStack(alignment: .leading, spacing: 8) {
                        headerView
                        attendanceList
                    }
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .background(Color.white)
            }
            .contentMargins(.horizontal, 16, for: .scrollContent)
            .contentMargins(.bottom, 32, for: .scrollContent)
            .refreshable {
                await viewModel.refreshRecords()
            }
        }
        .task {
            await viewModel.fetchAttendanceRecords()
        }
        .onDisappear {
            viewModel.cancelCurrentTask()
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    let vm = SWACDetailAttendanceViewModel(swacNumber: "008E", selectedDate: Date())
    return SWACDetailAttendanceView(viewModel: vm)
        .environmentObject(TabNavigationStore())
}
#endif
