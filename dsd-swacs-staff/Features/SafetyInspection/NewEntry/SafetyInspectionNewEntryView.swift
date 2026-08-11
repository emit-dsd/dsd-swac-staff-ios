//
//  SafetyInspectionNewEntryView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//

import SwiftUI

struct SafetyInspectionNewEntryView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    
    @StateObject private var viewModel: SafetyInspectionNewEntryViewModel
    let part: SafetyInspectionPart
    
    @State private var showPermitImagePicker = false
    @State private var showRAImagePicker = false
    @State private var showPermitCompletePicker = false

    @State private var showPermitPickerOption = false
    @State private var showRAPickerOption = false
    @State private var showPermitCompletePickerOption = false
    
    @State private var showPermitCameraPicker = false
    @State private var showRACameraPicker = false
    @State private var showPermitCompleteCameraPicker = false

    @State private var permitPickerImage: UIImage?
    @State private var raPickerImage: UIImage?
    @State private var permitCompletePickerImage: UIImage?
    
    @State private var editingAsset: ImageAsset? = nil
    
    private let maxImageSizeMB: Double = 5.0
    private let imageSize = CGSize(width: 160, height: 120)
    
    init(swacNumber: String, draft: SafetyInspectionDraft? = nil, inspectionId: Int? = nil, part: SafetyInspectionPart = .partA) {
        self.part = part
        _viewModel = StateObject(wrappedValue: SafetyInspectionNewEntryViewModel(swacNumber: swacNumber, draft: draft, inspectionId: inspectionId, part: part))
    }
    
    // MARK: - Helper Methods
    private func imageSizeInMB(_ image: UIImage) -> Double {
        guard let data = image.jpegData(compressionQuality: 1.0) else { return 0 }
        return Double(data.count) / (1024.0 * 1024.0)
    }
    
    private func validateImage(_ image: UIImage) -> Bool {
        let imgSizeMB = imageSizeInMB(image)
        if imgSizeMB > maxImageSizeMB {
            showFileSizeAlert(actualSize: imgSizeMB)
            return false
        }
        return true
    }
    
    private func showFileSizeAlert(actualSize: Double) {
        alertManager.show(
            title: "site_diary_detail_alertTitle_file_size".localized(),
            message: "site_diary_detail_alertMessage_file_size".localized()
                .replacingOccurrences(of: "{R1}", with: String(format: "%.2f MB", actualSize)),
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
    
    private func leaveAlert() {
        if viewModel.shouldShowLeaveAlert {
            alertManager.show(
                title: "safety_inspection_detail_alertTitle_leave".localized(),
                message: "safety_inspection_detail_alertMessage_leave".localized(),
                buttons: [
                    CommonButtonModel(
                        title: "safety_inspection_detail_button_confirm_leave".localized(),
                        style: .contained,
                        enabled: true,
                        maxWidth: .infinity,
                        backgroundColor: .red,
                        action: {
                            tabStore.popLastOnCurrentPath()
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
        } else {
            tabStore.popLastOnCurrentPath()
        }
    }
    
    private func handleNext() {
        if part == .full || (viewModel.isReadOnly && part == .partA) {
            let results = viewModel.apiResults ?? []
            tabStore.appendToCurrentPath(Screen.SafetyInspectionChecklistReadOnly(results, part))
        } else {
            let draft = viewModel.createDraftPayload()
            tabStore.appendToCurrentPath(Screen.SafetyInspectionChecklist(draft, part))
        }
    }
    
    // MARK: - Subviews
    @ViewBuilder
    private func imageSection(
        title: String,
        images: Binding<[ImageAsset]>,
        showPickerOption: Binding<Bool>,
        showImagePicker: Binding<Bool>,
        showCameraPicker: Binding<Bool>,
        pickerImage: Binding<UIImage?>,
        readOnly: Bool = false
    ) -> some View {
        VStack(spacing: 8) {
            HStack(alignment: .center) {
                Text(title)
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                
                Spacer()
                
                if !readOnly && !viewModel.isLoadingAttachments {
                    CommonButton(
                        title: "safety_inspection_detail_button_add_new".localized(),
                        style: .text,
                        enabled: true,
                        isUnderline: true
                    ) {
                        showPickerOption.wrappedValue = true
                    }
                }
            }
            .frame(minHeight: 44)
            
            if viewModel.isLoadingAttachments && readOnly {
                loadingImagesView
            } else if readOnly {
                if images.wrappedValue.isEmpty {
                    emptyImagePlaceholder
                } else {
                    HorizontalImagePickerView(
                        images: .constant(images.wrappedValue),
                        readonly: true,
                        imageSize: imageSize,
                        showCaption: false,
                        onEdit: { asset in
                            editingAsset = nil
                            DispatchQueue.main.async {
                                editingAsset = asset
                            }
                        }
                    )
                }
            } else {
                HorizontalImagePickerView(
                    images: images,
                    imageSize: imageSize,
                    showCaption: false,
                    onAdd: { showPickerOption.wrappedValue = true },
                    onRemove: { assetToRemove in
                        images.wrappedValue.removeAll { $0.id == assetToRemove.id }
                    },
                    onEdit: { asset in editingAsset = asset }
                )
            }
        }
        .sheet(isPresented: showImagePicker) {
            CustomImagePicker(image: pickerImage, sourceType: .photoLibrary)
        }
        .fullScreenCover(isPresented: showCameraPicker) {
            CustomImagePicker(image: pickerImage, sourceType: .camera)
                .ignoresSafeArea()
        }
        .commonBottomSheet(isPresented: showPickerOption, detents: [.height(160)]) {
            VStack(alignment: .leading, spacing: 16) {
                CommonButton(
                    title: "site_diary_detail_button_take_photo".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    showPickerOption.wrappedValue = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showCameraPicker.wrappedValue = true
                    }
                }
                
                CommonButton(
                    title: "site_diary_detail_button_select_from_gallery".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    showPickerOption.wrappedValue = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        showImagePicker.wrappedValue = true
                    }
                }
            }
            .padding(.horizontal, 24)
            .padding(.top, 24)
            .padding(.bottom, 24)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.white)
        }
    }
    
    private var loadingImagesView: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                ProgressView().scaleEffect(1)
            }
            .padding(0)
            .frame(width: imageSize.width, height: imageSize.height, alignment: .center)
            .background(Color.Neutral100)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 0.5)
                    .stroke(Color.Neutral300, lineWidth: 1)
            )
          
            Spacer()
        }
    }
    
    private var emptyImagePlaceholder: some View {
        HStack(alignment: .center) {
            VStack(alignment: .center, spacing: 4) {
                Image("icon-add-new-image")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.Neutral300)
            }
            .padding(0)
            .frame(width: imageSize.width, height: imageSize.height, alignment: .center)
            .background(Color.Neutral100)
            .cornerRadius(4)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 0.5)
                    .stroke(Color.Neutral300, lineWidth: 1)
            )
            Spacer()
        }
    }
    
    
    @ViewBuilder
    private var readOnlyFields: some View {
        VStack(spacing: 24) {
            InfoRowView(title: "safety_inspection_detail_label_date_of_checking".localized(), value: viewModel.date.toString(format: "yyyy-MM-dd HH:mm"))
            InfoRowView(title: "safety_inspection_detail_label_work_details".localized(), value: viewModel.workDetails)
            InfoRowView(title: "safety_inspection_detail_label_type_of_confined_space".localized(), value: viewModel.typeOfConfinedSpace)
        }
    }
    
    @ViewBuilder
    private var editFields: some View {
        VStack(spacing: 24) {
            CustomDatePickerView(
                title: "safety_inspection_detail_label_date_of_checking".localized(),
                date: $viewModel.date,
                placeholder: "",
                isMandatory: false,
                range: Date.distantPast...Date(),
                displayFormat: .custom("yyyy-MM-dd HH:mm")
            )
            
            CustomInputView(
                title: "safety_inspection_detail_label_work_details".localized(),
                text: $viewModel.workDetails,
                placeholder: "safety_inspection_detail_label_work_details".localized(),
                mode: .default
            )
            
            CustomInputView(
                title: "safety_inspection_detail_label_type_of_confined_space".localized(),
                text: $viewModel.typeOfConfinedSpace,
                placeholder: "safety_inspection_detail_label_type_of_confined_space".localized(),
                mode: .default
            )
        }
    }
    
    // MARK: - Body
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                let navTitleKey: String = {
                    switch part {
                    case .partA:
                        // Part A: 判斷是新建/編輯 還是 唯讀
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
                    type: .backOnly,
                    title:  navTitleKey.localized(),
                    onBackTapped: leaveAlert
                )
                
                if viewModel.isLoading {
                    ProgressView()
                        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                } else if let swacDetail = viewModel.swacDetail {
                    ScrollView {
                        VStack(spacing: 24) {
                            SafetyInspectionSWACInfoView(swacDetail: swacDetail)
                            
                            // Form Fields: 如果是 Part B 或已存在的舊單，這裡會是 readOnlyFields
                            if viewModel.isReadOnly {
                                readOnlyFields
                            } else {
                                editFields
                            }
                            
                            // ---- Part A  ----
                            if part == .partA || part == .full {
                                // Images - Permit to Work
                                imageSection(
                                    title: "safety_inspection_detail_label_permit_to_work".localized(),
                                    images: $viewModel.permitImages,
                                    showPickerOption: $showPermitPickerOption,
                                    showImagePicker: $showPermitImagePicker,
                                    showCameraPicker: $showPermitCameraPicker,
                                    pickerImage: $permitPickerImage,
                                    readOnly: !viewModel.canEditPartAImages
                                )
                                .onChange(of: permitPickerImage) { _, newValue in
                                    if let img = newValue, validateImage(img) { viewModel.addPermitImage(img) }
                                    permitPickerImage = nil
                                }
                                
                                // Images - Fresh RA
                                imageSection(
                                    title: "safety_inspection_detail_label_fresh_ra".localized(),
                                    images: $viewModel.raImages,
                                    showPickerOption: $showRAPickerOption,
                                    showImagePicker: $showRAImagePicker,
                                    showCameraPicker: $showRACameraPicker,
                                    pickerImage: $raPickerImage,
                                    readOnly: !viewModel.canEditPartAImages
                                )
                                .onChange(of: raPickerImage) { _, newValue in
                                    if let img = newValue, validateImage(img) { viewModel.addRAImage(img) }
                                    raPickerImage = nil
                                }
                            }
                            
                            // ---- Part B  ----
                            if part == .partB || part == .full {
                                // Images - Permit Complete
                                imageSection(
                                    title: "safety_inspection_detail_label_permit_to_work_complete".localized(),
                                    images: $viewModel.permitCompleteImages,
                                    showPickerOption: $showPermitCompletePickerOption,
                                    showImagePicker: $showPermitCompletePicker,
                                    showCameraPicker: $showPermitCompleteCameraPicker,
                                    pickerImage: $permitCompletePickerImage,
                                    readOnly: !viewModel.canEditPartBImages
                                )
                                .onChange(of: permitCompletePickerImage) { _, newValue in
                                    if let img = newValue, validateImage(img) { viewModel.addPermitCompleteImage(img) }
                                    permitCompletePickerImage = nil
                                }
                            }
                        }
                        .padding(.vertical, 24)
                        .padding(.horizontal, 16)
                    }
                } else {
                    VStack {
                        Text("site_diary_detail_error_loading_swac".localized())
                            .foregroundColor(.red)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                }
                
                // Bottom Button
                VStack(alignment: .leading, spacing: 12) {
                    CommonButton(
                        title: "general_next".localized(),
                        style: .contained,
                        enabled: (part == .full || (viewModel.isReadOnly && part == .partA)) || viewModel.isFormComplete,
                        maxWidth: .infinity
                    ) {
                        handleNext()
                    }
                }
                .padding(.horizontal, 24)
                .padding(.vertical, 12)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(Color.white)
        }
        .background(Color.white)
        .fullScreenCover(item: $editingAsset) { asset in
            ImagePreviewAndEditCaptionView(
                image: asset.image ?? UIImage(),
                caption: asset.caption,
                readonly: true
            )
        }
        .task {
            await viewModel.loadData()
        }
    }
    

}
