//
//  Attendance.swift
//  dsd-swacs-staff
//
//  Created by Andy on 8/8/2025.
//

import SwiftUI

enum AttendanceStatus: CaseIterable, Hashable {
    case signedIn
    case signedOut
    case noRecord
    
    var displayText: String {
        switch self {
        case .signedIn: return "staff_card_status_signed_in".localized()
        case .signedOut: return "staff_card_status_signed_out".localized()
        case .noRecord: return "staff_card_status_no_record".localized()
        }
    }
    
    var color: Color {
        switch self {
        case .signedIn: return Color.green
        case .signedOut: return Color.orange
        case .noRecord: return Color.Neutral500
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .signedIn: return Color(hex: "EEFFEE")
        case .signedOut: return Color(hex: "FFFBF5")
        case .noRecord: return Color.Neutral200
        }
    }
    
    var linearGradientColor: Color {
        switch self {
        case .signedIn:
            return Color.Primary100
        case .signedOut:
            return Color(red: 1, green: 0.91, blue: 0.77)
        case .noRecord:
            return Color(red: 0.96, green: 0.96, blue: 0.96)
        }
    }
}

struct Attendance: Identifiable, Hashable, Codable {
    let id: Int
    let swac: String
    let memberID: Int
    let member: String
    let memberRole: String
    let signIn: String?
    let signOut: String?
    let signInType: Int?
    let signOutType: Int?
    
    init(from response: AttendanceRecordResponse) {
        self.id = response.id
        self.swac = response.swac
        self.memberID = response.memberID
        self.member = response.member
        self.memberRole = response.memberRole
        self.signIn = response.signIn
        self.signOut = response.signOut
        self.signInType = response.signInType
        self.signOutType = response.signOutType
    }
    

    init(
        id: Int,
        swac: String,
        memberID: Int,
        member: String,
        memberRole: String,
        signIn: String?,
        signOut: String?,
        signInType: Int?,
        signOutType: Int?
    ) {
        self.id = id
        self.swac = swac
        self.memberID = memberID
        self.member = member
        self.memberRole = memberRole
        self.signIn = signIn
        self.signOut = signOut
        self.signInType = signInType
        self.signOutType = signOutType
    }
    
    // MARK: - 計算屬性
    /// 出勤狀態
    var status: AttendanceStatus {
        if signOut != nil && !signOut!.isEmpty {
            return .signedOut
        } else if signIn != nil && !signIn!.isEmpty {
            return .signedIn
        } else {
            return .noRecord
        }
    }
    
    var uniqueID: String {
        "\(self.hashValue)"
    }
    
    var signInDate: Date? {
        guard let signInStr = signIn, !signInStr.isEmpty else { return nil }
        return Self.dateTimeFormatter.date(from: signInStr)
    }
    
    var signOutDate: Date? {
        guard let signOutStr = signOut, !signOutStr.isEmpty else { return nil }
        return Self.dateTimeFormatter.date(from: signOutStr)
    }
    
    var signInTimeFormatted: String {
        guard let signInStr = signIn, !signInStr.isEmpty,
              let date = Self.dateTimeFormatter.date(from: signInStr) else { return "-" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    var signOutTimeFormatted: String {
        guard let signOutStr = signOut, !signOutStr.isEmpty,
              let date = Self.dateTimeFormatter.date(from: signOutStr) else { return "-" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm:ss"
        return formatter.string(from: date)
    }
    
    var dateFormatted: String {
        guard let signInStr = signIn, !signInStr.isEmpty,
              let date = Self.dateTimeFormatter.date(from: signInStr) else { return "-" }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    

    private static let dateTimeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
    
}
