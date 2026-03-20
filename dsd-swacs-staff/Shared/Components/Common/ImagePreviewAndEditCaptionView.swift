//
//  ImagePreviewAndEditCaptionView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

extension UIApplication {
    func endEditing() {
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct ImagePreviewAndEditCaptionView: View {
    @Environment(\.dismiss) private var dismiss
    @StateObject private var keyboardResponder = KeyboardResponder()

    let image: UIImage
    @State var caption: String = ""
    var readonly: Bool = false
    var onConfirm: (_ caption: String) -> Void = { _ in }
    var onCancel: (() -> Void)? = nil

    @State private var scale: CGFloat = 1.0
    @GestureState private var gestureScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @GestureState private var gestureOffset: CGSize = .zero
    
    var body: some View {
        let totalScale = scale * gestureScale
        let totalOffset = CGSize(
            width: offset.width + gestureOffset.width,
            height: offset.height + gestureOffset.height
        )
        
        GeometryReader { geometry in
            let safeAreaBottom = geometry.safeAreaInsets.bottom

            ZStack {
                // Zoomable image
                Image(uiImage: image)
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .scaleEffect(totalScale)
                    .offset(totalOffset)
                    .gesture(
                        SimultaneousGesture(
                            MagnificationGesture()
                                .updating($gestureScale) { value, state, _ in
                                    state = value
                                }
                                .onEnded { value in
                                    let newScale = min(max(scale * value, 1), 4)
                                    scale = newScale
                                    if newScale == 1 {
                                        offset = .zero
                                    }
                                },
                            DragGesture()
                                .updating($gestureOffset) { value, state, _ in
                                    state = value.translation
                                }
                                .onEnded { value in
                                    if totalScale > 1 {
                                        offset.width += value.translation.width
                                        offset.height += value.translation.height
                                    }
                                }
                        )
                    )

                VStack {
                    HStack {
                        Button(action: { dismiss() }) {
                            Image("back-button")
                        }
                        .frame(width: 36, height: 36)
                        Spacer()
                    }
                    .padding(.leading, 16)
                    .padding(.top, 20)
                    .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
                    Spacer()

                    if readonly {
                        HStack {
                            if !caption.isEmpty {
                                Text(caption)
                                    .appFont(.robotoRegular, size: 16)
                                    .foregroundColor(Color.white)
                                    .padding(12)
                                    .background(Color.Neutral800.opacity(0.85))
                                    .cornerRadius(4)
                                    .lineLimit(2)
                            }
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 24)
                    } else {
                        HStack {
                            TextField(
                                "site_diary_detail_label_add_description".localized(),
                                text: $caption,
                                prompt: Text("site_diary_detail_label_add_description".localized()).foregroundColor(Color.Neutral300)
                            )
                            .blockEmoji($caption)
                            .appFont(.robotoRegular, size: 16)
                            .foregroundColor(Color.white)
                            .padding(12)
                            .background(Color.Neutral800.opacity(0.95))
                            .cornerRadius(4)
                            .lineLimit(1)
                            
                            
                            Button {
                                onConfirm(caption)
                                dismiss()
                            } label: {
                                Image("icon-image-upload")
                                    .resizable()
                                    .frame(width: 28, height: 28)
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, max(0, keyboardResponder.keyboardHeight - safeAreaBottom) + 12)
                    }
                }
                .animation(.easeInOut(duration: 0.2), value: keyboardResponder.keyboardHeight)
            }
            .background(Color.black)
            .contentShape(Rectangle())
            .onTapGesture {
                if keyboardResponder.keyboardHeight > 0 {
                    UIApplication.shared.endEditing()
                }
            }
        }
    }
}


struct ImagePreviewAndEditCaptionView_Previews: PreviewProvider {
    static var previews: some View {
        ImagePreviewAndEditCaptionView(
            image: UIImage(systemName: "photo")!,
            onConfirm: { caption in }
        )
    }
}
