//
//  CustomToggleRowView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/11/2025.
//

import SwiftUI

// MARK: - Toggle Row View
struct ToggleRowView: View {
    // MARK: - Properties
    let title: String
    @Binding var isOn: Bool
    var onToggle: ((Bool) -> Void)? = nil
    
    // Customization options
    var titleColor: Color = Color.Primary800
    var tintColor: Color = Color.Primary800
    var backgroundColor: Color = Color.clear
    var padding: EdgeInsets = EdgeInsets(top: 0, leading: 0, bottom: 0, trailing: 0)
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: 16) {
            // Title
            Text(title)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(titleColor)
            
            Spacer()
            
            Text(isOn ? "general_yes".localized() : "general_no".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(isOn ? Color.Primary800 : Color.Neutral500)
            // Toggle Switch
            Toggle("", isOn: $isOn)
                .labelsHidden()
                .tint(tintColor)
                .onChange(of: isOn) { oldValue, newValue in
                    onToggle?(newValue)
                }
        }
        .padding(padding)
        .background(backgroundColor)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    VStack(spacing: 24) {
        ToggleRowView(
            title: "Any casualties",
            isOn: .constant(false)
        )
        

        
        ToggleRowView(
            title: "Any medias",
            isOn: .constant(true)
        )
        

        
        ToggleRowView(
            title: "Any paramedics",
            isOn: .constant(true)
        )
        
   
        
        ToggleRowView(
            title: "Any fire force",
            isOn: .constant(false)
        )
        

        
        ToggleRowView(
            title: "Any polices",
            isOn: .constant(false)
        )
    }
    .background(Color.white)
}
#endif
