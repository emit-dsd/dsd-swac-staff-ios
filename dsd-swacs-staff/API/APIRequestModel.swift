//
//  Login.swift
//  dsd-swacs-staff
//
//  Created by Andy on 22/10/2025.
//

import Foundation

struct StaffLoginRequest: Codable {
    let loginName: String
    let password: String
}

struct NotificationListRequest: Codable {
    let page: Int
    let pageSize: Int
}

struct SwacListRequest: Codable {
    let page: Int
    let pageSize: Int
    let state: Int?
}

struct SwacSearchRequest: Codable {
    let page: Int
    let pageSize: Int
    let state: Int?
    let number: String?
    let startDate: String?
    let finishDate: String?
    let isSiteWorkRegistered: Bool?
}

struct AttendanceListRequest: Codable {
    let swac: String
    let date: String
    let page: Int
    let pageSize: Int
    
    init(swac: String, date: Date, page: Int = 1, pageSize: Int = 20) {
        self.swac = swac
        self.date = Self.dateFormatter.string(from: date)
        self.page = page
        self.pageSize = pageSize
    }
    
    init(swac: String, date: String, page: Int = 1, pageSize: Int = 20) {
        self.swac = swac
        self.date = date
        self.page = page
        self.pageSize = pageSize
    }
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone.current
        return formatter
    }()
}

struct AttendanceMemberRequest: Codable {
    let memberID: Int
    let page: Int
    let pageSize: Int
    
    init(memberID: Int, page: Int = 1, pageSize: Int = 20) {
        self.memberID = memberID
        self.page = page
        self.pageSize = pageSize
    }
}

struct IncidentReportListRequest: Codable {
    let page: Int
    let pageSize: Int
}

struct IncidentReportRequest: Codable {
    let occurenceTime: String  // ISO 8601 format: "2025-11-17T00:31:29.331Z"
    let swac: String
    let location: String
    let brief: String
    let hasCasualty: Bool
    let hasMedia: Bool
    let hasParamedic: Bool
    let hasFirefighter: Bool
    let hasPoliceOfficer: Bool
    let contactPerson: String
    let contractor: String
}

struct SiteDiarySubmissionRequest {
    let instruction: String
    let response: String
    let swac: String
    let weather: Int
    let workActivity: String
    let date: String // Format: "2025-12-08"
    let approver: String
    let attachments: [SiteDiaryAttachment]
    let attachmentFiles: [Data] // AttachmentData
}

struct SiteDiaryAttachment {
    let subject: String
    let remarks: String?
}

struct SiteDiaryListRequest: Codable {
    let swac: String
    let page: Int
    let pageSize: Int
    let startDate: String?
    let endDate: String?
    let state: [Int]?
    let workActivity: String?
}

struct SafetyInspectionListRequest: Codable {
    let page: Int
    let pageSize: Int
    let swac: String
    let isClosed: Bool?
}
