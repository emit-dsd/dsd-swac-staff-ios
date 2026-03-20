//
//  SWACListItem.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/11/2025.
//

import Foundation

struct SWACListItem: Codable, Identifiable, Hashable {
    var id: String { number }
    let number: String
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
}
