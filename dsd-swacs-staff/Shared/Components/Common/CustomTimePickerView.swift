//
//  CustomTimePickerView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/11/2025.
//

import SwiftUI

struct CustomTimePickerView: View {
    let title: String
    @Binding var time: Date
    let placeholder: String
    var isMandatory: Bool = false
    var minuteInterval: Int = 1
    var timeFormat: TimeFormat = .system
    
    @State private var showTimePicker = false
    
    @EnvironmentObject var languageManager: AppLanguageManager
    
    // MARK: - Time Format Enum
    
    enum TimeFormat {
        case system         // Follow system settings
        case twelveHour     // 12-hour format (1:30 PM)
        case twentyFourHour // 24-hour format (13:30)
        case custom(String) // Custom format (HH:mm)
        
        func formatter(locale: Locale) -> DateFormatter {
            let formatter = DateFormatter()
            formatter.locale = locale
            
            switch self {
            case .system:
                formatter.timeStyle = .short
            case .twelveHour:
                formatter.dateFormat = "h:mm a"
            case .twentyFourHour:
                formatter.dateFormat = "HH:mm"
            case .custom(let format):
                formatter.dateFormat = format
            }
            
            return formatter
        }
    }
    
    // MARK: - Convenience Initializer with String Format
    
    init(
        title: String,
        time: Binding<Date>,
        placeholder: String,
        isMandatory: Bool = false,
        minuteInterval: Int = 1,
        format: String
    ) {
        self.title = title
        self._time = time
        self.placeholder = placeholder
        self.isMandatory = isMandatory
        self.minuteInterval = minuteInterval
        self.timeFormat = .custom(format)
    }
    
    // MARK: - Standard Initializer
    
    init(
        title: String,
        time: Binding<Date>,
        placeholder: String,
        isMandatory: Bool = false,
        minuteInterval: Int = 1,
        timeFormat: TimeFormat = .system
    ) {
        self.title = title
        self._time = time
        self.placeholder = placeholder
        self.isMandatory = isMandatory
        self.minuteInterval = minuteInterval
        self.timeFormat = timeFormat
    }
    
    // MARK: - Computed Properties
    
    private var currentLocale: Locale {
        return Locale(identifier: languageManager.currentLanguage.rawValue)
    }
    
    private var timeFormatter: DateFormatter {
        return timeFormat.formatter(locale: currentLocale)
    }
    
    private var formattedTime: String {
        timeFormatter.string(from: time)
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

            Button(action: {
                showTimePicker = true
            }) {
                HStack(alignment: .center, spacing: 10) {
                    Text(formattedTime)
                        .appFont(.robotoRegular, size: 16)
                        .foregroundColor(Color.Neutral800)
                      
                    Spacer()
                    
                    Image(systemName: "clock")
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
        .commonBottomSheet(isPresented: $showTimePicker, detents: [.height(360)]) {
            VStack(spacing: 16) {
                DatePicker(
                    "",
                    selection: $time,
                    displayedComponents: .hourAndMinute
                )
                .datePickerStyle(.wheel)
                .labelsHidden()
                .environment(\.locale, pickerLocale)
                .padding(.horizontal)
                .onAppear {
                    UIDatePicker.appearance().minuteInterval = minuteInterval
                }
                .onDisappear {
                    UIDatePicker.appearance().minuteInterval = 1
                }
                
                CommonButton(
                    title: "general_done".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    showTimePicker = false
                }
                .padding()
            }
        }
    }
    
    // MARK: - Helper
    
    /// Locale for the picker (forces 12/24 hour format)
    private var pickerLocale: Locale {
        switch timeFormat {
        case .twelveHour:
            return Locale(identifier: "en_US")  // Force 12-hour
        case .twentyFourHour:
            return Locale(identifier: "en_GB")  // Force 24-hour
        default:
            return currentLocale
        }
    }
}

// MARK: - Preview

struct CustomTimePickerView_Previews: PreviewProvider {
    @State static var previewTime = Date()
    
    static var previews: some View {
        ScrollView {
            VStack(spacing: 24) {
                // System default
                CustomTimePickerView(
                    title: "System Format",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    timeFormat: .system
                )
                
                // 12-hour format
                CustomTimePickerView(
                    title: "12-Hour Format",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    timeFormat: .twelveHour
                )
                
                // 24-hour format
                CustomTimePickerView(
                    title: "24-Hour Format",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    timeFormat: .twentyFourHour
                )
                
                // Custom format: HH:mm:ss
                CustomTimePickerView(
                    title: "Custom: HH:mm:ss",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    timeFormat: .custom("HH:mm:ss")
                )
                
                // Using string initializer
                CustomTimePickerView(
                    title: "String Format: HH:mm",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    format: "HH:mm"
                )
                
                // With minute interval
                CustomTimePickerView(
                    title: "15-min Interval",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    minuteInterval: 15,
                    timeFormat: .twentyFourHour
                )
                
                // Mandatory field
                CustomTimePickerView(
                    title: "Mandatory Time",
                    time: $previewTime,
                    placeholder: "Pick a time",
                    isMandatory: true,
                    timeFormat: .twelveHour
                )
            }
            .padding()
        }
        .environmentObject(AppLanguageManager.shared)
    }
}
