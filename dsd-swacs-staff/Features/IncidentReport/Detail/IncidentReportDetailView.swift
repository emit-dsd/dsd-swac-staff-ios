//
//  IncidentReportDetailView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/11/2025.
//

import SwiftUI


enum IncidentReportSource {
    case fromSubmit
    case fromList
}

struct IncidentReportDetailView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    
    @State private var showToast = false
    @State private var isProcessing = false
    
    let source: IncidentReportSource
    
    @StateObject private var viewModel: IncidentReportDetailViewModel
    
    init(reportId: Int, source: IncidentReportSource) {
        self.source = source
        _viewModel = StateObject(wrappedValue: IncidentReportDetailViewModel(reportId: reportId))
    }
    
    private func handleBackClick() {
        switch source {
        case .fromSubmit:
            tabStore.popLastOnCurrentPath(count: 2)
        case .fromList:
            tabStore.popLastOnCurrentPath()
        }
        
        tabStore.notifyIncidentReportListReload()
    }
    
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            CustomNavBarView(
                type: .backOnly,
                title: "new_incident_report_label_incident_report".localized(),
                onBackTapped: handleBackClick
            )
            
            ZStack {
                if viewModel.isLoading {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let report = viewModel.report {
                    contentView(report: report)
                }else {
                    ProgressView()
                        .scaleEffect(1.5)
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
            }
        }
        .background(Color.white)
        .navigationBarHidden(true)
        .toast(isShowing: $showToast, message: "new_incident_report_label_copied".localized())
        .task {
            await viewModel.loadDetail()
        }
    }
    
    // MARK: - Subviews
    
    private func contentView(report: IncidentReport) -> some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                InfoRowView(title: "new_incident_report_label_reference_no".localized(), value: report.reportNumber)
                
                // Date and Time
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "new_incident_report_label_date".localized(), value: report.formattedOccurenceDate)
                    InfoRowView(title: "new_incident_report_label_time".localized(), value: report.formattedOccurenceTime)
                }
                // SWAC No. and Location
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "new_incident_report_label_swac_no".localized(), value: report.swac.isEmpty ? "-" : report.swac)
                    InfoRowView(title: "new_incident_report_label_location".localized(), value: report.location.isEmpty ? "-" : report.location)
                }
                
                // Incident Section
                Text("new_incident_report_label_incident".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(.Neutral800)
                
                // Cause of accident
                InfoRowView(title: "new_incident_report_label_cause_of_accident".localized(), value: report.brief)
                
                // Yes/No Fields
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "new_incident_report_label_any_casualties".localized(),
                                value: report.hasCasualty ? "general_yes".localized() : "general_no".localized())
                    InfoRowView(title: "new_incident_report_label_any_medias".localized(),
                                value: report.hasMedia ? "general_yes".localized() : "general_no".localized())
                }
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "new_incident_report_label_any_paramedics".localized(),
                                value: report.hasParamedic ? "general_yes".localized() : "general_no".localized())
                    InfoRowView(title: "new_incident_report_label_any_fire_force".localized(),
                                value: report.hasFirefighter ? "general_yes".localized() : "general_no".localized())
                }
                InfoRowView(title: "new_incident_report_label_any_polices".localized(),
                            value: report.hasPoliceOfficer ? "general_yes".localized() : "general_no".localized())
                
                // DSD Contact Person
                InfoRowView(title: "new_incident_report_label_dsd_contact_person".localized(), value: report.contactPerson)
                
                // Contractor
                InfoRowView(title: "new_incident_report_label_dsd_contractor".localized() + " " + "new_incident_report_label_dsd_contractor_ifAny".localized(), value: report.contractor.isEmpty ? "-" : report.contractor)
                
                // Actions
                VStack(spacing: 24) {
                    CommonButton(
                        title: "new_incident_report_label_copy_to_clipboard".localized(),
                        style: .outlined,
                        enabled: !isProcessing,
                        maxWidth: .infinity
                    ) {
                        copyReportToClipboard(report: report)
                    }
                    
                    CommonButton(
                        title: "general_back".localized(),
                        style: .contained,
                        enabled: true,
                        maxWidth: .infinity
                    ) {
                        handleBackClick()
                    }
                }
            }
            .padding(.vertical, 24)
            .padding(.horizontal, 16)
        }
    }
    
    // MARK: - Copy to Clipboard
    private func copyReportToClipboard(report: IncidentReport) {
        guard !isProcessing else { return }
        
        isProcessing = true
        
        let reportText = """
        \("new_incident_report_label_reference_no".localized()): \(report.reportNumber)
        \("new_incident_report_label_date".localized()): \(report.formattedOccurenceDate)
        \("new_incident_report_label_time".localized()): \(report.formattedOccurenceTime)
        \("new_incident_report_label_swac_no".localized()): \(report.swac.isEmpty ? "-" : report.swac)
        \("new_incident_report_label_location".localized()): \(report.location)
        
        \("new_incident_report_label_cause_of_accident".localized()): \(report.brief)
        
        \("new_incident_report_label_any_casualties".localized()): \(report.hasCasualty ? "general_yes".localized() : "general_no".localized())
        \("new_incident_report_label_any_medias".localized()): \(report.hasMedia ? "general_yes".localized() : "general_no".localized())
        \("new_incident_report_label_any_paramedics".localized()): \(report.hasParamedic ? "general_yes".localized() : "general_no".localized())
        \("new_incident_report_label_any_fire_force".localized()): \(report.hasFirefighter ? "general_yes".localized() : "general_no".localized())
        \("new_incident_report_label_any_polices".localized()): \(report.hasPoliceOfficer ? "general_yes".localized() : "general_no".localized())
        
        \("new_incident_report_label_dsd_contact_person".localized()): \(report.contactPerson)
        \("new_incident_report_label_dsd_contractor".localized()): \(report.contractor.isEmpty ? "-" : report.contractor)
        """
        
        UIPasteboard.general.string = reportText
        
        withAnimation {
            showToast = true
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.1) {
            isProcessing = false
        }
        
        print("✅ Report copied to clipboard")
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    IncidentReportDetailView(reportId: 1, source: .fromList)
}
#endif
