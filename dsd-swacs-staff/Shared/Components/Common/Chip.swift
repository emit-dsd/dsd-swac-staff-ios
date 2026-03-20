//
//  Chip.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/8/2025.
//

import SwiftUI

struct Chip: View {
    let label: String
    let isSelected: Bool
    let showIcon: Bool
    let onTap: () -> Void   // callback when tapped

    private var iconColor: Color {
        isSelected ? Color.Primary500 : Color.clear
    }

    private var textColor: Color {
        isSelected ? Color.Primary100 : Color.Neutral500
    }

    private var backgroundColor: Color {
        isSelected ? Color.Primary500 : Color.Neutral200
    }

    var body: some View {
        HStack(alignment: .center, spacing: 8) {
            if isSelected && showIcon{
                Image("chip-tick-icon")
                    .resizable()
                    .renderingMode(.template)
                    .foregroundColor(iconColor)
                    .frame(width: 14, height: 14)
            }
            Text(label)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(textColor)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(backgroundColor)
        .cornerRadius(100)
        .onTapGesture {
            onTap()
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 12){
        Chip(label: "Confined Space", isSelected: true, showIcon: true) {
                 
                
              }
        Chip(label: "Confined Space", isSelected: true, showIcon: false) {
                 
                
              }
        Chip(label: "Confined Space", isSelected: false, showIcon: true) {
                 
                
              }
    }

}
#endif
