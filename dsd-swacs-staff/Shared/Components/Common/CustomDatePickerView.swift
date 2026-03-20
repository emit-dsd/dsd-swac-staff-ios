//
//  CustomDatePickerView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/10/2025.
//

import SwiftUI

struct CustomDatePickerView: View {
    let title: String
    @Binding var date: Date
    let placeholder: String
    var isMandatory: Bool = false
    var range: ClosedRange<Date>? = nil
    var displayFormat: DateDisplayFormat = .medium
    
    @State private var showDatePicker = false
    
    @EnvironmentObject var languageManager: AppLanguageManager

    // MARK: - Date Display Format Enum
    enum DateDisplayFormat {
        case short           // 21/11/2025
        case medium          // Nov 21, 2025
        case long            // November 21, 2025
        case full            // Friday, November 21, 2025
        case custom(String)  // Custom format like "yyyy-MM-dd"
        
        func formatter(locale: Locale) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = locale
            
            switch self {
            case .short:
                formatter.dateStyle = .short
            case .medium:
                formatter.dateStyle = .medium
            case .long:
                formatter.dateStyle = .long
            case .full:
                formatter.dateStyle = .full
            case .custom(let format):
                formatter.dateFormat = format
            }
            
            return formatter
        }
    }
    
    // MARK: - Computed Properties
    
    private var currentLocale: Locale {
        return Locale(identifier: languageManager.currentLanguage.rawValue)
    }
    
    private var dateFormatter: DateFormatter {
        return displayFormat.formatter(locale: currentLocale)
    }
    
    private var formattedDate: String {
        dateFormatter.string(from: date)
    }
    
    // MARK: - Body
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 4) {
                Text(title)
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(Color.Primary800)
                
                if isMandatory {
                    Text("*")
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.red)
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)

            // Date picker button
            Button(action: {
                showDatePicker = true
            }) {
                HStack(alignment: .center, spacing: 10) {
                    Text(formattedDate)
                        .appFont(.robotoRegular, size: 16)
                        .foregroundColor(Color.Neutral800)
                      
                    Spacer()
                    
                    Image("date-chip")
                        .resizable()
                        .renderingMode(.template)
                        .frame(width: 16, height: 16)
                        .foregroundColor(Color.Primary800)
                }
                .padding(12)
                .frame(height: 44)
                .background(Color.Neutral100)
                .cornerRadius(4)
            }
        }
        .commonBottomSheet(isPresented: $showDatePicker, detents: [.height(500)]) {
            VStack {
                DatePicker(
                    "",
                    selection: $date,
                    in: range ?? Date.distantPast...Date.distantFuture,
                    displayedComponents: [.date]
                )
                .datePickerStyle(.graphical)
                .tint(Color.Primary600)
                .environment(\.locale, currentLocale)
                .padding()
                
                CommonButton(
                    title: "general_done".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    showDatePicker = false
                }
                .padding()
            }
        }
    }
}

// MARK: - Preview

struct CustomDatePickerView_Previews: PreviewProvider {
    @State static var previewDate = Date()
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // Short format
                CustomDatePickerView(
                    title: "Short Format",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .short
                )
                
                // Medium format (default)
                CustomDatePickerView(
                    title: "Medium Format",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .medium
                )
                
                // Long format
                CustomDatePickerView(
                    title: "Long Format",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .long
                )
                
                // Full format
                CustomDatePickerView(
                    title: "Full Format",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .full
                )
                
                // Custom format: yyyy-MM-dd
                CustomDatePickerView(
                    title: "Custom: yyyy-MM-dd",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .custom("yyyy-MM-dd")
                )
                
                // Custom format: dd/MM/yyyy
                CustomDatePickerView(
                    title: "Custom: dd/MM/yyyy",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .custom("dd/MM/yyyy")
                )
                
                // Custom format: EEE, dd MMM yyyy
                CustomDatePickerView(
                    title: "Custom: EEE, dd MMM yyyy",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    displayFormat: .custom("EEE, dd MMM yyyy")
                )
                
                // Mandatory with date range
                CustomDatePickerView(
                    title: "Mandatory with Range",
                    date: $previewDate,
                    placeholder: "Pick a date",
                    isMandatory: true,
                    range: Date()...Date().addingTimeInterval(30*24*60*60),
                    displayFormat: .custom("yyyy-MM-dd")
                )
            }
            .padding()
        }
        .environmentObject(AppLanguageManager.shared)
    }
}
