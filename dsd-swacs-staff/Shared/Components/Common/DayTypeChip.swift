//
//  DayTypeChip.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI
enum DayType {
    case weekday
    case weekend
}


struct DayTypeChip: View {
    let dayType: DayType
    
    init(date: Date = Date()) {
         let weekday = Calendar.current.component(.weekday, from: date)
         if weekday == 1 || weekday == 7 {
             self.dayType = .weekend
         } else {
             self.dayType = .weekday
         }
     }

    
    private var chipColor: Color {
        switch dayType {
        case .weekday:
            return Color.green
        case .weekend:
            return Color.red
        }
    }
    
    private var backgroundColor: Color {
        switch dayType {
        case .weekday:
            return Color.successBackground
        case .weekend:
            return Color(hex: "FFEAEF")
        }
    }
    
    private var label: String {
        switch dayType {
        case .weekday:
            return "day_type_chip_label_weekday".localized()
        case .weekend:
            return "day_type_chip_label_weekend".localized()
        }
    }
    
    
    var body: some View {
        HStack(spacing: 2) {
            Image("date-chip")
                .resizable()
                .renderingMode(.template)
                .foregroundColor(chipColor)
                .frame(width: 12, height: 12)
            Text(label)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(chipColor)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(backgroundColor)
        .cornerRadius(4)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .inset(by: 0.5)
                .stroke(chipColor, lineWidth: 1)
        )
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 20 ){
        DayTypeChip()
        DayTypeChip()
    }
}
#endif
