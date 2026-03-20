//
//  HorizontalImagePickerView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

struct ImageAsset: Identifiable, Hashable {
    let id: UUID = UUID()
    let image: UIImage?
    var caption: String
}

struct HorizontalImagePickerView: View {
    @Binding var images: [ImageAsset]
    
    var readonly: Bool = false
    var maxImages: Int? = nil
    var imageSize: CGSize = CGSize(width: 220, height: 260)
    var showCaption: Bool = true
    var requiresCaption: Bool = true
    var onAdd: (() -> Void)? = nil
    var onRemove: ((ImageAsset) -> Void)? = nil
    var onEdit: ((ImageAsset) -> Void)? = nil
    
    // MARK: - Computed Properties
    
    /// Check if can add more images
    private var canAddMore: Bool {
        guard let maxImages = maxImages else { return true }
        return images.count < maxImages
    }
    
    /// Remaining slots count
    private var remainingCount: Int? {
        guard let maxImages = maxImages else { return nil }
        return max(0, maxImages - images.count)
    }
    
    // MARK: - Body
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 20) {
                ForEach(images, id: \.id) { asset in
                    imageCard(for: asset)
                }

                // Add button (only if not readonly and not reached limit)
                if !readonly, canAddMore, let onAdd = onAdd {
                    addButton
                }
            }
        }
    }
    
    // MARK: - Subviews
    
    @ViewBuilder
    private func imageCard(for asset: ImageAsset) -> some View {
        ZStack(alignment: .topTrailing) {
            VStack {
                if let uiImage = asset.image {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: imageSize.width, height: imageSize.height)
                        .clipped()
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onEdit?(asset)
                        }
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.2))
                        .frame(width: imageSize.width, height: imageSize.height)
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                        .cornerRadius(4)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            onEdit?(asset)
                        }
                }
            }
            
            // Remove button
            if !readonly, let onRemove = onRemove {
                Button(action: { onRemove(asset) }) {
                    Image("close-button-black")
                        .resizable()
                        .frame(width: 28, height: 28)
                }
                .offset(x: -8, y: 8)
            }
            
            // Caption overlay (only if showCaption is true)
            if showCaption {
                VStack {
                    Spacer()
                    HStack(alignment: .center, spacing: 0) {
                        Text(asset.caption.isEmpty ? "site_diary_detail_label_caption".localized() : asset.caption)
                            .appFont(.robotoRegular, size: 10)
                            .foregroundColor(Color.white)
                            .frame(maxWidth: .infinity, alignment: .topLeading)
                            .lineLimit(1)
                    }
                    .padding(8)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                    .background(.black.opacity(0.6))
                    .cornerRadius(30)
                    .padding(.bottom, 4)
                }
                .padding(4)
            }
        }
        .frame(width: imageSize.width, height: imageSize.height)
    }
    
    private var addButton: some View {
        Button(action: { onAdd?() }) {
            VStack(alignment: .center, spacing: 4) {
                Image("icon-add-new-image")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(Color.Neutral300)
                
                Text("site_diary_detail_label_add_new".localized())
                    .appFont(.robotoBold, size: 16)
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
        }
        .disabled(!canAddMore)
        .opacity(canAddMore ? 1.0 : 0.5)
    }
}

// MARK: - Convenience Initializers

extension HorizontalImagePickerView {
    /// Single image picker
    static func single(
        image: Binding<ImageAsset?>,
        imageSize: CGSize = CGSize(width: 220, height: 260),
        readonly: Bool = false,
        showCaption: Bool = true,
        requiresCaption: Bool = true,
        onAdd: (() -> Void)? = nil,
        onEdit: ((ImageAsset) -> Void)? = nil
    ) -> some View {
        let binding = Binding<[ImageAsset]>(
            get: {
                if let img = image.wrappedValue {
                    return [img]
                }
                return []
            },
            set: { newValue in
                image.wrappedValue = newValue.first
            }
        )
        
        return HorizontalImagePickerView(
            images: binding,
            readonly: readonly,
            maxImages: 1,
            imageSize: imageSize,
            showCaption: showCaption,
            requiresCaption: requiresCaption,
            onAdd: onAdd,
            onRemove: { _ in
                image.wrappedValue = nil
            },
            onEdit: onEdit
        )
    }
}
