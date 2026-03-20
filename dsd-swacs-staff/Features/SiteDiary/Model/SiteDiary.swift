//
//  SiteDiary.swift
//  dsd-swacs-staff
//
//  Created by Andy on 2/9/2025.
//

import SwiftUI

// MARK: - Site Diary Status
enum SiteDiaryStatus: Int, CaseIterable {
    case pendingDSDEndorsement = 1      // pending for endorsement by DSD staff
    case pendingContractorEndorsement = 2  // pending for endorsement by contractor
    case pendingDSDApproval = 3         // pending for final approval by DSD staff
    case rejected = 4                   // rejected
    case archived = 5                   // archived
    
    var displayText: String {
        switch self {
        case .pendingDSDEndorsement: return "site_diary_status_label_pending_dsd_endorsement".localized()
        case .pendingContractorEndorsement: return "site_diary_status_label_pending_contractor_endorsement".localized()
        case .pendingDSDApproval: return "site_diary_status_label_pending_dsd_approval".localized()
        case .rejected: return "site_diary_status_label_rejected".localized()
        case .archived: return "site_diary_status_label_archived".localized()
        }
    }
    
    var color: Color {
        switch self {
        case .pendingDSDEndorsement: return Color.orange
        case .pendingContractorEndorsement: return Color.yellow
        case .pendingDSDApproval: return Color.Primary800
        case .rejected: return Color.Neutral500
        case .archived: return Color(hex: "058A05")
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .pendingDSDEndorsement: return Color(hex: "FFF5E7")
        case .pendingContractorEndorsement: return Color(hex: "FFFAE8")
        case .pendingDSDApproval: return Color(hex: "F6FCFF")
        case .rejected: return .Neutral200
        case .archived: return Color(hex: "EDFEEE")
        }
    }
    
    var gradientColor: Color {
        switch self {
        case .pendingDSDEndorsement: return Color(hex: "F6D8AB")
        case .pendingContractorEndorsement: return Color(hex: "FFECAB")
        case .pendingDSDApproval: return Color.Primary100
        case .rejected: return .Neutral200
        case .archived: return Color(hex: "E9FEEB")
        }
    }
}

// MARK: - Weather Status
enum WeatherStatus: Int, CaseIterable {
    case fine = 1
    case cloudy = 2
    case rainy = 3

    var imageName: String {
        switch self {
        case .fine: return "icon-weather-sun"
        case .cloudy: return "icon-weather-cloud"
        case .rainy: return "icon-weather-rainy"
        }
    }

    var label: String {
        switch self {
        case .fine: return "site_diary_detail_label_weather_fine".localized()
        case .cloudy: return "site_diary_detail_label_weather_cloudy".localized()
        case .rainy: return "site_diary_detail_label_weather_rainy".localized()
        }
    }
}

// MARK: - Site Diary Model
struct SiteDiary: Codable, Identifiable, Hashable {
    let id: Int
    let swac: String
    let approver: String?
    let date: String
    let weather: Int
    let workActivity: String
    let instruction: String?
    let response: String?
    let state: Int
    let attachment: [String]
    let siteInCharge: String?
    let contractor: String?
    
    init(from response: SiteDiaryListItemResponse) {
        self.id = response.id
        self.swac = response.swac
        self.approver = response.approver
        self.date = response.date
        self.weather = response.weather
        self.workActivity = response.workActivity
        self.instruction = response.instruction
        self.response = response.response
        self.state = response.state
        self.attachment = response.attachment
        self.siteInCharge = response.siteInCharge
        self.contractor = response.contractor
    }
    
    init(from response: SiteDiaryDetailResponse) {
        self.id = response.id
        self.swac = response.swac
        self.approver = response.approver
        self.date = response.date
        self.weather = response.weather
        self.workActivity = response.workActivity
        self.instruction = response.instruction
        self.response = response.response
        self.state = response.state
        self.attachment = response.attachment
        self.siteInCharge = response.siteInCharge
        self.contractor = response.contractor
    }
    
    init(
        id: Int,
        swac: String,
        approver: String,
        date: String,
        weather: Int,
        workActivity: String,
        instruction: String?,
        response: String?,
        state: Int,
        attachment: [String] = [],
        siteInCharge: String?,
        contractor: String?
    ) {
        self.id = id
        self.swac = swac
        self.approver = approver
        self.date = date
        self.weather = weather
        self.workActivity = workActivity
        self.instruction = instruction
        self.response = response
        self.state = state
        self.attachment = attachment
        self.siteInCharge = siteInCharge
        self.contractor = contractor
    }
    
    // MARK: - Computed Properties
    
    /// Site Diary Status
    var status: SiteDiaryStatus {
        return SiteDiaryStatus(rawValue: state) ?? .rejected
    }
    
    /// Weather status enum
    var weatherStatus: WeatherStatus? {
        return WeatherStatus(rawValue: weather)
    }
    
    /// Formatted date
    var formattedDate: Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.date(from: date)
    }
    
    /// Date display string
    var dateDisplayString: String {
        guard let date = formattedDate else { return date }
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    /// String ID for navigation
    var stringId: String {
        return String(id)
    }
    
    /// Has instruction
    var hasInstruction: Bool {
        return instruction != nil && !instruction!.isEmpty
    }
    
    /// Has response
    var hasResponse: Bool {
        return response != nil && !response!.isEmpty
    }
    
    /// Has attachments
    var hasAttachments: Bool {
        return !attachment.isEmpty
    }
    
    /// Attachment count
    var attachmentCount: Int {
        return attachment.count
    }
    
    /// Attachment IDs/names
    var attachmentList: [String] {
        return attachment
    }
    
    // MARK: - Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(state)
        hasher.combine(instruction)
        hasher.combine(response)
        hasher.combine(attachment)
    }
    
    static func == (lhs: SiteDiary, rhs: SiteDiary) -> Bool {
        lhs.id == rhs.id &&
        lhs.state == rhs.state &&
        lhs.instruction == rhs.instruction &&
        lhs.response == rhs.response &&
        lhs.attachment == rhs.attachment
    }
}

// MARK: - Preview Examples
extension SiteDiary {
    static let exampleNoAttachment = SiteDiary(
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
    
    static let exampleWithAttachment = SiteDiary(
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
    
    static let exampleWithInstructionAndResponse = SiteDiary(
        id: 1,
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
    
    static let exampleActionRequired = SiteDiary(
        id: 10,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-11-26",
        weather: 3,
        workActivity: "Carry out confined space works today",
        instruction: "This is my instructions to contractor",
        response: nil,
        state: 1,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    static let exampleRejected = SiteDiary(
        id: 13,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-09",
        weather: 2,
        workActivity: "Test rejected",
        instruction: nil,
        response: nil,
        state: 4,
        attachment: [],
        siteInCharge: nil,
        contractor: nil
    )
    
    static let exampleArchived = SiteDiary(
        id: 14,
        swac: "0099",
        approver: "ksfong02",
        date: "2025-12-01",
        weather: 1,
        workActivity: "Completed work",
        instruction: "Final instructions",
        response: "Work completed",
        state: 5,
        attachment: ["001A", "002B"],
        siteInCharge: nil,
        contractor: nil
    )
}
