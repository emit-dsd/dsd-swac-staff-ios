//
//  CustomNavigationRouter.swift
//  SiteWorkApp
//
//  Created by User on 21/7/2025.
//

import SwiftUI

enum Screen: Hashable {
    case home
    case swac
    case swacDetail(String)
    case swacWorkerInfo(Attendance)
    case attendance
    case attendanceDetail(SiteWork)
    case SiteDiaryList(String)               // SWAC number
    case SiteDiaryNewEntry(String)           // SWAC number
    case SiteDiaryDetailMain(String, Int)    // (SWAC number, Diary ID)
    case SafetyInspectionList(String, Bool)  // SWAC number, canSubmitSafetyInspectionReport
    
    
    case SafetyInspectionNewEntry(String, SafetyInspectionPart)                   // SWAC number , Part
    case SafetyInspectionEdit(SafetyInspectionDraft, SafetyInspectionPart)        // Draft Mode, Part
    case SafetyInspectionDetail(String, Int, SafetyInspectionPart)                // (SWAC number, API Inspection ID)
    case SafetyInspectionChecklist(SafetyInspectionDraft, SafetyInspectionPart)   // Edit Mode, Part
    case SafetyInspectionChecklistReadOnly([SafetyInspectionChecklistResult], SafetyInspectionPart)  // ReadOnly Mode, Part
    
    case setting
    case scan(ScanMode, Bool, Binding<Bool>, onComplete: (String) -> Void, onFail: () -> Void)
    case scanResult(InspectAccessCodeResponse?, String?, Bool)
    case signInOutResult(StaffSignInOutResponse, ScanMode)
    case IncidentReport
    case IncidentReportList
    case IncidentReportDetail(Int,IncidentReportSource)
    case notificationMain
}

extension View {
    func appNavigationDestination() -> some View {
        self.navigationDestination(for: Screen.self) { screen in
            switch screen {
            case .home:
                HomeView()
                    .navigationBarHidden(true)
            case .swac:
                SWACMainView()
                    .navigationBarHidden(true)
            case .swacDetail(let swac):
                SWACDetailMainView(swacNumber: swac)
                    .navigationBarHidden(true)
            case .swacWorkerInfo(let attendance):
                SWACDetailWorkerInfoView(attendance: attendance)
                    .navigationBarHidden(true)
            case .attendance:
                AttendanceView()
                    .navigationBarHidden(true)
            case .attendanceDetail(let siteWork):
                AttendanceDetailView(siteWork: siteWork)
                    .navigationBarHidden(true)
            case .SiteDiaryList(let swacNumber):
                SiteDiaryListView(swacNumber: swacNumber)
                    .navigationBarHidden(true)
            case .SiteDiaryNewEntry(let swacNumber):
                SiteDiaryNewEntryView(swacNumber: swacNumber)
                    .navigationBarHidden(true)
            case .SiteDiaryDetailMain(let swacNumber, let diaryId):
                SiteDiaryDetailMainView(swacNumber: swacNumber, diaryId: diaryId)
                    .navigationBarHidden(true)
            case .SafetyInspectionList(let swacNumber, let canSubmitSafetyInspectionReport):
                SafetyInspectionListView(swacNumber: swacNumber, canSubmitSafetyInspectionReport:canSubmitSafetyInspectionReport)
                    .navigationBarHidden(true)
                
                
            case .SafetyInspectionNewEntry(let swac, let part):
                SafetyInspectionNewEntryView(swacNumber: swac, part: part)
                    .navigationBarHidden(true)
            case .SafetyInspectionEdit(let draft, let part):
                SafetyInspectionNewEntryView(swacNumber: draft.swacNumber, draft: draft, part: part)
                    .navigationBarHidden(true)
            case .SafetyInspectionDetail(let swac, let id, let part):
                SafetyInspectionNewEntryView(swacNumber: swac, draft: nil, inspectionId: id, part: part)
                    .navigationBarHidden(true)
            case .SafetyInspectionChecklist(let draft, let part):
                SafetyInspectionChecklistView(draft: draft, part: part)
                    .navigationBarHidden(true)
            case .SafetyInspectionChecklistReadOnly(let results, let part):
                SafetyInspectionChecklistView(results: results, part: part)
                    .navigationBarHidden(true)
                
            case .setting:
                Color.white.ignoresSafeArea()
            case .scan(let scanMode, let showButton, let isPaused, let onComplete, let onFail):
                ScanView(
                    scanMode: scanMode,
                    showButton: showButton,
                    isPaused: isPaused,
                    onComplete: { code in
                        onComplete(code)
                    },
                    onFail: {
                        onFail()
                    }
                )
                .navigationBarHidden(true)
            case .scanResult(let inspectAccessCodeResponse, let error, let isValid):
                ScreanResultView(inspectAccessCodeResponse: inspectAccessCodeResponse, errorMessage: error, isValid: isValid, )
                    .navigationBarHidden(true)
            case .signInOutResult(let staffSignInOutResponse, let scanMode, ):
                SignInOutResult(staffSignInOutResponse: staffSignInOutResponse, scanMode: scanMode)
                    .navigationBarHidden(true)
            case .IncidentReport:
                IncidentReportView()
                    .navigationBarHidden(true)
            case .IncidentReportList:
                IncidentReportListView()
                    .navigationBarHidden(true)
            case .IncidentReportDetail(let reportId, let source):
                IncidentReportDetailView(reportId: reportId, source: source)
                    .navigationBarHidden(true)
            case .notificationMain:
                NotificationMainView()
                    .navigationBarHidden(true)
            }
        }
    }
}

extension Screen {
    func hash(into hasher: inout Hasher) {
        switch self {
        case .scan(let mode, let showButton, _, _ , _):
            hasher.combine("scan-\(mode)-\(showButton)")
        case .SafetyInspectionChecklist(let draft, let part):
            hasher.combine("SafetyInspectionChecklist")
            hasher.combine(draft.id)
            hasher.combine(part)
        default:
            hasher.combine(String(describing: self))
        }
    }

    static func == (lhs: Screen, rhs: Screen) -> Bool {
        switch (lhs, rhs) {
        case let (.SafetyInspectionChecklist(lDraft, lPart), .SafetyInspectionChecklist(rDraft, rPart)):
            return lDraft.id == rDraft.id && lPart == rPart
        default:
            return String(describing: lhs) == String(describing: rhs)
        }
    }
}

