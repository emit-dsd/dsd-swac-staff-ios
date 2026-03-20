//
//  SafetyInspectionItem.swift
//  dsd-swacs-staff
//
//  Created by Andy on 20/11/2025.
//

import Foundation
import SwiftUI

// MARK: - Checklist Status Enum

enum SafetyInspectionPart: String, Codable {
    case partA
    case partB
    case full // 用於 Closed 狀態下檢視全部
}

enum SafetyInspectionStatus: Int, Codable, CaseIterable, Hashable {
    case draft = 0
    case pendingClose = 1
    case closed = 2
    
    var color: Color {
        switch self {
        case .draft: return Color.Neutral500
        case .pendingClose: return Color.orange
        case .closed: return Color.Primary800
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .draft: return .Neutral200
        case .pendingClose: return Color(hex: "FFFBF5")
        case .closed: return Color(hex: "F6FCFF")
        }
    }
    
    var displayText: String {
        switch self {
        case .draft: return "safety_inspection_status_label_draft".localized()
        case .pendingClose: return "safety_inspection_status_label_pending_close".localized()
        case .closed: return "safety_inspection_status_label_closed".localized()
        }
    }
}

// MARK: - Domain Model (for UI)
struct SafetyInspectionItem: Identifiable, Equatable {
    // MARK: - Internal Identity
    let apiId: Int?        // ID from API (Optional, as Drafts do not have this)
    let draftUUID: UUID?   // ID from Local Draft (Optional, as API Items do not have this)
    
    // MARK: - Standard Properties
    let swac: String
    let worksDetail: String
    let confinedSpaceType: String
    let reportTime: Date?
    let submissionTime: Date?
    let submittedBy: String
    let status: SafetyInspectionStatus
    
    // MARK: - Identifiable Compliance
    // Unique identifier for SwiftUI ForEach
    // Logic: Use UUID string if available, otherwise fallback to API ID string
    var id: String {
        if let uuid = draftUUID {
            return "draft-\(uuid.uuidString)"
        } else if let apiid = apiId {
            return "api-\(apiid)"
        }
        return UUID().uuidString
    }
    
    // MARK: - Display Helpers
    var displayReportNumber: String {
        if status == .draft {
            return "-" // Do not show ID for drafts
        } else if let aid = apiId {
            return String(aid) // Show ID for submitted items
        }
        return "-"
    }
    
    // MARK: - Computed Properties
    var formattedInspectionDate: String {
        guard let date = reportTime else { return "-" }
        return date.toString(format: "yyyy-MM-dd HH:mm")
    }
    
    var formattedCreatedDate: String {
        guard let date = submissionTime else { return "-" }
        return date.toString(format: "yyyy-MM-dd HH:mm")
    }
    
    // MARK: - Initializer
    // Standard initializer for testing or manual creation
    init(
        id: Int,
        swac: String,
        worksDetail: String,
        confinedSpaceType: String,
        reportTime: Date?,
        submissionTime: Date?,
        submittedBy: String,
        status: SafetyInspectionStatus
    ) {
        self.apiId = id
        self.draftUUID = nil
        self.swac = swac
        self.worksDetail = worksDetail
        self.confinedSpaceType = confinedSpaceType
        self.reportTime = reportTime
        self.submissionTime = submissionTime
        self.submittedBy = submittedBy
        self.status = status
    }
    
    // Initialize from API Response
    init(from apiItem: SafetyInspectionListItemResponse, swacNumber: String) {
        let status: SafetyInspectionStatus = apiItem.isClosed ? .closed : .pendingClose
        
        self.init(
            id: apiItem.id,
            swac: swacNumber,
            worksDetail: apiItem.worksDetail,
            confinedSpaceType: apiItem.confinedSpaceType,
            reportTime: apiItem.reportTime.iso8601Date,
            submissionTime: apiItem.submissionTime.iso8601Date,
            submittedBy: apiItem.submittedBy,
            status: status
        )
    }
    
    // Initialize from Local Draft
    init(from draft: SafetyInspectionDraft) {
        self.apiId = nil
        self.draftUUID = draft.id
        self.swac = draft.swacNumber
        self.worksDetail = draft.workDetails
        self.confinedSpaceType = draft.typeOfConfinedSpace
        self.reportTime = draft.checkingDate
        self.submissionTime = nil
        self.submittedBy = "-"
        self.status = .draft
    }
}


// MARK: - Preview Helpers

#if DEBUG
extension SafetyInspectionItem {
    static let example = SafetyInspectionItem(
        id: 101,
        swac: "001D",
        worksDetail: "Title",
        confinedSpaceType: "",
        reportTime: Date().addingTimeInterval(-86400),
        submissionTime: Date().addingTimeInterval(-86400),
        submittedBy: "user1",
        status: .closed
    )
    
    static let submittedExample = SafetyInspectionItem(
        id: 102,
        swac: "001D",
        worksDetail: "Title",
        confinedSpaceType: "",
        reportTime: Date().addingTimeInterval(-86400),
        submissionTime: Date().addingTimeInterval(-86400),
        submittedBy: "user1",
        status: .pendingClose
    )
    
    static let examples: [SafetyInspectionItem] = [
        example,
        submittedExample
    ]
}
#endif
