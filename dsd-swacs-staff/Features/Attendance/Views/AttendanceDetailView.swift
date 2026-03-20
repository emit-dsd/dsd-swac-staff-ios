//
//  AttendanceDetailView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/8/2025.
//

import SwiftUI

struct AttendanceDetailView: View {
    enum SheetMode {
        case signIn
        case signOut
    }
    @State private var showSheet = false
    @State private var sheetMode: SheetMode = .signIn
    @State private var allCandidates: [SelectableAttendance] = []
    @State private var displayedCandidates: [SelectableAttendance] = []
    
    let siteWork: SiteWork
#if DEBUG
    let mockAttendances = mockAttendancesList
#else
    let mockAttendances: [Attendance] = []
#endif
    
    
    init(siteWork: SiteWork) {
        self.siteWork = siteWork
        let mapped = mockAttendances.map {
            SelectableAttendance(attendance: $0, isChecked: false)
        }
        self._allCandidates = State(initialValue: mapped)
        self._displayedCandidates = State(initialValue: mapped)
    }
    
    var headerView: some View {
        HStack {
            Text("Today")
                .appFont(.robotoBold, size: 18)
                .foregroundColor(.Neutral800)
            
            Text("attendance_detail_label_total_count".localized().replacingOccurrences(of: "{R1}", with: "\( mockAttendances.count)"))
                .appFont(.robotoRegular, size: 14)
                .multilineTextAlignment(.trailing)
                .foregroundColor(Color.Neutral500)
                .frame(maxWidth: .infinity, alignment: .topTrailing)
        }
    }
    
    var siteInfoView: some View {
        VStack(alignment: .leading, spacing: 12) {
            InfoRowView(title: "site_work_card_label_contract_title".localized(), value: siteWork.contractTitle)
            HStack{
                InfoRowView(title: "site_work_card_label_work_order_no".localized(), value: siteWork.workOrderNo)
                InfoRowView(title: "site_work_card_label_swac_no".localized(), value: siteWork.swacNo)
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.Neutral100)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(Color.Primary500),
            alignment: .leading
        )
    }
    
    var attendanceList: some View{
        ScrollView {
            VStack(spacing: 8) {
                ForEach(mockAttendances, id: \.self) { attendance in
                    StaffCard(attendance: attendance)
                }
            }
            .padding(.bottom, 32)
        }
    }
    
    var bottomButtonView: some View {
        VStack(alignment: .leading, spacing: 12) {
            CommonButton(title: "attendance_detail_button_manual_sign_in".localized(), style: .contained, enabled: true, maxWidth: .infinity) {
                sheetMode = .signIn
                displayedCandidates = allCandidates.filter {
                    $0.attendance.status == .noRecord
                }
                showSheet = true
            }
            CommonButton(title: "attendance_detail_button_manual_sign_out".localized(), style: .outlined, enabled: true, maxWidth: .infinity) {
                sheetMode = .signOut
                displayedCandidates = allCandidates.filter {
                    $0.attendance.status == .signedIn
                }
                showSheet = true
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 16)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    var body: some View {
        VStack(spacing: 0){
            //            bottomSheetView
            CustomNavBarView(type: .searchBar)
            VStack(alignment: .leading, spacing: 8) {
                headerView
                siteInfoView
                attendanceList
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.Neutral100)
            .ignoresSafeArea(edges: .bottom)
            
            bottomButtonView
        }
        .background(Color.white)
        .commonBottomSheet(isPresented: $showSheet, detents:[.height(750)]) {
            ManualSignSheetView(
                sheetMode: sheetMode,
                candidates: $displayedCandidates
            ) { selected in
                print("✅ Ready to call API with \(selected.count) people")
                showSheet = false
            }
        }
    }
}

#if DEBUG
#Preview {
    AttendanceDetailView(
        siteWork: SiteWork(
            contractTitle: "西九龍雨水排放系統改善計劃",
            workOrderNo: "4108CD",
            swacNo: "001D",
            signedIn: 12,
            signedOut: 6,
            totalWorkers: 12
        )
    ).environmentObject(TabNavigationStore())
}

#endif
