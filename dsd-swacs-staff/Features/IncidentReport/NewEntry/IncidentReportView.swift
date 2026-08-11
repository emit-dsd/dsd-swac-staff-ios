//
//  IncidentReportView.swift
//  dsd-swacs-staff DEV
//
//  Created by Andy on 17/11/2025.
//

import SwiftUI

struct IncidentReportView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    @ObservedObject var userSession = UserSession.shared
    
    @StateObject private var viewModel = IncidentReportViewModel()
    
    @FocusState private var isBriefFocused: Bool
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(
                type: .backOnly,
                title: "new_incident_report_label_tiltle".localized(),
                onBackTapped: {
                    if viewModel.hasUnsavedChanges {
                        showLeaveAlert()
                    } else {
                        tabStore.popLastOnCurrentPath()
                    }
                }
            )
            
            ZStack(alignment: .top) {
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 24) {
                            // Incident Report Section
                            Text("new_incident_report_label_incident_report".localized())
                                .appFont(.robotoBold, size: 18)
                                .foregroundColor(.Neutral800)
                            
                            CustomDatePickerView(
                                title: "new_incident_report_label_date".localized(),
                                date: $viewModel.date,
                                placeholder: "site_diary_detail_label_pick_date".localized(),
                                range: Date.distantPast...Date(),
                                displayFormat: .custom("yyyy-MM-dd")
                            )
                            
                            CustomTimePickerView(
                                title: "new_incident_report_label_time".localized(),
                                time: $viewModel.time,
                                placeholder: "",
                                timeFormat: .twentyFourHour
                            )
                            
                            CustomInputView(
                                attributedTitle: swacTitleAttributedString,
                                text: $viewModel.swac,
                                placeholder: "",
                                mode: .default
                            )
                            
                            CustomInputView(
                                title: "new_incident_report_label_location".localized(),
                                text: $viewModel.location,
                                placeholder: "",
                                mode: .default
                            )
                            
                            // Incident Section
                            Text("new_incident_report_label_incident".localized())
                                .appFont(.robotoBold, size: 18)
                                .foregroundColor(.Neutral800)
                            
                            VStack(spacing: 8) {
                                Text("new_incident_report_label_cause_of_accident".localized())
                                    .appFont(.robotoRegular, size: 14)
                                    .foregroundColor(.Primary800)
                                    .frame(maxWidth: .infinity, alignment: .topLeading)
                                
                                CustomPlaceholderTextEditor(
                                    text: $viewModel.brief,
                                    placeholder: ""
                                )
                                .id("briefEditor")
                                .focused($isBriefFocused)
                                .frame(height: 140)
                            }
                            
                            ToggleRowView(
                                title: "new_incident_report_label_any_casualties".localized(),
                                isOn: $viewModel.hasCasualty
                            )
                            
                            
                            ToggleRowView(
                                title: "new_incident_report_label_any_medias".localized(),
                                isOn: $viewModel.hasMedia
                            )
                            
                            
                            ToggleRowView(
                                title: "new_incident_report_label_any_paramedics".localized(),
                                isOn: $viewModel.hasParamedic
                            )
                            
                            
                            ToggleRowView(
                                title: "new_incident_report_label_any_fire_force".localized(),
                                isOn: $viewModel.hasFirefighter
                            )
                            
                            
                            ToggleRowView(
                                title: "new_incident_report_label_any_polices".localized(),
                                isOn: $viewModel.hasPoliceOfficer
                            )
                            
                            
                            CustomInputView(
                                title: "new_incident_report_label_dsd_contact_person".localized(),
                                text: $viewModel.contactPerson,
                                placeholder: "",
                                mode: .default
                            )
                            
                            CustomInputView(
                                attributedTitle: contractorTitleAttributedString,
                                text: $viewModel.contractor,
                                placeholder: "",
                                mode: .default
                            )
                        }
                    }
                    .contentMargins(.vertical, 24, for: .scrollContent)
                    .contentMargins(.horizontal, 16, for: .scrollContent)
                    .background(Color.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
                    .onChange(of: isBriefFocused) { _, newValue in
                        if newValue {
                            withAnimation {
                                proxy.scrollTo("briefEditor", anchor: .center)
                            }
                        }
                    }
                }

            }
            
            // Submit Button
            VStack {
                CommonButton(
                    title: "general_submit".localized(),
                    style: .contained,
                    enabled: viewModel.isFormValid && !viewModel.isLoading,
                    maxWidth: .infinity
                ) {
                    Task {
                        await viewModel.submitReport()
                    }
                }
            }
            .padding(.vertical, 16)
            .padding(.horizontal, 16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .onAppear {
            setupCurrentStaffName()
        }
        .onChange(of: viewModel.showSuccess) { _, show in
            if show {
                showSuccessAlert()
            }
        }
        .background(Color.white)
    }
    
    // MARK: - Setup Methods
    private func setupCurrentStaffName() {
        if let profile = userSession.profile {
            viewModel.setCurrentStaffName(profile.nameEng)
            return
        }
    }
    
    // MARK: - Attributed Strings
    private var swacTitleAttributedString: AttributedString {
        var text = AttributedString("new_incident_report_label_swac_no".localized())
        text.foregroundColor = Color.Primary800
        text.font = .custom("Roboto", size: 14)
        
        var star = AttributedString(" " + "new_incident_report_label_swac_no_optional".localized())
        star.foregroundColor = Color.Neutral500
        star.font = .custom("Roboto", size: 14)
        
        text.append(star)
        return text
    }
    
    private var contractorTitleAttributedString: AttributedString {
        var text = AttributedString("new_incident_report_label_dsd_contractor".localized())
        text.foregroundColor = Color.Primary800
        text.font = .custom("Roboto", size: 14)
        
        var star = AttributedString(" " + "new_incident_report_label_dsd_contractor_ifAny".localized())
        star.foregroundColor = Color.Neutral500
        star.font = .custom("Roboto", size: 14)
        
        text.append(star)
        return text
    }
    
    // MARK: - Alert Helpers
    private func showLeaveAlert() {
        alertManager.show(
            title: "new_incident_report_alertTitle_leave".localized(),
            message: "new_incident_report_alertMessage_leave".localized(),
            buttons: [
                CommonButtonModel(
                    title: "new_incident_report_button_confirm_leave".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    textColor: .white,
                    backgroundColor: .red,
                    action: {
                        tabStore.popLastOnCurrentPath()
                        alertManager.close()
                    }
                ),
                CommonButtonModel(
                    title: "general_cancel".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: { }
                )
            ]
        )
    }
    
    private func showErrorAlert(message: String) {
        alertManager.show(
            title: "Error",
            message: message,
            buttons: [
                CommonButtonModel(
                    title: "OK",
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    backgroundColor: .red,
                    action: {
                        viewModel.showError = false
                    }
                )
            ]
        )
    }
    
    private func showSuccessAlert() {
        alertManager.show(
            title: "new_incident_report_alertTitle_msg".localized(),
            message: "new_incident_report_alertMessage_msg".localized(),
            image: "icon-alert-success",
            buttons: [
                CommonButtonModel(
                    title: "general_confirm".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        viewModel.showSuccess = false
                        viewModel.resetForm()
                        if let reportId = viewModel.submittedReportId {
                            tabStore.appendToCurrentPath(Screen.IncidentReportDetail(reportId, .fromSubmit))
                        }
                    }
                )
            ]
        )
    }
}


// MARK: - Preview
#if DEBUG
#Preview {
    IncidentReportView()
}
#endif
