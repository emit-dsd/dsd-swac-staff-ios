//
//  SafetyVettingRemarkBottomSheetView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 9/4/2026.
//

import SwiftUI

struct SafetyVettingRemarkBottomSheetView: View {
    @Binding var isPresented: Bool
    @Binding var isApprove: Bool
    let onConfirm: (String) -> Void
    
    @State private var remarks: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header

            HStack(alignment: .center) {
                Text("swac_detail_label_remark".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(Color.Neutral800)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image("close-button")
                        .resizable()
                        .frame(width: 22, height: 22)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            CustomPlaceholderTextEditor(
                text: $remarks,
                placeholder: "swac_detail_placeholder_type_here".localized()
            )
            .frame(height: 132)
            
            CommonButton(
                title: isApprove ? "swac_detail_button_confirm_pass".localized() : "swac_detail_button_confrim_fail".localized(),
                style: isApprove ? .contained : .contained,
                enabled: true,
                maxWidth: .infinity,
                textColor: Color.white,
                backgroundColor: isApprove ? .Primary600 : Color.red 
            ) {
                isPresented = false
                onConfirm(remarks)
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, minHeight: 320, alignment: .topLeading)
        .background(Color.white)
    }
}
