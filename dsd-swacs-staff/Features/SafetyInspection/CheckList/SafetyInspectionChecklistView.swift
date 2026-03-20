//
//  SafetyInspectionChecklistView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//

import SwiftUI

struct SafetyInspectionChecklistView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    
    @StateObject private var viewModel: SafetyInspectionChecklistViewModel
    @StateObject private var keyboardResponder = KeyboardResponder()
    
    @FocusState private var focusedField: String?
    @State private var selectedItemId: String?
    
    let part: SafetyInspectionPart
    
    // Init for Edit Mode
    init(draft: SafetyInspectionDraft, part: SafetyInspectionPart) {
        self.part = part
        _viewModel = StateObject(wrappedValue: SafetyInspectionChecklistViewModel(draft: draft, part: part))
    }
    
    // Init for ReadOnly Mode
    init(results: [SafetyInspectionChecklistResult], part: SafetyInspectionPart) {
        self.part = part
        _viewModel = StateObject(wrappedValue: SafetyInspectionChecklistViewModel(results: results, part: part))
    }
    
    private func handleSaveDraft() {
        Task {
            let success = await viewModel.saveAsDraft()
            if success {
                tabStore.popLastOnCurrentPath(count:2)
            } else {
                showErrorAlert()
            }
        }
    }
    
    private func handleSubmit() {
        Task {
            let success = await viewModel.submitInspection()
            if success {
                showSuccessAlert()
            } else {
                showErrorAlert()
            }
        }
    }
    
    private func showConfirmAlert() {
        alertManager.show(
            title: "safety_inspection_checklist_alertTitle_confirm".localized(),
            message: "safety_inspection_checklist_alertMessage_confirm".localized(),
            buttons: [
            
                CommonButtonModel(
                    title: "safety_inspection_checklist_button_confirm_submit".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        handleSubmit()
                    }
                ),
                
                CommonButtonModel(
                    title: "general_cancel".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        
                    }
                )
            ]
        )
    }
    
    private func showSuccessAlert() {
        alertManager.show(
            title: "safety_inspection_checklist_alertTitle_submitted".localized(),
            message: "safety_inspection_checklist_alertMessage_submitted".localized(),
            image: "icon-alert-success",
            buttons: [
                CommonButtonModel(
                    title: "general_back".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        tabStore.popLastOnCurrentPath(count:2)
                    }
                )
            ]
        )
    }
    
    private func showErrorAlert() {
        alertManager.show(
            title: "safety_inspection_checklist_alertTitle_submission_failed".localized(),
            message: viewModel.errorMessage ?? "safety_inspection_checklist_error_save_failed".localized(),
            image: "icon-alert-fail",
            buttons: [
                CommonButtonModel(
                    title: "safety_inspection_checklist_button_back_to_checklist".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {}
                )
            ]
        )
    }
    

    private func showNotePopupAlert() {
        let noteKeys = [
            "safety_inspection_checklist_alertMessage_note_msg1",
            "safety_inspection_checklist_alertMessage_note_msg2",
            "safety_inspection_checklist_alertMessage_note_msg3",
            "safety_inspection_checklist_alertMessage_note_msg4",
            "safety_inspection_checklist_alertMessage_note_msg5"
        ]
        
        let noteView = VStack(alignment: .leading, spacing: 24) {
            Text("safety_inspection_checklist_alertTitle_note".localized())
                .appFont(.robotoBold, size: 18)
                .foregroundColor(.Neutral800)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            
            ScrollView(showsIndicators: true) {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(noteKeys.enumerated()), id: \.offset) { index, key in
                        HStack(alignment: .top, spacing: 8) {
                            Text("\(index + 1).")
                                .appFont(.robotoRegular, size: 16)
                                .foregroundColor(.Neutral500)
                            
                            Text(key.localized())
                                .appFont(.robotoRegular, size: 16)
                                .foregroundColor(.Neutral500)
                                .fixedSize(horizontal: false, vertical: true)
                        }
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                    }
                }
                .padding(.trailing, 8)
            }
            .frame(maxHeight: UIScreen.main.bounds.height * 0.6)
            
            CommonButton(
                title: "safety_inspection_checklist_button_close".localized(),
                style: .outlined,
                enabled: true,
                maxWidth: .infinity
            ) {
                alertManager.close()
            }
        }.background(Color.white)
        alertManager.showWithCustomView(content: noteView)
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                let navTitleKey: String = {
                    switch part {
                    case .partA:
                        return viewModel.isReadOnly
                            ? "safety_inspection_detail_title"
                            : "safety_inspection_detail_new_title"
                    case .partB:
                        return "safety_inspection_detail_complete_title"
                    case .full:
                        return "safety_inspection_detail_completed_title"
                    }
                }()

                CustomNavBarView(
                    type: .backWithAction,
                    title: navTitleKey.localized(),
                    actionIconName: "icon-info-button",
                    onActionTapped: {
                        showNotePopupAlert()
                    }
                )
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else {
                    // ScrollViewReader to enable auto-scroll
                    ScrollViewReader { proxy in
                        ScrollView {
                            VStack(spacing: 0) {
                                ForEach(viewModel.checklistItems) { item in
                                    ChecklistItemView(
                                        item: item,
                                        selectedItemId: $selectedItemId,
                                        focusedField: $focusedField,
                                        isReadOnly: viewModel.isReadOnly
                                    )
                                }
                            }
                            .padding(.bottom, keyboardResponder.keyboardHeight)
                        }
                        // Auto-scroll when selected item changes
                        .onChange(of: selectedItemId) {
                            if let id = selectedItemId {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(id, anchor: .center)
                                }
                            }
                        }
                        // Also scroll when keyboard appears
                        .onChange(of: keyboardResponder.keyboardHeight) {
                            if keyboardResponder.keyboardHeight > 0, let id = selectedItemId {
                                withAnimation(.easeInOut(duration: 0.3)) {
                                    proxy.scrollTo(id, anchor: .center)
                                }
                            }
                        }
                        // Sync focusedField changes to selectedItemId
                        .onChange(of: focusedField) {
                            if focusedField != nil {
                                selectedItemId = focusedField
                            }
                        }
                    }
                    // Tap to dismiss keyboard
                    .onTapGesture {
                        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
                        selectedItemId = nil
                    }
                }
                
                // Bottom Button
                if !viewModel.isReadOnly {
                    VStack(alignment: .leading, spacing: 12) {
          
                            if part == .partA {
                                CommonButton(
                                    title: "safety_inspection_checklist_button_save_as_draft".localized(),
                                    style: .outlined,
                                    enabled: !viewModel.isSaving,
                                    maxWidth: .infinity
                                ) {
                                    handleSaveDraft()
                                }
                            }
                            
                            CommonButton(
                                title: part == .partA ? "general_submit".localized() : "safety_inspection_checklist_button_complete".localized(),
                                style: .contained,
                                enabled: !viewModel.isSaving,
                                maxWidth: .infinity
                            ) {
                                showConfirmAlert()
                            }
                        
                    }
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(Color.white)
                    .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 0)
                }
            }
        }
        .background(Color.white)
        .task {
            await viewModel.fetchChecklist()
        }
    }
}
