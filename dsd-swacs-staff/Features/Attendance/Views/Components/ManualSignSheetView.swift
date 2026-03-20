//
//  ManualSignSheetView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/8/2025.
//

import SwiftUI

struct ManualSignSheetView: View {
    var sheetMode: AttendanceDetailView.SheetMode
    @Binding var candidates: [SelectableAttendance]
    var onSubmit: ([Attendance]) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(sheetMode == .signIn ? "manual_sign_sheet_title_sign_in".localized() : "manual_sign_sheet_title_sign_out".localized())
                .appFont(.robotoBold, size: 18)
                .foregroundColor(Color.black)

            HStack {
                CommonButton(title: "manual_sign_sheet_button_select_all".localized(), style: .text, enabled: true) {
                    for i in candidates.indices {
                        candidates[i].isChecked = true
                    }
                }
                Spacer()
                CommonButton(title: "manual_sign_sheet_button_clear_all".localized(), style: .text, enabled: true, textColor: .red) {
                    for i in candidates.indices {
                        candidates[i].isChecked = false
                    }
                }
            }

            ScrollView {
                LazyVStack(spacing: 12) {
                    ForEach($candidates) { $item in
                        SimpleStaffCard(
                            attendance: item.attendance,
                            isChecked: $item.isChecked
                        )
                    }
                }
            }
            
            CommonButton(
                title: "manual_sign_sheet_button_submit".localized(),
                style: .contained,
                enabled: true,
                maxWidth: .infinity
            ) {
                let selected = candidates.filter { $0.isChecked }.map { $0.attendance }
                onSubmit(selected)
            }
            .padding(.top, 16)
        }
        .padding(.horizontal, 16)
        .padding(.top, 24)
        .padding(.bottom, 0)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.Neutral100)
    }
}
