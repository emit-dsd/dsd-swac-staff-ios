//
//  CustomPlaceholderTextEditor.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//
import SwiftUI

struct CustomPlaceholderTextEditor: View {
    @Binding var text: String
    let placeholder: String
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            if text.isEmpty {
                Text(placeholder)
                    .appFont(.robotoRegular, size: 16)
                    .foregroundColor(Color.Neutral500)
                    .padding(12)
            }
            
            TextEditor(text: $text)
                .blockEmoji($text)
                .padding(5)
                .appFont(.robotoRegular, size: 16)
                .foregroundColor(Color.Neutral800)
                .accentColor(Color.Primary800)
                .scrollContentBackground(.hidden)
        }
        .background(Color.Neutral100)
        .cornerRadius(4)
    }
}
