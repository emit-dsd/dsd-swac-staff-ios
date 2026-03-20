//
//  SiteDiaryDetailDiaryView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

struct SiteDiaryDetailDiaryView: View {
    @EnvironmentObject var alertManager: AlertManager
    @EnvironmentObject var tabStore: TabNavigationStore
    @StateObject private var keyboardResponder = KeyboardResponder()
    @FocusState private var isDescFocused: Bool
    
    @ObservedObject var viewModel: SiteDiaryDetailViewModel  // ⬅️ 改為接收 ViewModel
    
    @State private var descriptionText: String = ""
    @State private var remarkText: String = ""
    @State private var editingAsset: ImageAsset? = nil
    
    private let initialDescriptionText: String
    private let imageCardSize = CGSize(width: 220, height: 260)
    let swacDetail: SWACDetail
    let siteDiary: SiteDiary
    
    init(viewModel: SiteDiaryDetailViewModel, swacDetail: SWACDetail, siteDiary: SiteDiary) {
        self.viewModel = viewModel
        self.swacDetail = swacDetail
        self.siteDiary = siteDiary
        self.initialDescriptionText = siteDiary.workActivity
        _descriptionText = State(initialValue: siteDiary.workActivity)
    }
    
    // MARK: - Computed Properties
    
    var descriptionTitleAttributedString: AttributedString {
        var text = AttributedString("site_diary_detail_label_brief_description".localized() +
                                    "site_diary_detail_label_max_words".localized())
        text.foregroundColor = Color.Neutral800
        text.font = .custom("Roboto", size: 14)
        
        var star = AttributedString(" *")
        star.foregroundColor = .red
        star.font = .custom("Roboto", size: 14)
        
        text.append(star)
        return text
    }
    
    var isEditable: Bool {
        return siteDiary.status == .pendingDSDEndorsement
    }
    
    // MARK: - Subviews
    
    var swacSection: some View {
        SWACInfoView(swacDetail: swacDetail)
    }
    
    var statusSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("site_diary_detail_label_status".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(.Neutral500)
            StatusTag(status: siteDiary.status)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
    
    var dateAndWeatherSection: some View {
        HStack(alignment: .top, spacing: 24) {
            InfoRowView(title: "site_diary_detail_label_date".localized(), value: siteDiary.dateDisplayString)
            
            if let status = WeatherStatus(rawValue: siteDiary.weather) {
                VStack(alignment: .leading, spacing: 8) {
                    Text("site_diary_detail_label_weather_status".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                    WeatherIconView(status:status)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
    }
    
    var representativeSection: some View {
        HStack(alignment: .top, spacing: 24) {
            InfoRowView(
                title: "site_diary_detail_label_dsd_rep".localized(),
                value: siteDiary.siteInCharge ?? "-"
            )
            InfoRowView(
                title: "site_diary_detail_label_contractor_rep".localized(),
                value: siteDiary.contractor ?? "-"
            )
        }
    }
    
    @ViewBuilder
    var workActivitySection: some View {
//        if isEditable {
//            editableWorkActivitySection
//        } else {
            InfoRowView(
                title: "site_diary_detail_label_brief_description".localized(),
                value: siteDiary.workActivity
            )
//        }
    }
    
    var editableWorkActivitySection: some View {
        VStack(spacing: 8) {
            HStack(alignment: .center, spacing: 4) {
                Image("icon-pen")
                    .frame(width: 16, height: 16)
                Text(descriptionTitleAttributedString)
                Spacer()
                resetButton
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            
            CustomPlaceholderTextEditor(
                text: $descriptionText,
                placeholder: "site_diary_detail_placeholder_type_here".localized()
            )
            .id("descEditor")
            .focused($isDescFocused)
            .frame(height: 162)
            .overlay(
                RoundedRectangle(cornerRadius: 4)
                    .inset(by: 0.5)
                    .stroke(Color.Primary500, lineWidth: 1)
            )
        }
    }
    
    var resetButton: some View {
        CommonButton(
            title: "general_reset".localized(),
            style: .text,
            enabled: descriptionText != initialDescriptionText,
            isUnderline: true
        ) {
            descriptionText = initialDescriptionText
        }
    }
    
    var instructionSection: some View {
        Group {
            if let instruction = siteDiary.instruction, siteDiary.hasInstruction {
                InfoRowView(
                    title: "site_diary_detail_label_instructions_representative".localized(),
                    value: instruction
                )
            }
        }
    }
    
    var responseSection: some View {
        Group {
            if let response = siteDiary.response, siteDiary.hasResponse {
                InfoRowView(
                    title: "site_diary_detail_label_response_representative".localized(),
                    value: response
                )
            }
        }
    }
    
    var imageSection: some View {
        VStack(spacing: 8) {
            if siteDiary.hasAttachments {
                Text("site_diary_detail_label_image".localized())
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.Neutral500)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                if viewModel.isLoadingAttachments {
                    loadingImagesView
                } else {
                    HorizontalImagePickerView(
                        images: .constant(viewModel.imageAssets),
                        readonly: true,
                        imageSize: imageCardSize,
                        onEdit: { asset in
                            editingAsset = asset
                        }
                    )
                }
            }
        }
    }
    
    private var loadingImagesView: some View {
         ScrollView(.horizontal, showsIndicators: false) {
             HStack(spacing: 20) {
                 ForEach(0..<siteDiary.attachment.count, id: \.self) { index in
                     LoadingImagePlaceholder(size: imageCardSize)
                 }
             }
         }
     }
    
    struct LoadingImagePlaceholder: View {
        let size: CGSize
        
        var body: some View {
            Rectangle()
                .fill(Color.gray.opacity(0.2))
                .frame(width: size.width, height: size.height)
                .overlay(
                    ProgressView()
                        .scaleEffect(1)
                        .padding(.leading, 4)
                )
                .cornerRadius(4)
                .contentShape(Rectangle())
        }
    }
    
    var mainContent: some View {
        VStack(spacing: 16) {
            swacSection
            statusSection
            dateAndWeatherSection
            representativeSection
            workActivitySection
            instructionSection
            responseSection
            imageSection
        }
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack {
            ScrollViewReader { proxy in
                ScrollView {
                    mainContent
                }
                .contentMargins(.top, 24, for: .scrollContent)
                .contentMargins(.bottom, 36, for: .scrollContent)
                .contentMargins(.horizontal, 16, for: .scrollContent)
                .onChange(of: isDescFocused) { _, isFocused in
                    if isFocused {
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
        }
        .fullScreenCover(item: $editingAsset) { asset in
            ImagePreviewAndEditCaptionView(
                image: asset.image ?? UIImage(),
                caption: asset.caption,
                readonly: true
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
        .background(Color.white)
    }
}

// MARK: - Preview

#if DEBUG
#Preview {
    let viewModel = SiteDiaryDetailViewModel(
        swacNumber: SWACDetail.preview.number,
        diaryId: SiteDiary.previewArchived.id
    )
    
    SiteDiaryDetailDiaryView(
        viewModel: viewModel,
        swacDetail: SWACDetail.preview,
        siteDiary: SiteDiary.previewArchived
    )
    .environmentObject(TabNavigationStore())
    .environmentObject(AlertManager.shared)
}
#endif
