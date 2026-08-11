//
//  SWACListItem.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/11/2025.
//

import Foundation

enum SiteWorkState: Int, CaseIterable {
    case pendingForEndorsement = 1
    case pendingForAcknowledgement = 2
    case pendingForMPS2Acknowledgement = 3
    case pendingForSafetyInspection = 4
    case pendingForApproval = 5
    case confirmedEntry = 6
    case pendingForMPS1Checkout = 7
    case completed = 8
    case rejected = 9
    case recessInProgress = 10

    var localizationKey: String {
        switch self {
        case .pendingForEndorsement:
            return "cswr_status_label_pending_for_endorsement"
        case .pendingForAcknowledgement:
            return "cswr_status_label_pending_for_acknowledgement"
        case .pendingForMPS2Acknowledgement:
            return "cswr_status_label_pending_for_mps2_acknowledgement"
        case .pendingForSafetyInspection:
            return "cswr_status_label_pending_for_safety_inspection"
        case .pendingForApproval:
            return "cswr_status_label_pending_for_approval"
        case .confirmedEntry:
            return "cswr_status_label_confirmed_entry"
        case .pendingForMPS1Checkout:
            return "cswr_status_label_pending_for_mps1_checkout"
        case .completed:
            return "cswr_status_label_completed"
        case .rejected:
            return "cswr_status_label_rejected"
        case .recessInProgress:
            return "cswr_status_label_recess_in_progress"
        }
    }
}

struct SWACListItem: Codable, Identifiable, Hashable {
    var id: String { number }
    let number: String
    let ticket: Int?
    let contractNumber: String
    let contractor: String
    let contractTitle: String
    let worksOrderNumber: String?
    let isConfinedSpaceWorks: Bool
    let startTime: Date
    let finishTime: Date
    let state: Int
    let needSiteWorkStartApproval: Bool
    let canSubmitSafetyInspectionReport: Bool
    let siteWorkID: Int
    let siteWorkstate: Int
    
    var status: SWACStatus {
        return SWACStatus(stateInt: state) ?? .draft
    }
    
    var uniqueID: String {
        "\(self.hashValue)"
    }
    
    init(from response: SWACListItemResponse) {
        self.number = response.number
        self.ticket = nil
        self.contractNumber = response.contractNumber ?? ""
        self.contractor = response.contractor ?? ""
        self.contractTitle = response.contractTitle
        self.worksOrderNumber = response.worksOrderNumber
        self.isConfinedSpaceWorks = response.isConfinedSpaceWorks
        self.state = response.state
        
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        self.startTime = formatter.date(from: response.startTime) ?? Date()
        self.finishTime = formatter.date(from: response.finishTime) ?? Date()
        self.needSiteWorkStartApproval = response.needSiteWorkStartApproval
        self.canSubmitSafetyInspectionReport = response.canSubmitSafetyInspectionReport
        self.siteWorkID = response.siteWorkID ?? 0
        self.siteWorkstate = response.siteWorkstate ?? 0
    }
    
    init(from response: SWACDetailResponse) {
        self.number = response.number
        self.ticket = nil
        self.contractNumber = response.contractNumber ?? ""
        self.contractor = response.contractor ?? ""
        self.contractTitle = response.contractTitle ?? ""
        self.worksOrderNumber = response.worksOrderNumber
        self.isConfinedSpaceWorks = response.isConfinedSpaceWorks ?? false
        self.state = response.state
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        self.startTime = formatter.date(from: response.startTime ?? "") ?? Date()
        self.finishTime = formatter.date(from: response.finishTime ?? "") ?? Date()
        
        // Detail API 回傳嘅無呢啲欄位，唯有填預設值
        self.needSiteWorkStartApproval = false
        self.canSubmitSafetyInspectionReport = false
        self.siteWorkID = 0
        self.siteWorkstate = 0
    }
    
    init(from siteWork: SiteWorkProfileResponse) {
        self.number = siteWork.swac ?? ""
        self.ticket = siteWork.ticket
        
        self.contractNumber = "-"
        self.worksOrderNumber = "-"
        self.contractTitle = "-"
        
        self.contractor = siteWork.company ?? ""
        self.isConfinedSpaceWorks = siteWork.isConfinedSpaceWork
        self.state = 5
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        self.startTime = formatter.date(from: siteWork.date ?? "") ?? Date()
        self.finishTime = formatter.date(from: siteWork.targetFinishTime ?? "") ?? Date()
        
        self.needSiteWorkStartApproval = false
        self.canSubmitSafetyInspectionReport = false
        self.siteWorkID = siteWork.id
        self.siteWorkstate = siteWork.state
    }
}
