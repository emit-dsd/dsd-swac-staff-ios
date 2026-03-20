//
//  IncidentReportViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/11/2025.
//

import Foundation
import SwiftUI

@MainActor
class IncidentReportViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var date = Date()
    @Published var time = Date()
    @Published var swac = ""
    @Published var location = ""
    @Published var brief = ""
    @Published var hasCasualty = false
    @Published var hasMedia = false
    @Published var hasParamedic = false
    @Published var hasFirefighter = false
    @Published var hasPoliceOfficer = false
    @Published var contactPerson = ""
    @Published var contractor = ""
    

    @Published var currentStaffName: String? {
        didSet {
            if let name = currentStaffName, contactPerson.isEmpty {
                contactPerson = name
                print("✅ Auto-filled contactPerson: \(name)")
            }
        }
    }
    
    // UI States
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showError = false
    @Published var showSuccess = false
    
    // Detail model
    @Published var submittedReportId: Int? 
    
    // MARK: - Public Methods
    func setCurrentStaffName(_ name: String) {
        currentStaffName = name
    }
    
    // MARK: - Computed Properties
    
    /// Combine date and time into a single DateTime
    private var occurenceDateTime: Date {
        let hongKongTimeZone = TimeZone(identifier: "Asia/Hong_Kong")!
        var calendar = Calendar.current
        calendar.timeZone = hongKongTimeZone

        let dateComponents = calendar.dateComponents([.year, .month, .day], from: date)
        let timeComponents = calendar.dateComponents([.hour, .minute], from: time)
        
        var combined = DateComponents()
        combined.timeZone = hongKongTimeZone
        combined.year = dateComponents.year
        combined.month = dateComponents.month
        combined.day = dateComponents.day
        combined.hour = timeComponents.hour
        combined.minute = timeComponents.minute
        
        return calendar.date(from: combined) ?? Date()
    }

    
    /// Check if form is valid
    var isFormValid: Bool {
        return !location.isEmpty &&
               !brief.isEmpty &&
               !contactPerson.isEmpty
    }
    
    // MARK: - Submit Report
    func submitReport() async {
        guard isFormValid else {
            errorMessage = "Please fill in all required fields"
            showError = true
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
               let parameters = createFormDataParameters()
            
               let responseId = try await APIService.submitIncidentReport(parameters: parameters)
               
               isLoading = false
               submittedReportId = responseId
               showSuccess = true
               print("✅ Incident report submitted successfully: \(responseId)")
               
           } catch {
               isLoading = false
               errorMessage = error.localizedDescription
               showError = true
               print("❌ Failed to submit incident report: \(error)")
           }
    }
    
    // MARK: - Create Detail Model
    private func createFormDataParameters() -> [String: String] {
        let timeString = ISO8601DateFormatter.timeStringForAPI.string(from: occurenceDateTime)
        print("🔧 occurenceDateTime (UTC): \(occurenceDateTime)")  
        print("🔧 ISO string sent to API: \(timeString)")
        return [
            "Profile.OccurenceTime": timeString,
            "Profile.SWAC": swac,
            "Profile.Location": location,
            "Profile.Brief": brief,
            "Profile.HasCasualty": String(hasCasualty),
            "Profile.HasMedia": String(hasMedia),
            "Profile.HasParamedic": String(hasParamedic),
            "Profile.HasFirefighter": String(hasFirefighter),
            "Profile.HasPoliceOfficer": String(hasPoliceOfficer),
            "Profile.ContactPerson": contactPerson,
            "Profile.Contractor": contractor
        ]
    }
    
    // MARK: - Reset Form
    func resetForm() {
        date = Date()
        time = Date()
        swac = ""
        location = ""
        brief = ""
        hasCasualty = false
        hasMedia = false
        hasParamedic = false
        hasFirefighter = false
        hasPoliceOfficer = false
        contactPerson = currentStaffName ?? ""
        contractor = ""
    }
}
