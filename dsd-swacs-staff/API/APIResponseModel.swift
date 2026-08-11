//
//  Login.swift
//  dsd-swacs-staff
//
//  Created by Andy on 22/10/2025.
//

import Foundation

struct EmptyResponse: Codable {}

struct StaffLoginResponse: Codable {
    let token: String
    let profile: UserProfile
    
    struct UserProfile: Codable {
        let id: String
        let nameEng: String
        let nameChi: String?
        let post: String
        let officePhone: String?
        let mobile: String
        let email: String
        let division: String
        let roles: [String]
        let language: Int?
    }
}

struct NotificationItemResponse: Codable, Identifiable {
    let id: Int
    let topic: String
    let content: String
    let isRead: Bool
    let sender: String
    let sentTime: String
}

struct StaffSignInOutResponse: Codable {
    let swac: String
    let company: String
    let member: String
    let memberRole: String
}

struct InspectAccessCodeResponse: Codable {
    let swac: String
    let contractor: String
    let workingTeamMember: String
    let startTime: String
    let finishTime: String
    let memberRole: String
    let location: String
}

struct SWACListItemResponse: Codable {
    let number: String
    let contractNumber: String?
    let contractor: String?
    let contractTitle: String
    let worksOrderNumber: String?
    let isConfinedSpaceWorks: Bool
    let startTime: String
    let finishTime: String
    let state: Int
    let needSiteWorkStartApproval: Bool
    let canSubmitSafetyInspectionReport: Bool
    let siteWorkID: Int?
    let siteWorkstate: Int?
}

struct SWACDetailResponse: Codable {
    let number: String
    let contractNumber: String?
    let contractTitle: String?
    let worksOrderNumber: String?
    let isConfinedSpaceWorks: Bool?
    let startTime: String?
    let finishTime: String?
    let state: Int
    let createTime: String?
    let submitTime: String?
    let contractor: String?
    let contractorID: String?
    let contratcorPhone: String?  // Note: API has typo "contratcor"
    let projectInCharge: String?
    let siteInCharge: String?
    let location: String?
    let worksDetails: String?
    let regionalControlCentreEng: String?
    let regionalControlCenterChi: String?
    let latitude: Double?
    let longitude: Double?
    let regionalControlCentre: Int?
}

struct SiteWorkProfileResponse: Codable {
    let id: Int
    let ticket: Int?
    let regionalControlCentre: Int
    let swac: String?
    let company: String?
    let date: String?
    let location: String?
    let isConfinedSpaceWork: Bool
    let siteInCharge: String?
    let targetFinishTime: String?
    let state: Int
}

struct AttendanceRecordResponse: Identifiable, Codable {
    let id: Int
    let swac: String
    let memberID: Int
    let member: String
    let memberRole: String
    let signIn: String?
    let signOut: String?
    let signInType: Int?
    let signOutType: Int?
}

struct WorkingTeamMemberResponse: Codable {
    let accessCode: String
    let name: String
    let phone: String
    let swac: String
}

struct IncidentReportResponse: Codable, Identifiable {
    let id: Int
    let occurenceTime: String
    let swac: String?
    let location: String?
    let brief: String?
    
    let hasCasualty: Bool
    let hasMedia: Bool
    let hasParamedic: Bool
    let hasFirefighter: Bool
    let hasPoliceOfficer: Bool
    
    let contactPerson: String?
    let contractor: String?
    let submittedBy: String?
    let submissionTime: String
    
    let attachment: [String]?
}

struct SiteDiaryListItemResponse: Decodable, Identifiable {
    let id: Int
    let swac: String
    let approver: String?
    let date: String  // "2025-12-10"
    let weatherAM: Int?
    let weatherPM: Int?
    let labour: Int?
    let workActivity: String
    let instruction: String?
    let response: String?
    let state: Int  // 1-5
    let attachment: [String]
    let siteInCharge: String?
    let contractor: String?
}

struct SiteDiaryDetailResponse: Decodable, Identifiable {
    let id: Int
    let swac: String
    let approver: String?
    let date: String  // "2025-12-10"
    let weatherAM: Int?
    let weatherPM: Int?
    let labour: Int?
    let workActivity: String
    let instruction: String?
    let response: String?
    let state: Int  // 1-5
    let attachment: [String]
    let siteInCharge: String?
    let contractor: String?
}

struct StaffApproverResponse: Codable {
    let id: String
    let nameEng: String?
    let nameChi: String?
    let post: String?
    let officePhone: String?
    let mobile: String?
    let email: String?
    let division: String?
    let roles: [String]?
    
    var displayName: String {
        if let eng = nameEng, let chi = nameChi, !eng.isEmpty, !chi.isEmpty {
            return "\(eng) \(chi)"
        }
        return nameEng ?? nameChi ?? id
    }
}

struct SafetyInspectionListItemResponse: Codable, Identifiable {
    let id: Int
    let reportTime: String // e.g. "2026-01-06T11:13:48"
    let worksDetail: String
    let confinedSpaceType: String
    let attachment: [String]
    let submittedBy: String
    let submissionTime: String // e.g. "2026-01-06T11:07:44.743"
    let swac: String
    let cswr: Int?
    let isClosed: Bool
}

struct SafetyInspectionDetailResponse: Codable {
    let id: Int
    let reportTime: String
    let worksDetail: String
    let confinedSpaceType: String
    let attachment: [String]
    let submittedBy: String
    let submissionTime: String
    let swac: String
    let result: [SafetyInspectionChecklistResult]
}

struct SafetyInspectionChecklistResult: Codable, Hashable {
    let category: Int
    let text: String?
    let number: Int?
    let boolean: Int? // 1: Yes, 0: No, 2: N/A
    let option: Int?
    let remarks: String?
}

struct DocumentContentItemResponse: Codable {
    let profile: DocumentContentProfileResponse
    let data: DocumentContentDataResponse
}

struct DocumentContentProfileResponse: Codable {
    let subject: String?
    let category: Int?
    let createDate: String?
    let remarks: String?
}

struct DocumentContentDataResponse: Codable {
    let content: String          // base64 string
    let fileExtension: String
    let fileName: String
    let size: Int

    var fileData: Data? {
        Data(base64Encoded: content)
    }

    var cleanFileExtension: String {
        fileExtension.replacingOccurrences(of: ".", with: "")
    }
}

struct ReleaseNotes: Codable, Equatable {
    let version: String
    let summaryEn: String
    let summaryTc: String
    let summarySc: String
    let url: String
}
