//
//  CustomDateFilterBottomSheetView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

struct DateFilterResult {
    let mode: DateFilterMode
    let singleDate: Date?
    let startDate: Date?
    let endDate: Date?
}

enum DateFilterMode: String, CaseIterable, Identifiable {
    case singleDate = "singleDate"
    case dateRange = "dateRange"
    
    var id: String { self.rawValue }
    
    var bottomSheetHeight: CGFloat {
        switch self {
        case .singleDate:
            return 306
        case .dateRange:
            return 380
        }
    }
}

struct CustomDateFilterBottomSheetView: View {
    @Binding var isPresented: Bool
    let initialMode: DateFilterMode
    let initialSingleDate: Date?
    let initialStartDate: Date?
    let initialEndDate: Date?
    
    var onApply: (DateFilterResult) -> Void
    
    // 內部狀態
    @State private var mode: DateFilterMode
    @State private var singleDate: Date
    @State private var startDate: Date
    @State private var endDate: Date
    
    init(
        isPresented: Binding<Bool>,
        mode: DateFilterMode = .singleDate,
        singleDate: Date? = nil,
        startDate: Date? = nil,
        endDate: Date? = nil,
        onApply: @escaping (DateFilterResult) -> Void
    ) {
        self._isPresented = isPresented
        self.initialMode = mode
        self.initialSingleDate = singleDate
        self.initialStartDate = startDate
        self.initialEndDate = endDate
        self.onApply = onApply
        
        // 初始化內部狀態
        _mode = State(initialValue: mode)
        _singleDate = State(initialValue: singleDate ?? Date())
        _startDate = State(initialValue: startDate ?? Date())
        _endDate = State(initialValue: endDate ?? Date())
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // MARK: - Header
            HStack(alignment: .center) {
                Text(mode == .singleDate ? "date_filter_label_title_select_date".localized() : "date_filter_label_title".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(Color.Neutral800)
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isPresented = false
                    }
                }) {
                    Image("close-button")
                        .resizable()
                        .frame(width: 22, height: 22)
                }
            }
            .frame(maxWidth: .infinity, alignment: .center)
            
            VStack(alignment: .leading, spacing: 10) {
                if mode == .singleDate {
                    CustomDatePickerView(
                        title: "date_filter_label_date".localized(),
                        date: $singleDate,
                        placeholder: "date_filter_label_pick_date".localized(),
                        isMandatory: true,
                        range: Date.distantPast...Date(),
                        displayFormat: .custom("yyyy-MM-dd")
                    )
                } else {
                    CustomDatePickerView(
                        title: "date_filter_label_receive_time_from".localized(),
                        date: $startDate,
                        placeholder: "date_filter_label_pick_date".localized(),
                        range: Date.distantPast...endDate,
                        displayFormat: .custom("yyyy-MM-dd")
                    )
                    CustomDatePickerView(
                        title: "date_filter_label_to".localized(),
                        date: $endDate,
                        placeholder: "date_filter_label_pick_date".localized(),
                        range: startDate...Date(),
                        displayFormat: .custom("yyyy-MM-dd")
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .animation(.easeInOut(duration: 0.3), value: mode)
            
            Spacer()
            
            VStack(alignment: .leading, spacing: 8) {
                CommonButton(
                    title: "date_filter_button_show_result".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    applyFilter()
                }
                
                CommonButton(
                    title: "general_reset".localized(),
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity
                ) {
                    resetFilter()
                }
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
        }
        .padding(.horizontal, 24)
        .padding(.top, 24)
        .padding(.bottom, 48)
        .frame(maxWidth: .infinity, minHeight: mode.bottomSheetHeight, maxHeight: mode.bottomSheetHeight, alignment: .topLeading)
        .background(Color.white)
    }
    
    private func applyFilter() {
        let result: DateFilterResult
        
        if mode == .singleDate {
            result = DateFilterResult(
                mode: .singleDate,
                singleDate: singleDate,
                startDate: nil,
                endDate: nil
            )
        } else {
            result = DateFilterResult(
                mode: .dateRange,
                singleDate: nil,
                startDate: startDate,
                endDate: endDate
            )
        }
        
        withAnimation {
            isPresented = false
        }
        onApply(result)
    }
    
    private func resetFilter() {
        // Reset to initial values or current date
        singleDate = initialSingleDate ?? Date()
        startDate = initialStartDate ?? Date()
        endDate = initialEndDate ?? Date()
        
        let result = DateFilterResult(
            mode: mode,
            singleDate: nil,
            startDate: nil,
            endDate: nil
        )
        
        withAnimation {
            isPresented = false
        }
        onApply(result)
    }
}

// MARK: - Preview
#if DEBUG
#Preview("單日模式") {
    struct PreviewWrapper: View {
        @State private var showBottomSheet = true
        
        var body: some View {
            VStack {
                Button("Show Filter") {
                    showBottomSheet = true
                }
            }
            .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(380)]) {
                CustomDateFilterBottomSheetView(
                    isPresented: $showBottomSheet,
                    mode: .singleDate,
                    onApply: { result in
                        print("模式: \(result.mode)")
                        if let date = result.singleDate {
                            print("單日: \(date)")
                        } else {
                            print("清除 filter")
                        }
                    }
                )
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("日期範圍模式") {
    struct PreviewWrapper: View {
        @State private var showBottomSheet = true
        
        var body: some View {
            VStack {
                Button("Show Filter") {
                    showBottomSheet = true
                }
            }
            .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(380)]) {
                CustomDateFilterBottomSheetView(
                    isPresented: $showBottomSheet,
                    mode: .dateRange,
                    startDate: Date(),
                    endDate: Date(),
                    onApply: { result in
                        print("模式: \(result.mode)")
                        if let start = result.startDate, let end = result.endDate {
                            print("範圍: \(start) 至 \(end)")
                        } else {
                            print("清除 filter")
                        }
                    }
                )
            }
        }
    }
    
    return PreviewWrapper()
}

#Preview("帶初始值") {
    struct PreviewWrapper: View {
        @State private var showBottomSheet = true
        
        var body: some View {
            VStack {
                Button("Show Filter") {
                    showBottomSheet = true
                }
            }
            .commonBottomSheet(isPresented: $showBottomSheet, detents: [.height(380)]) {
                CustomDateFilterBottomSheetView(
                    isPresented: $showBottomSheet,
                    mode: .dateRange,
                    startDate: Calendar.current.date(byAdding: .day, value: -7, to: Date()),
                    endDate: Date(),
                    onApply: { result in
                        print("模式: \(result.mode)")
                        if let start = result.startDate, let end = result.endDate {
                            print("範圍: \(start) 至 \(end)")
                        } else {
                            print("清除 filter")
                        }
                    }
                )
            }
        }
    }
    
    return PreviewWrapper()
}
#endif
