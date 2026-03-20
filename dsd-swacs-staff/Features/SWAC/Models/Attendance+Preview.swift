//
//  Attendance+Preview.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import SwiftUI

#if DEBUG
// MARK: - Preview Data ✨
extension Attendance {
    /// 已簽出的記錄
    static let signedOutExample = Attendance(
        id: 1001,
        swac: "008E",
        memberID: 101,
        member: "王永慶",
        memberRole: "Registered Safety Officer",
        signIn: "2025-08-22 08:00:00",
        signOut: "2025-08-22 17:30:00",
        signInType: 1,
        signOutType: 1
    )
    
    /// 已簽入的記錄
    static let signedInExample = Attendance(
        id: 1002,
        swac: "008E",
        memberID: 102,
        member: "李明宇",
        memberRole: "General Worker",
        signIn: "2025-08-22 08:30:00",
        signOut: nil,
        signInType: 2,
        signOutType: nil
    )
    
    /// 未簽到的記錄
    static let noRecordExample = Attendance(
        id: 1003,
        swac: "008E",
        memberID: 103,
        member: "孫雅婷",
        memberRole: "General Worker",
        signIn: nil,
        signOut: nil,
        signInType: nil,
        signOutType: nil
    )
    
    /// 短工時記錄（3小時）
    static let shortDurationExample = Attendance(
        id: 1004,
        swac: "008E",
        memberID: 104,
        member: "周浩然",
        memberRole: "General Worker",
        signIn: "2025-08-22 14:00:00",
        signOut: "2025-08-22 17:00:00",
        signInType: 1,
        signOutType: 2
    )
    
    /// 長工時記錄（9小時）
    static let longDurationExample = Attendance(
        id: 1005,
        swac: "008E",
        memberID: 105,
        member: "黃麗華",
        memberRole: "Supervisor",
        signIn: "2025-08-22 08:00:00",
        signOut: "2025-08-22 17:00:00",
        signInType: 2,
        signOutType: 2
    )
    
    /// 預覽用的完整數據集
    static let previews: [Attendance] = [
        signedOutExample,
        signedInExample,
        noRecordExample,
        shortDurationExample,
        longDurationExample,
        Attendance(
            id: 1006,
            swac: "008E",
            memberID: 106,
            member: "吳俊杰",
            memberRole: "General Worker",
            signIn: "2025-08-22 09:00:00",
            signOut: "2025-08-22 12:30:00",
            signInType: 1,
            signOutType: 1
        ),
        Attendance(
            id: 1007,
            swac: "008E",
            memberID: 107,
            member: "鄧小雨",
            memberRole: "General Worker",
            signIn: "2025-08-22 10:00:00",
            signOut: nil,
            signInType: 2,
            signOutType: nil
        ),
        Attendance(
            id: 1008,
            swac: "008E",
            memberID: 108,
            member: "陳大明",
            memberRole: "Safety Officer",
            signIn: "2025-08-22 07:30:00",
            signOut: "2025-08-22 18:00:00",
            signInType: 1,
            signOutType: 1
        ),
        Attendance(
            id: 1009,
            swac: "008E",
            memberID: 109,
            member: "劉小芳",
            memberRole: "General Worker",
            signIn: nil,
            signOut: nil,
            signInType: nil,
            signOutType: nil
        ),
        Attendance(
            id: 1010,
            swac: "008E",
            memberID: 110,
            member: "張德華",
            memberRole: "General Worker",
            signIn: "2025-08-22 08:15:00",
            signOut: "2025-08-22 16:45:00",
            signInType: 2,
            signOutType: 2
        )
    ]
}

// MARK: - Mock 數據
let mockAttendancesList: [Attendance] = Attendance.previews

// MARK: - Preview 定義
#Preview("StaffCard - 已簽出") {
    StaffCard(attendance: .signedOutExample)
        .padding()
}

#Preview("StaffCard - 已簽入") {
    StaffCard(attendance: .signedInExample)
        .padding()
}

#Preview("StaffCard - 未簽到") {
    StaffCard(attendance: .noRecordExample)
        .padding()
}

#Preview("StaffCard - 短工時") {
    StaffCard(attendance: .shortDurationExample)
        .padding()
}

#Preview("StaffCard - 長工時") {
    StaffCard(attendance: .longDurationExample)
        .padding()
}

#Preview("StaffCard - 混合列表") {
    VStack(spacing: 12) {
        StaffCard(attendance: .signedOutExample)
        StaffCard(attendance: .signedInExample)
        StaffCard(attendance: .noRecordExample)
    }
    .padding()
}

#Preview("AttendanceListView - 完整") {
    SWACDetailAttendanceView(swacNumber: "008E")
        .environmentObject(TabNavigationStore())
}

#endif

