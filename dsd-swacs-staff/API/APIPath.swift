//
//  APIPath.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

public struct APIPath {
    
    static let staffLogin             = "/api/Home/StaffLogin"
    static let inspectAccessCode      = "/api/Home/InspectAccessCode"
    static let setLanguage            = "/api/Home/SetLanguage"
    static let getReleaseNotes        = "/api/Home/GetReleaseNotes"
    
    static let submitincidentReport   = "/api/Report/Incident"
    static let incidentReportList     = "/api/Report/Incident/List"
    static let incidentReportDetail   = "/api/Report/Incident"
    static let submitSiteDiary        = "/api/Report/SiteDiary"
    static let siteDiaryList          = "/api/Report/SiteDiary/List"
    static let siteDiaryDetail        = "/api/Report/SiteDiary"
    static let safetyInspectionList   = "/api/Report/SafetyInspection/List"
    static let safetyInspectionDetail = "/api/Report/SafetyInspection"
    static let safetyInspectionFormat = "/api/Report/SafetyInspection/Format"
    static let openSafetyInspection   = "/api/Report/OpenSafetyInspection"
    static let closeSafetyInspection  = "/api/Report/CloseSafetyInspection"
    static let documentContent        = "/api/Report/DocumentContent"
    
    static let registerMobileToken   = "/api/Home/RegisterMobileToken"
    static let deregisterMobileToken = "/api/Home/DeregisterMobileToken"
    static let notificationList      = "/api/Notification/List"
    static let unreadCount           = "/api/Notification/UnreadCount"
    static let markRead              = "/api/Notification/MarkRead"
    
    static let staffSignIn           = "/api/Attendance/staff/SignIn"
    static let staffSignOut          = "/api/Attendance/staff/SignOut"
    static let attendanceList        = "/api/Attendance/List"
    static let attendanceMember      = "/api/Attendance/Member"
    
    static let swacList              = "/api/SWAC/List"
    static let swacSearch            = "/api/SWAC/Search"
    static let swacProfile           = "/api/SWAC/Profile"
    static let workingTeamMember     = "/api/SWAC/WorkingTeamMember"
    static let getApproverByRCC      = "/api/SWAC/GetApproverByRCC"
    static let safetyVettingList     = "/api/SWAC/SafetyVetting"
    static let passSafetyVetting     = "/api/SWAC/PassSafetyVetting"
    static let failSafetyVetting     = "/api/SWAC/FailSafetyVetting"
    
    static let approvalList             = "/api/CSWR/GetApprovalList"
    static let endorsementList          = "/api/CSWR/GetEndorsementList"
    static let rejectList               = "/api/CSWR/GetRejectList"
    static let cswrApproveEntry         = "/api/CSWR/ApproveEntry"
    static let cswrEndorseRegistration  = "/api/CSWR/EndorseRegistration"
    static let cswrRejectEntry          = "/api/CSWR/RejectEntry"
}
