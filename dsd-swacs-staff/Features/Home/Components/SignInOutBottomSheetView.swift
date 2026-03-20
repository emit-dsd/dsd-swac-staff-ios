//
//  SignInOutBottomSheetView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/10/2025.
//

import SwiftUI

struct SignInOutBottomSheetView: View {
    @Binding var isPresented: Bool
    var onSignIn: () -> Void
    var onSignOut: () -> Void
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                Text("quick_action_label_sign_title".localized()).appFont(.robotoBold, size: 18) .foregroundColor(Color.Neutral800)
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
            
            VStack(alignment: .leading, spacing: 16) {
                
                CommonButton(
                    title: "quick_action_button_sign_in".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    icon: Image("icon-sign-in"),
                    iconSize: 24,
                    backgroundColor: Color.Primary800,
                ) {
                    onSignIn()
                }
                
                CommonButton(
                    title: "quick_action_button_sign_out".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    icon: Image("icon-sign-out"),
                    iconSize: 24,
                    backgroundColor: Color.red,
                ) {
                    onSignOut()
                }
            }
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(24)
    }
}

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
                SignInOutBottomSheetView(isPresented: $showBottomSheet) {
                    
                } onSignOut: {
                    
                }
            }
        }
    }

    return PreviewWrapper()
    

}
#endif
