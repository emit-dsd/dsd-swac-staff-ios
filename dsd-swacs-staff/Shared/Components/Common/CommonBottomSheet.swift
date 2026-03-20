//
//  CommonBottomSheet.swift
//  DSD_SWACS
//
//  Created by Andy on 29/7/2025.
//

import SwiftUI

struct CommonBottomSheetModifier<SheetContent: View>: ViewModifier {
    @Binding var isPresented: Bool
    let detents: Set<PresentationDetent>
    let content: () -> SheetContent

    func body(content base: Content) -> some View {
        base
            .sheet(isPresented: $isPresented) {
                self.content()
                    .presentationDetents(detents)
                    .presentationBackground(.white)
                    .presentationCornerRadius(24)
                    .presentationDragIndicator(.hidden)
            }
    }
}

extension View {
    func commonBottomSheet<Content: View>(
        isPresented: Binding<Bool>,
        detents: Set<PresentationDetent> = [.medium, .large],
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        self.modifier(CommonBottomSheetModifier(isPresented: isPresented, detents: detents, content: content))
    }
}
