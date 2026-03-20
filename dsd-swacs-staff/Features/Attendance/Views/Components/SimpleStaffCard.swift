//
//  SimpleStaffCard.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/8/2025.
//

import SwiftUI

struct SelectableAttendance: Identifiable, Hashable {
    var id: UUID = UUID()
    var attendance: Attendance
    var isChecked: Bool
}

struct SimpleStaffCard: View {
    let attendance: Attendance
    @Binding var isChecked: Bool
    
    var checkBox: some View {
        HStack(spacing: 0) {
            if isChecked {
                Image("tick-icon")
                    .resizable()
                    .frame(width: 12, height: 12)
            }
        }
        .padding(4)
        .frame(width: 20, height: 20)
        .background(isChecked ? Color.Primary800 : Color.white)
        .cornerRadius(2)
        .overlay(
            Group {
                if !isChecked {
                    RoundedRectangle(cornerRadius: 2)
                        .inset(by: 0.5)
                        .stroke(Color.Neutral300, lineWidth: 1)
                }
            }
        )
    }
    
    var staffInfoView: some View {
        HStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 2) {
                Text( attendance.member)
                    .appFont(.robotoBold, size: 16)
                    .foregroundColor(Color.Primary800)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Text(attendance.memberRole)
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Neutral500)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
            
            StatusTag(status: attendance.status)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .top)
        .background(Color.Neutral100)
        .cornerRadius(2)
        .overlay(
            RoundedRectangle(cornerRadius: 2)
                .inset(by: 0.5)
                .stroke(Color.Neutral200, lineWidth: 1)
        )
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            checkBox
            staffInfoView
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
        .onTapGesture {
            isChecked.toggle()
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        SimpleStaffCard(attendance: Attendance.signedInExample, isChecked: .constant(true))
        SimpleStaffCard(attendance: Attendance.signedOutExample ,isChecked: .constant(false))
        SimpleStaffCard(attendance: Attendance.longDurationExample,isChecked: .constant(false))
    }
    .padding()
}
#endif
