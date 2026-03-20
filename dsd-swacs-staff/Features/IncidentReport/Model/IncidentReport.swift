//
//  IncidentReport.swift
//  dsd-swacs-staff
//
//  Created by Andy on 9/2/2026.
//
//
//  IncidentReport.swift
//  dsd-swacs-staff
//

import Foundation
import SwiftUI

struct IncidentReport: Identifiable {
    
    // MARK: - Properties (Mapped from API)
    
    let id: Int
    let occurenceTime: Date?
    let swac: String
    let location: String
    let brief: String
    
    // Bool Flags
    let hasCasualty: Bool
    let hasMedia: Bool
    let hasParamedic: Bool
    let hasFirefighter: Bool
    let hasPoliceOfficer: Bool
    
    let contactPerson: String
    let contractor: String
    let submittedBy: String
    let submissionTime: Date?
    
    // Attachment
    let attachment: [String]?
    
    
    // MARK: - Computed Properties
    
    var reportNumber: String {
        return "\(id)"
    }
    
    var formattedOccurenceDateTime: String {
         guard let date = occurenceTime else { return "-" }
         return date.toString(format: "yyyy-MM-dd HH:mm")
     }

     var formattedOccurenceDate: String {
         guard let date = occurenceTime else { return "-" }
         return date.toString(format: "yyyy-MM-dd")
     }
    
     var formattedOccurenceTime: String {
         guard let date = occurenceTime else { return "-" }
         return date.toString(format: "HH:mm")
     }
    
    var formattedSubmissionDateTime: String {
        guard let date = submissionTime else { return "-" }
        return date.toString(format: "yyyy-MM-dd HH:mm")
    }
    
    // MARK: - Initializer
    
    init(
        id: Int,
        occurenceTime: String,
        swac: String,
        location: String,
        brief: String,
        hasCasualty: Bool,
        hasMedia: Bool,
        hasParamedic: Bool,
        hasFirefighter: Bool,
        hasPoliceOfficer: Bool,
        contactPerson: String,
        contractor: String,
        submittedBy: String,
        submissionTime: String,
        attachment: [String]
    ) {
        self.id = id
        self.occurenceTime = occurenceTime.iso8601Date
        self.swac = swac
        self.location = location
        self.brief = brief
        self.hasCasualty = hasCasualty
        self.hasMedia = hasMedia
        self.hasParamedic = hasParamedic
        self.hasFirefighter = hasFirefighter
        self.hasPoliceOfficer = hasPoliceOfficer
        self.contactPerson = contactPerson
        self.contractor = contractor
        self.submittedBy = submittedBy
        self.submissionTime = submissionTime.iso8601Date
        self.attachment = attachment
    }
    
    init(from response: IncidentReportResponse) {
        self.id = response.id
        self.occurenceTime = response.occurenceTime.iso8601Date
        self.swac = (response.swac?.trimmingCharacters(in: .whitespaces) ?? "").isEmpty
                    ? "-"
                    : response.swac!.trimmingCharacters(in: .whitespaces)
        self.location = response.location ?? "-"
        self.brief = response.brief ?? "-"
        
        self.hasCasualty = response.hasCasualty
        self.hasMedia = response.hasMedia
        self.hasParamedic = response.hasParamedic
        self.hasFirefighter = response.hasFirefighter
        self.hasPoliceOfficer = response.hasPoliceOfficer
        
        self.contactPerson = response.contactPerson ?? "-"
        self.contractor = response.contractor ?? "-"
        self.submittedBy = response.submittedBy ?? "-"
        self.submissionTime = response.submissionTime.iso8601Date
        
        self.attachment = response.attachment ?? []
    }
}
