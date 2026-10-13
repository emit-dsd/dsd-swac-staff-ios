//
//  SiteDiaryNewEntryView.swift
//  dsd-swacs-staff
//

import SwiftUI

struct SiteDiaryNewEntryView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    @StateObject private var keyboardResponder = KeyboardResponder()
    @FocusState private var isDescFocused: Bool
    
    @StateObject private var viewModel: SiteDiaryNewEntryViewModel
    
    @State private var editingAsset: ImageAsset? = nil
    @State private var showPickerOption = false
    @State private var showImagePicker = false
    @State private var showCameraPicker = false
    @State private var pickerImage: UIImage?

    
    private let maxImageSizeMB: Double = 5.0
    
    init(swacNumber: String) {
        _viewModel = StateObject(wrappedValue: SiteDiaryNewEntryViewModel(swacNumber: swacNumber))
    }
    
    // MARK: - Computed Properties
    var descriptionTitleAttributedString: AttributedString {
        var text = AttributedString("site_diary_detail_label_brief_description".localized() + " " + "site_diary_detail_label_max_words".localized())
        text.foregroundColor = Color.Primary800
        text.font = .custom("Roboto", size: 14)
        
        var star = AttributedString(" *")
        star.foregroundColor = .red
        star.font = .custom("Roboto", size: 14)
        
        text.append(star)
        return text
    }
    
    // MARK: - Navigation & Alert Logic
    private func handleBackTapped() {
        if viewModel.hasUnsavedChanges {
            showLeaveAlert()
        } else {
            tabStore.popLastOnCurrentPath()
        }
    }
    
    private func showLeaveAlert() {
        alertManager.show(
            title: "site_diary_detail_alertTitle_leave".localized(),
            message: "site_diary_detail_alertMessage_leave".localized(),
            buttons: [
                CommonButtonModel(
                    title: "site_diary_detail_button_confirm_leave".localized(),
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
                    action: {
                      
                    }
                )
            ]
        )
    }

    // MARK: - Image Handling
    private func handleImageConfirm(_ newCaption: String, for asset: ImageAsset) {
        guard let img = asset.image else {
            cleanupImageState()
            return
        }
        
        let (isValid, sizeMB) = viewModel.validateImageSize(img, maxSizeMB: maxImageSizeMB)
        
        guard isValid else {
            showFileSizeAlert(actualSize: sizeMB)
            cleanupImageState()
            return
        }
        
        var updatedAsset = asset
        updatedAsset.caption = newCaption
        
        if viewModel.images.contains(where: { $0.id == asset.id }) {
            viewModel.updateImage(updatedAsset)
        } else {
            viewModel.addImage(updatedAsset)
        }
        
        cleanupImageState()
    }
    
    private func cleanupImageState() {
        editingAsset = nil
        pickerImage = nil
    }
    
    private func showFileSizeAlert(actualSize: Double) {
        alertManager.show(
            title: "site_diary_detail_alertTitle_file_size".localized(),
            message: "site_diary_detail_alertMessage_file_size".localized().replacingOccurrences(of: "{R1}", with: String(format: "%.2f", actualSize)),
            buttons: [
                CommonButtonModel(
                    title: "general_confirm".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    textColor: .white,
                    backgroundColor: .red,
                    action: {}
                )
            ]
        )
    }
    
    // MARK: - Submit Flow
    private func confirmAlert() {
        alertManager.show(
            title: "site_diary_detail_alertTitle_confirm_submit".localized(),
            message: "site_diary_detail_alertMessage_confirm_submit".localized(),
            buttons: [
                CommonButtonModel(
                    title: "site_diary_detail_button_confirm_submit".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        Task { await submitDiary() }
                    }
                ),
                CommonButtonModel(
                    title: "general_cancel".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {}
                )
            ]
        )
    }
    
    private func submitDiary() async {
        do {
            let diaryId = try await viewModel.submitSiteDiary()
            
            Logger.debug(tag: "SiteDiary", "✅ Site Diary submitted: \(diaryId)")
            
            await MainActor.run {
                alertManager.close()
                Task {
                    try? await Task.sleep(nanoseconds: 100_000_000)
                    showSuccessAlert()
                }
            }
        } catch {
            Logger.error(tag: "SiteDiary", "❌ Failed to submit: \(error)")
        }
    }
    
    // MARK: - Alerts
    private func showSuccessAlert() {
        alertManager.show(
            title: "site_diary_detail_alertTitle_submitted".localized(),
            message: "site_diary_detail_alertMessage_submitted".localized(),
            image: "icon-alert-success",
            buttons: [
                CommonButtonModel(
                    title: "general_back".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        tabStore.popLastOnCurrentPath()
                    }
                )
            ]
        )
    }
    
    @ViewBuilder
    private func renderImagePreviewEditor(for asset: ImageAsset) -> some View {
        if let img = asset.image {
            ImagePreviewAndEditCaptionView(
                image: img,
                caption: asset.caption,
                onConfirm: { newCaption in
                    handleImageConfirm(newCaption, for: asset)
                },
                onCancel: {
                    cleanupImageState()
                }
            )
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                CustomNavBarView(
                    type: .backOnly,
                    title: "site_diary_detail_new_diary_entry_title".localized(),
                    onBackTapped: handleBackTapped
                )
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else if let swacDetail = viewModel.swacDetail {
                    mainContent(swacDetail: swacDetail)
                } else {
                    errorContent
                }
            }
        }
        .commonBottomSheet(isPresented:  $showPickerOption, detents: [.height(160)]) {
            VStack(alignment: .leading, spacing: 16) {
                CommonButton(
                    title: "site_diary_detail_button_take_photo".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    showPickerOption = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showCameraPicker = true
                    }
                }
                
                CommonButton(
                    title: "site_diary_detail_button_select_from_gallery".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    showPickerOption = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showImagePicker = true
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.white)
        }
        .background(Color.white)
        .task {
            await viewModel.fetchSWACDetail()
        }
    }
    
    // MARK: - View Components
    
    @ViewBuilder
    private func mainContent(swacDetail: SWACDetail) -> some View {
        VStack(spacing: 0) {
            ScrollViewReader { proxy in
                ScrollView {
                    VStack(spacing: 24) {
                        SWACInfoView(swacDetail: swacDetail)
                        
                        CustomDropdownView(
                            title: "site_diary_detail_label_inform_to_approve".localized(),
                            selectedItem: $viewModel.selectedApprove,
                            items:viewModel.approverList,
                            placeholder: "site_diary_detail_placeholder_inform_to_approve".localized(),
                            isMandatory: true
                        )
                        
                        CustomDatePickerView(
                            title: "site_diary_detail_label_date".localized(),
                            date: $viewModel.date,
                            placeholder: "site_diary_detail_label_pick_date".localized(),
                            isMandatory: true,
                            range: Date.distantPast...Date(),
                            displayFormat: .custom("yyyy-MM-dd")
                        )
                        
                        WeatherSelector(selectedWeatherAM: $viewModel.selectedWeatherAM, selectedWeatherPM: $viewModel.selectedWeatherPM)
                        
                        labourSection
                        
                        descriptionSection
                        
                        instructionSection
                        
                        responsesSection
                        
                        imageSection
                        
                        
                    }
                }
                .contentMargins(.vertical, 24, for: .scrollContent)
                .contentMargins(.horizontal, 16, for: .scrollContent)
                .onChange(of: isDescFocused) {
                    if isDescFocused {
                        withAnimation {
                            proxy.scrollTo("descEditor", anchor: .center)
                        }
                    }
                }
                .onTapGesture {
                    if keyboardResponder.keyboardHeight > 0 {
                        UIApplication.shared.endEditing()
                    }
                }
            }
            
            submitButton
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
    
    private var labourSection: some View {
        VStack(spacing: 8) {
            HStack {
                Text("site_diary_detail_label_no_of_labour".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                
                Text("*")
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.red)
                Spacer()
            }
            TextField(
                "site_diary_detail_placeholder_no_of_labour".localized(),
                text: Binding(
                    get: {
                        viewModel.labour.map { "\($0)" } ?? ""
                    },
                    set: { newValue in
                        if newValue.isEmpty {
                            viewModel.labour = nil
                        } else if let intVal = Int(newValue.filter { $0.isNumber }) {
                            viewModel.labour = min(255, max(0, intVal))
                        }
                    }
                )
            )
            .appFont(.robotoRegular, size: 14)
            .keyboardType(.numberPad)
            .padding(12)
            .background(Color.Neutral100)
            .cornerRadius(8)
        }
    }

    private var descriptionSection: some View {
        VStack(spacing: 8) {
            Text(descriptionTitleAttributedString)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CustomPlaceholderTextEditor(
                text: $viewModel.descriptionText,
                placeholder: "site_diary_detail_placeholder_type_here".localized()
            )
            .id("descEditor")
            .focused($isDescFocused)
            .frame(height: 200)
        }
    }
    
    private var instructionSection: some View {
        VStack(spacing: 8) {
            Text("site_diary_detail_label_instructions_representative".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(Color.Primary800)
                .frame(maxWidth: .infinity, alignment: .leading)
           
            CustomPlaceholderTextEditor(
                text: $viewModel.instructionText,
                placeholder: "site_diary_detail_placeholder_type_here".localized()
            )
            .frame(height: 200)
        }
    }
    
    private var responsesSection: some View {
        VStack(spacing: 8) {
            Text("site_diary_detail_label_response_representative".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(Color.Primary800)
                .frame(maxWidth: .infinity, alignment: .leading)
            
            CustomPlaceholderTextEditor(
                text: $viewModel.responseText,
                placeholder: "site_diary_detail_placeholder_type_here".localized()
            )
            .frame(height: 200)
        }
    }
    
    private var imageSection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Text("site_diary_detail_label_image".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                Spacer()
                
                CommonButton(
                    title: "site_diary_detail_label_add_new".localized(),
                    style: .text,
                    enabled: true,
                    isUnderline: true
                ) {
                    showPickerOption = true
                }
            }
            
            HorizontalImagePickerView(
                 images: $viewModel.images,
                 onAdd: { showPickerOption = true },
                 onRemove: { asset in viewModel.removeImage(asset) },
                 onEdit: { asset in editingAsset = asset }
             )
             .sheet(isPresented: $showImagePicker) {
                 CustomImagePicker(image: $pickerImage, sourceType: .photoLibrary)
             }
             .fullScreenCover(isPresented: $showCameraPicker) {
                 CustomImagePicker(image: $pickerImage, sourceType: .camera)
                     .ignoresSafeArea()
             }
             .onChange(of: pickerImage) {
                 if let img = pickerImage {
                     editingAsset = ImageAsset(image: img, caption: "")
                 }
             }
             .fullScreenCover(item: $editingAsset) { asset in
                 renderImagePreviewEditor(for: asset)
             }
        }
    }

    private var submitButton: some View {
        CommonButton(
            title: "site_diary_detail_button_sign_and_submit".localized(),
            style: .contained,
            enabled: viewModel.canSubmit,
            maxWidth: .infinity
        ) {
            confirmAlert()
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 12)
    }
    
    private var errorContent: some View {
        VStack {
            Text("site_diary_detail_error_loading_swac".localized())
                .foregroundColor(.red)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#if DEBUG
#Preview {
    SiteDiaryNewEntryView(swacNumber: "003H")
        .environmentObject(TabNavigationStore())
        .environmentObject(AlertManager.shared)
}
#endif
