//
//  CustomCommentBottomSheetView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 30/10/2025.
//

import SwiftUI

struct CustomCommentBottomSheetView: View {
    @Binding var isPresented: Bool
    @State var commentText: String = ""
    @FocusState private var isCommentFocused: Bool
    var onSend: (_ comment: String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 24) {

            HStack(alignment: .center) {
                Text("site_diary_detail_label_instructions_to_contractor".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(Color.Neutral800)
                Spacer()
                Button(action: {
                    withAnimation { isPresented = false }
                }) {
                    Image("close-button")
                        .resizable()
                        .frame(width: 22, height: 22)
                }
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .center)

            CustomPlaceholderTextEditor(
                text: $commentText,
                placeholder: "site_diary_detail_placeholder_type_here".localized()
            )
            .frame(height: 140)
            .focused($isCommentFocused)

            CommonButton(
                title: "site_diary_detail_button_send_back".localized(),
                style: .contained,
                enabled: !commentText.trimmingCharacters(in: .whitespaces).isEmpty,
                maxWidth: .infinity,
                backgroundColor: !commentText.trimmingCharacters(in: .whitespaces).isEmpty ? .red : Color.Neutral300
            ) {
                withAnimation { isPresented = false }
                onSend(commentText)
            }
        }
        .onTapGesture {
            isCommentFocused = false
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, minHeight: 300, maxHeight: 320, alignment: .topLeading)
        .background(Color.white)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    struct PreviewWrapper: View {
        @State private var showBottomSheet = true
        @State private var commentText = ""

        var body: some View {
            VStack {
                Button("Show Comment Sheet") {
                    showBottomSheet = true
                }
            }
            .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(320)]) {
                CustomCommentBottomSheetView(
                    isPresented: $showBottomSheet,
                    onSend: { text in print("Send:", text) }
                )
            }
        }
    }

    return PreviewWrapper()
}
#endif
