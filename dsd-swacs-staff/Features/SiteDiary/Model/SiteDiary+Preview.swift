//
//  SiteDiary+Preview.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import Foundation

#if DEBUG

// MARK: - SiteDiary Preview
extension SiteDiary {
    // State 1: Pending DSD Endorsement (Action Required)
    static let previewPendingDSDEndorsement = SiteDiary(
        id: 1,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-10",
        weather: 1,
        workActivity: "Foundation inspection required",
        instruction: nil,
        response: nil,
        state: 1,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 2: Pending Contractor Endorsement (No Attachment)
    static let previewPendingContractorNoAttachment = SiteDiary(
        id: 2,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-10",
        weather: 1,
        workActivity: "Mobile test",
        instruction: nil,
        response: nil,
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 2: Pending Contractor Endorsement (With Attachment)
    static let previewPendingContractorWithAttachment = SiteDiary(
        id: 3,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-10",
        weather: 1,
        workActivity: "Concrete pouring progress",
        instruction: nil,
        response: nil,
        state: 2,
        attachment: ["003E"],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 2: Pending Contractor (With Instruction & Response)
    static let previewPendingContractorWithInstructionResponse = SiteDiary(
        id: 4,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-08",
        weather: 3,
        workActivity: "Carry out confined space works today",
        instruction: "This is my instructions to contractor",
        response: "This is contractor's response",
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 2: Pending Contractor (With Instruction, No Response)
    static let previewPendingContractorWithInstruction = SiteDiary(
        id: 5,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-08",
        weather: 3,
        workActivity: "Carry out confined space works today",
        instruction: "This is my instructions to contractor",
        response: nil,
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 3: Pending DSD Approval
    static let previewPendingDSDApproval = SiteDiary(
        id: 6,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-09",
        weather: 2,
        workActivity: "Safety inspection completed",
        instruction: "Please review and approve",
        response: "All safety measures passed",
        state: 3,
        attachment: ["001A", "002B"],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 4: Rejected
    static let previewRejected = SiteDiary(
        id: 7,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-07",
        weather: 2,
        workActivity: "Incomplete documentation",
        instruction: "Need more details",
        response: nil,
        state: 4,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    // State 5: Archived (Closed)
    static let previewArchived = SiteDiary(
        id: 8,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-01",
        weather: 1,
        workActivity: "Foundation works completed",
        instruction: "Final inspection completed",
        response: "Work approved and closed",
        state: 5,
        attachment: ["101A", "102B", "103C"],
        siteInCharge: nil,
        contractor: nil
    )
    
    // Different Weather Conditions
    static let previewCloudyWeather = SiteDiary(
        id: 9,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-09",
        weather: 0,  // Cloudy
        workActivity: "Cloudy day inspection",
        instruction: nil,
        response: nil,
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    static let previewRainyWeather = SiteDiary(
        id: 10,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-08",
        weather: 2,  // Rainy
        workActivity: "Rainy day - work delayed",
        instruction: "Wait for better weather",
        response: nil,
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    static let previewOvercastWeather = SiteDiary(
        id: 11,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-11-26",
        weather: 3,  // Overcast
        workActivity: "Carry out confined space works today",
        instruction: "This is my instructions to contractor",
        response: nil,
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    // MARK: - Preview Lists
    
    /// All preview site diaries
    static let previewList: [SiteDiary] = [
        previewPendingDSDEndorsement,
        previewPendingContractorNoAttachment,
        previewPendingContractorWithAttachment,
        previewPendingContractorWithInstructionResponse,
        previewPendingContractorWithInstruction,
        previewPendingDSDApproval,
        previewRejected,
        previewArchived
    ]
    
    /// State 1: Pending DSD Endorsement (Action Required)
    static let pendingDSDEndorsementList: [SiteDiary] = [
        previewPendingDSDEndorsement
    ]
    
    /// State 2: Pending Contractor Endorsement
    static let pendingContractorList: [SiteDiary] = [
        previewPendingContractorNoAttachment,
        previewPendingContractorWithAttachment,
        previewPendingContractorWithInstructionResponse,
        previewPendingContractorWithInstruction
    ]
    
    /// State 3: Pending DSD Approval
    static let pendingDSDApprovalList: [SiteDiary] = [
        previewPendingDSDApproval
    ]
    
    /// State 4: Rejected
    static let rejectedList: [SiteDiary] = [
        previewRejected
    ]
    
    /// State 5: Archived (Closed)
    static let archivedList: [SiteDiary] = [
        previewArchived
    ]
    
    /// Different weather conditions
    static let weatherList: [SiteDiary] = [
        previewPendingContractorNoAttachment,  // Sunny
        previewCloudyWeather,                  // Cloudy
        previewRainyWeather,                   // Rainy
        previewOvercastWeather                 // Overcast
    ]
    
    /// With attachments
    static let withAttachmentsList: [SiteDiary] = [
        previewPendingContractorWithAttachment,
        previewPendingDSDApproval,
        previewArchived
    ]
    
    /// Without attachments
    static let withoutAttachmentsList: [SiteDiary] = [
        previewPendingDSDEndorsement,
        previewPendingContractorNoAttachment,
        previewPendingContractorWithInstructionResponse,
        previewRejected
    ]
    
    /// With instruction and response
    static let withInstructionResponseList: [SiteDiary] = [
        previewPendingContractorWithInstructionResponse,
        previewPendingDSDApproval,
        previewArchived
    ]
    
    /// With instruction only
    static let withInstructionOnlyList: [SiteDiary] = [
        previewPendingContractorWithInstruction,
        previewRejected,
        previewRainyWeather
    ]
    
    // MARK: - Quick Access by Status
    
    /// Action required (State 1)
    static var actionRequired: SiteDiary {
        previewPendingDSDEndorsement
    }
    
    /// Pending contractor (State 2)
    static var pendingContractor: SiteDiary {
        previewPendingContractorWithAttachment
    }
    
    /// Pending approval (State 3)
    static var pendingApproval: SiteDiary {
        previewPendingDSDApproval
    }
    
    /// Rejected (State 4)
    static var rejected: SiteDiary {
        previewRejected
    }
    
    /// Archived (State 5)
    static var archived: SiteDiary {
        previewArchived
    }
}

// MARK: - SiteDiaryResponse Preview (for testing API parsing)
extension SiteDiary {
    static let previewResponse1 = SiteDiary(
        id: 9,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-10",
        weather: 1,
        workActivity: "Mobile test",
        instruction: nil,
        response: nil,
        state: 2,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    static let previewResponse2 = SiteDiary(
        id: 12,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-10",
        weather: 1,
        workActivity: "test",
        instruction: nil,
        response: nil,
        state: 2,
        attachment: ["003E"],
        siteInCharge: nil,
        contractor: nil
    )
    
    static let previewResponseList: [SiteDiary] = [
        previewResponse1,
        previewResponse2
    ]
}

#endif // DEBUG
