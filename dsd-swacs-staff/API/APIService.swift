//
//  APIManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 22/10/2025.
//
import Foundation

struct APIService {
    // MARK: - Login
    static func staffLogin(loginName: String, password: String) async throws -> StaffLoginResponse {
        let reqBody = StaffLoginRequest(loginName: loginName, password: password)
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.staffLogin,
            body: reqBody,
            options: [.noAuth]
        )
    }
    
    // MARK: - Set Language
    static func setLanguage(_ languageCode: Int) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.setLanguage,
            body: languageCode,
            options: [.noDefaultErrorAlert]
        )
    }
    
    static func getReleaseNotes(appTypeId: Int) async throws -> ReleaseNotes {
        return try await APIManager.shared.sendAPIRequest(
            .GET,
            path: "\(APIPath.getReleaseNotes)/\(appTypeId)",
            body: EmptyBody(),
            options: [.noLoading, .noDefaultErrorAlert]
        )
    }
    
    // MARK: - Device Token
    static func registerMobileToken(_ fcmToken: String) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.registerMobileToken,
            body: fcmToken,
            options: [.noDefaultErrorAlert]
        )
    }
    
    static func deregisterMobileToken() async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.deregisterMobileToken,
            body: EmptyBody(),
            options: []
        )
    }
    
    // MARK: - Notification
    static func getNotificationList( page: Int = 1,  pageSize: Int = 20) async throws -> [NotificationItemResponse] {
        let request = NotificationListRequest(
            page: page,
            pageSize: pageSize
        )
        
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.notificationList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func getUnreadNotificationCount() async throws -> Int {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.unreadCount,
            body: EmptyBody(),
            options: [.noLoading]
        )
    }
    
    static func markNotificationAsRead(_ notificationId: Int) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.markRead,
            body: notificationId,
            options: [.noDefaultErrorAlert]
        )
    }
    
    // MARK: - Quick Action
    static func staffSignIn(accessCode: String) async throws -> StaffSignInOutResponse {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.staffSignIn,
            body: accessCode,
            options: [.noDefaultErrorAlert]
        )
    }
    
    static func staffSignOut(accessCode: String) async throws -> StaffSignInOutResponse {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.staffSignOut,
            body: accessCode,
            options: [.noDefaultErrorAlert]
        )
    }
    
    static func inspectAccessCode(accessCode: String) async throws -> InspectAccessCodeResponse {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.inspectAccessCode,
            body: accessCode,
            options: [.noDefaultErrorAlert]
        )
    }
    
    // MARK: - SWAC
    static func swacList(request: SwacListRequest) async throws -> [SWACDetailResponse] {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.swacList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func swacSearch(request: SwacSearchRequest) async throws -> [SWACListItemResponse] {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.swacSearch,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func fetchSWACProfile(swacNumber: String) async throws -> SWACDetailResponse {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.swacProfile,
            body: swacNumber,
            options: [.noDefaultErrorAlert]
        )
    }
    
    // MARK: - SWAC Attendance
    static func attendanceList(
        swac: String,
        date: Date,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> [AttendanceRecordResponse] {
        let reqBody = AttendanceListRequest(swac: swac, date: date, page: page, pageSize: pageSize)
        
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.attendanceList,
            body: reqBody,
            options: [.noLoading]
        )
    }
    
    static func attendanceList(
        swac: String,
        date: String,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> [AttendanceRecordResponse] {
        let reqBody = AttendanceListRequest(swac: swac, date: date, page: page, pageSize: pageSize)
        
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.attendanceList,
            body: reqBody,
            options: [.noLoading]
        )
    }
    
    static func getAttendanceMember(
        memberID: Int,
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> [AttendanceRecordResponse] {
        let reqBody = AttendanceMemberRequest(memberID: memberID, page: page, pageSize: pageSize)
        
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.attendanceMember,
            body: reqBody,
            options: [.noDefaultErrorAlert]
        )
    }
    
    static func getWorkingTeamMember(memberID: Int) async throws -> WorkingTeamMemberResponse {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.workingTeamMember,
            body: memberID,
            options: []
        )
    }
    
    // MARK: - SWAC Safety Vetting
    static func getSafetyVettingList(page: Int, pageSize: Int) async throws -> [SWACDetailResponse] {
        let request = SWACSimplePageRequest(page: page, pageSize: pageSize)
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.safetyVettingList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func passSafetyVetting(request: SafetyVettingRequest) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.passSafetyVetting,
            body: request,
            options: []
        )
    }
    
    static func failSafetyVetting(request: SafetyVettingRequest) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.failSafetyVetting,
            body: request,
            options: []
        )
    }
    
    // MARK: - Incident Report
    
    static func submitIncidentReport(parameters: [String: String], files: [MultipartFile] = []) async throws -> Int {
        let apiRequest = MultipartAPIRequest(
            .POST,
            path: APIPath.submitincidentReport,
            parameters: parameters,
            files: files
        )
        
        return try await APIManager.shared.uploadMultipartRequest(apiRequest)
    }
    
    static func getIncidentList(
        page: Int = 1,
        pageSize: Int = 20
    ) async throws -> [IncidentReportResponse] {
        let request = IncidentReportListRequest(
            page: page,
            pageSize: pageSize
        )
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.incidentReportList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func getIncidentDetail(id: Int) async throws -> IncidentReportResponse {
        return try await APIManager.shared.sendAPIRequest(
            .GET,
            path: "\(APIPath.incidentReportDetail)/\(id)",
            body: EmptyBody(),
            options: []
        )
    }
    
    // MARK: - Site Diary
    
    static func getSiteDiaryList(
        swac: String,
        page: Int = 1,
        pageSize: Int = 20,
        startDate: String? = nil,
        endDate: String? = nil,
        states: [Int]? = nil,
        workActivity: String? = nil
    ) async throws -> [SiteDiaryListItemResponse] {
        let request = SiteDiaryListRequest(
            swac: swac,
            page: page,
            pageSize: pageSize,
            startDate: startDate,
            endDate: endDate,
            state: states,
            workActivity: workActivity
        )
        
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.siteDiaryList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func getSiteDiaryDetail(id: Int) async throws -> SiteDiaryDetailResponse {
        return try await APIManager.shared.sendAPIRequest(
            .GET,
            path: "\(APIPath.siteDiaryDetail)/\(id)",
            body: EmptyBody(),
            options: []
        )
    }
    
    static func getApproverByRCC(rcc: Int) async throws -> [StaffApproverResponse] {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.getApproverByRCC,
            body: rcc,
            options: [.noDefaultErrorAlert]
        )
    }
    
    static func submitSiteDiary(
        instruction: String,
        response: String,
        swac: String,
        weatherAM: Int?,
        weatherPM: Int?,
        labour: Int?,
        workActivity: String,
        date: String, // Format: "2025-12-08"
        approver: String,
        attachments: [SiteDiaryAttachment],
        attachmentFiles: [Data]
    ) async throws -> Int {
        
        // 建立 parameters
        var parameters: [String: String] = [
            "Profile.Instruction": instruction,
            "Profile.Response": response,
            "Profile.SWAC": swac,
            "Profile.WorkActivity": workActivity,
            "Profile.Date": date,
            "Profile.Approver": approver
        ]
        if let weatherAM = weatherAM {
            parameters["Profile.WeatherAM"] = "\(weatherAM)"
        }
        if let weatherPM = weatherPM {
            parameters["Profile.WeatherPM"] = "\(weatherPM)"
        }
        if let labour = labour {
            parameters["Profile.Labour"] = "\(labour)"
        }
        // 加入 Attachment metadata
        for (index, attachment) in attachments.enumerated() {
            parameters["Attachment[\(index)].Subject"] = attachment.subject
            if let remarks = attachment.remarks {
                parameters["Attachment[\(index)].Remarks"] = remarks
            }
        }
        
        // 建立檔案陣列
        var files: [MultipartFile] = []
        for (index, fileData) in attachmentFiles.enumerated() {
            let mimeType = detectMimeType(from: fileData)
            let fileName = "attachment_\(index).\(mimeType.fileExtension)"
            
            files.append(MultipartFile(
                name: "AttachmentData",
                fileName: fileName,
                data: fileData,
                mimeType: mimeType
            ))
        }
        
        let apiRequest = MultipartAPIRequest(
            .POST,
            path: APIPath.submitSiteDiary,
            parameters: parameters,
            files: files
        )
        
        return try await APIManager.shared.uploadMultipartRequest(apiRequest)
    }
    
    private static func detectMimeType(from data: Data) -> MimeType {
        guard let firstByte = data.first else { return .octetStream }
        
        switch firstByte {
        case 0xFF: return .jpeg
        case 0x89: return .png
        case 0x25: return .pdf
        default: return .octetStream
        }
    }
    
    // MARK: - Safety Inspection
    
    static func getSafetyInspectionList(
        swac: String,
        page: Int = 1,
        pageSize: Int = 20,
        isClosed: Bool? = nil
    ) async throws -> [SafetyInspectionListItemResponse] {
        let request = SafetyInspectionListRequest(
            page: page,
            pageSize: pageSize,
            swac: swac,
            isClosed: isClosed
        )
        
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.safetyInspectionList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func getSafetyInspectionDetail(id: Int) async throws -> SafetyInspectionDetailResponse {
        return try await APIManager.shared.sendAPIRequest(
            .GET,
            path: "\(APIPath.safetyInspectionDetail)/\(id)",
            body: EmptyBody(),
            options: [.noLoading]
        )
    }
    
    static func fetchSafetyInspectionFormat() async throws -> [ChecklistItem] {
        return try await APIManager.shared.sendAPIRequest(
            .GET,
            path: APIPath.safetyInspectionFormat,
            body: EmptyBody(),
            options: []
        )
    }
    
    // MARK: - Document/Attachment
    static func getDocumentContentItems(attachmentIds: [String]) async throws -> [DocumentContentItemResponse] {
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.documentContent,
            body: attachmentIds,
            options: [.noLoading]
        )
    }
    
    
    // MARK: - Safety Inspection API
    
    static func openSafetyInspection(
        reportTime: String,
        worksDetail: String,
        confinedSpaceType: String,
        swac: String,
        items: [ChecklistItem],
        permitImages: [Data],
        raImages: [Data]
    ) async throws -> Int {
        
        var parameters: [String: String] = [:]
        
        // Profile
        parameters["Profile.ReportTime"] = reportTime
        parameters["Profile.WorksDetail"] = worksDetail
        parameters["Profile.ConfinedSpaceType"] = confinedSpaceType
        parameters["Profile.SWAC"] = swac
        
        // Attachments Meta
        var attachmentIndex = 0
        for _ in permitImages {
            parameters["Attachment[\(attachmentIndex)].Subject"] = "Permit"
            parameters["Attachment[\(attachmentIndex)].Remarks"] = ""
            attachmentIndex += 1
        }
        for _ in raImages {
            parameters["Attachment[\(attachmentIndex)].Subject"] = "FreshRA"
            parameters["Attachment[\(attachmentIndex)].Remarks"] = ""
            attachmentIndex += 1
        }
        
        // Items
        //        let answeredItems = flattenItems(items).filter { $0.hasAnswer }
        
        let targetItems = flattenItems(items)
        
        for (i, item) in targetItems.enumerated() {
            
            parameters["Item[\(i)].Category"] = String(item.rowID)
            
            if item.itemType == .text {
                if !item.textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    if let numValue = Int(item.textAnswer) {
                        parameters["Item[\(i)].Number"] = String(numValue)
                    } else {
                        parameters["Item[\(i)].Text"] = item.textAnswer
                    }
                }
            }
            
            else if item.itemType == .time {
                if !item.textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    parameters["Item[\(i)].Text"] = item.textAnswer
                }
            }
            
            else if item.itemType == .checkboxChoice {
                if let selected = item.choices.first(where: { $0.isChecked }) {
                    parameters["Item[\(i)].Option"] = String(selected.id)
                }
            }
            
            else if item.itemType == .singleChoice {
                if let selected = item.choices.first(where: { $0.isChecked }) {
                    parameters["Item[\(i)].Boolean"] = String(selected.id)
                }
            }
            
            
            if !item.remark.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                parameters["Item[\(i)].Remarks"] = item.remark
            }
        }
        
        // Files
        var files: [MultipartFile] = []
        let allImages = permitImages + raImages
        for (index, data) in allImages.enumerated() {
            let mime = detectMimeType(from: data)
            files.append(MultipartFile(
                name: "AttachmentData",
                fileName: "file\(index).\(mime.fileExtension)",
                data: data,
                mimeType: mime
            ))
        }
        
        let req = MultipartAPIRequest(.POST, path: APIPath.openSafetyInspection, parameters: parameters, files: files)
        return try await APIManager.shared.uploadMultipartRequest(req)
    }
    
    // PART B: closeSafetyInspection (Permit-complete & Section 9)
    static func closeSafetyInspection(
        id: Int,
        items: [ChecklistItem],
        permitCompleteImages: [Data]
    ) async throws -> Int {
        
        var parameters: [String: String] = [:]
        
        parameters["ID"] = String(id)
        
        // Attachments Meta (Permit-complete)
        for (index, _) in permitCompleteImages.enumerated() {
            parameters["Attachment[\(index)].Subject"] = "Permit-complete"
            parameters["Attachment[\(index)].Remarks"] = ""
        }
        
        let answeredItems = flattenItems(items).filter { $0.hasAnswer }
        
        for (i, item) in answeredItems.enumerated() {
            parameters["Item[\(i)].Category"] = String(item.rowID)
            
            if item.itemType == .text {
                if let numValue = Int(item.textAnswer) {
                    parameters["Item[\(i)].Number"] = String(numValue)
                } else {
                    parameters["Item[\(i)].Text"] = item.textAnswer
                }
            } else if item.itemType == .time {
                if !item.textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    parameters["Item[\(i)].Text"] = item.textAnswer
                }
            } else if item.itemType == .checkboxChoice {
                if let selected = item.choices.first(where: { $0.isChecked }) {
                    parameters["Item[\(i)].Option"] = String(selected.id)
                }
            } else if item.itemType == .singleChoice {
                if let selected = item.choices.first(where: { $0.isChecked }) {
                    parameters["Item[\(i)].Boolean"] = String(selected.id)
                }
            }
            if !item.remark.isEmpty {
                parameters["Item[\(i)].Remarks"] = item.remark
            }
        }
        
        // Files
        var files: [MultipartFile] = []
        for (index, data) in permitCompleteImages.enumerated() {
            let mime = detectMimeType(from: data)
            files.append(MultipartFile(
                name: "AttachmentData",
                fileName: "file\(index).\(mime.fileExtension)",
                data: data,
                mimeType: mime
            ))
        }
        
        let req = MultipartAPIRequest(.POST, path: APIPath.closeSafetyInspection, parameters: parameters, files: files)
        return try await APIManager.shared.uploadMultipartRequest(req)
    }
    
    
    // Helper to flatten items
    private static func flattenItems(_ items: [ChecklistItem]) -> [ChecklistItem] {
        var result: [ChecklistItem] = []
        for item in items {
            if item.itemType != .section { result.append(item) }
            result.append(contentsOf: flattenItems(item.childs))
        }
        return result
    }
    
    // MARK: - CSWR
    static func getApprovalList(page: Int, pageSize: Int) async throws -> [SiteWorkProfileResponse] {
        let request = SWACSimplePageRequest(page: page, pageSize: pageSize)
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.approvalList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func getEndorsementList(page: Int, pageSize: Int) async throws -> [SiteWorkProfileResponse] {
        let request = SWACSimplePageRequest(page: page, pageSize: pageSize)
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.endorsementList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func getRejectList(page: Int, pageSize: Int) async throws -> [SiteWorkProfileResponse] {
        let request = SWACSimplePageRequest(page: page, pageSize: pageSize)
        return try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.rejectList,
            body: request,
            options: [.noLoading]
        )
    }
    
    static func cswrApproveEntry(entryId: Int) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.cswrApproveEntry,
            body: entryId,
            options: []
        )
    }
    
    static func cswrRejectEntry(entryId: Int) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.cswrRejectEntry,
            body: entryId,
            options: .noDefaultErrorAlert
        )
    }
    
    static func cswrEndorseRegistration(entryId: Int) async throws {
        let _: EmptyResponse = try await APIManager.shared.sendAPIRequest(
            .POST,
            path: APIPath.cswrEndorseRegistration,
            body: entryId,
            options: []
        )
    }
}
