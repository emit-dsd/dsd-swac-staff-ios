//
//  CustomTwoButtonRowView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 16/3/2026.
//

import SwiftUI

// MARK: - Button Row View
struct CustomTwoButtonRowView: View {
    let title: String
    @Binding var isSelected: Bool      // true = Yes, false = No
    var onToggle: ((Bool) -> Void)? = nil

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {

            Text(title)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(Color.Primary800)

            HStack(alignment: .center, spacing: 16) {

                // YES button
                Button {
                    guard !isSelected else { return }
                    isSelected = true
                    onToggle?(true)
                } label: {
                    Text("general_yes".localized())
                        .appFont(.robotoRegular, size: 14)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.Primary800 : Color.Neutral200)
                        .foregroundColor(isSelected ? Color.Primary100 : Color.Neutral500)
                        .cornerRadius(100)
                }
                .background(Color.clear)

                // NO button
                Button {
                    guard isSelected else { return }
                    isSelected = false
                    onToggle?(false)
                } label: {
                    Text("general_no".localized())
                        .appFont(.robotoRegular, size: 14)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 8)
                        .background(isSelected ? Color.Neutral200 : Color.Primary800)
                        .foregroundColor(isSelected ? Color.Neutral500 : Color.Primary100)
                        .cornerRadius(100)
                }
                .background(Color.clear)
            }
            .padding(.horizontal, 8)
        }
    }
}


// MARK: - Preview
#if DEBUG
#Preview {
    VStack(spacing: 24) {
        CustomTwoButtonRowView(
            title: "Any casualties",
            isSelected: .constant(false)
        )
        
        CustomTwoButtonRowView(
            title: "Any medias",
            isSelected: .constant(true)
        )
        
        CustomTwoButtonRowView(
            title: "Any paramedics",
            isSelected: .constant(true)
        )
        
        CustomTwoButtonRowView(
            title: "Any fire force",
            isSelected: .constant(false)
        )
        
        CustomTwoButtonRowView(
            title: "Any polices",
            isSelected: .constant(false)
        )
    }
    .background(Color.white)
    .padding()
}
#endif
