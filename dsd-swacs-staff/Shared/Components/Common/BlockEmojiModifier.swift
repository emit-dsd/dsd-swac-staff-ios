//
//  BlockEmojiModifier.swift
//  dsd-swacs-staff
//
//  Created by Andy on 26/2/2026.
//

import SwiftUI
// MARK: - ViewModifier
struct BlockEmojiModifier: ViewModifier {
    @Binding var text: String

    func body(content: Content) -> some View {
        content
            .onChange(of: text, initial: false) { _, newValue in
                let filtered = newValue.removingEmojis()
                if filtered != newValue {
                    text = filtered
                }
            }
    }
}

// MARK: - View Extension
extension View {
    func blockEmoji(_ text: Binding<String>) -> some View {
        self.modifier(BlockEmojiModifier(text: text))
    }
}
