//
//  HomeSelectSWACBottomSheetView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 8/8/2025.
//

import SwiftUI

enum HomeSelectSWACUsageType {
    case siteDiary
    case safetyInspection
}

// MARK: - SWAC Row Component
struct SWACRow: View {
    let swac: SWACListItem
    let isSelected: Bool
    let usageType: HomeSelectSWACUsageType

    var canSelect: Bool {
        switch usageType {
        case .siteDiary:
            return true
        case .safetyInspection:
            return swac.canSubmitSafetyInspectionReport
        }
    }

    var body: some View {
        HStack(alignment: .center, spacing: 2) {
            VStack(alignment: .leading, spacing: 8) {
                Text(swac.number)
                    .appFont(.robotoBold, size: 16)
                    .foregroundColor(.Primary500)

                Text(swac.contractor)
                    .appFont(.robotoRegular, size: 16)
                    .foregroundColor(.Neutral800)

                if usageType == .safetyInspection && !swac.canSubmitSafetyInspectionReport {
                    Text("quick_action_label_no_right_of_submission".localized())
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                }
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            Spacer()
            
            if canSelect {
                Image(isSelected ? "radio-button-selected" : "radio-button")
                    .resizable()
                    .frame(width: 20, height: 20)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .contentShape(Rectangle())
    }
}

// MARK: - Home Select SWAC Bottom Sheet View
struct HomeSelectSWACBottomSheetView: View {
    @StateObject private var viewModel = HomeSelectSWACViewModel()
    @Binding var selectedID: String?
    let usageType: HomeSelectSWACUsageType
    var onContinue: (SWACListItem?) -> Void
    
    @State private var isKeyboardVisible = false
    @State private var calculatedHeight: CGFloat?
    
    let minHeight: CGFloat = 450
    private let screenHeight = UIScreen.main.bounds.height
    
    var scrollViewHeight: CGFloat {
        if isKeyboardVisible {
            return screenHeight * 0.3
        } else {
            let maxHeight = screenHeight * 0.5
            if let height = calculatedHeight {
                return min(max(height, minHeight), maxHeight)
            }
            return maxHeight
        }
    }
    
    // MARK: - Computed Properties
    /// Selected SWAC item
    var selectedSWAC: SWACListItem? {
        viewModel.swacList.first(where: { $0.number == selectedID })
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 24) {
            // Header with Search Bar
            VStack(alignment: .leading, spacing: 8) {
                Text("quick_action_label_select_swac".localized())
                    .appFont(.robotoBold, size: 18)
                    .foregroundColor(Color.Neutral800)
                
                
                SearchBarView(
                    searchText: $viewModel.searchText,
                    placeholder: "swac_main_placeholder_swac".localized()
                )
            }
            .padding(.horizontal, 24)
            .animation(.easeInOut(duration: 0.3), value: viewModel.isSearchActive)
            
            // SWAC List
            ScrollView {
                LazyVStack(spacing: 12) {
                    if viewModel.isLoading && viewModel.swacList.isEmpty {
                        // Initial loading
                        ProgressView()
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 40)
                    } else if viewModel.swacList.isEmpty {
                        // Empty state
                        VStack(spacing: 12) {
                            Text("general_no_results".localized())
                                .appFont(.robotoMedium, size: 16)
                                .foregroundColor(Color.Neutral500)
                            
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 40)
                        .transition(.opacity.combined(with: .scale(scale: 0.95)))
                    } else {
                        // SWAC list
                        ForEach(viewModel.swacList, id: \.uniqueID) { swac in
                            SWACRow(
                                swac: swac,
                                isSelected: swac.number == selectedID,
                                usageType:usageType
                            )
                            .onTapGesture {
                                if usageType == .safetyInspection && !swac.canSubmitSafetyInspectionReport {
                                    return
                                }
                                selectedID = swac.number
                            }
                            .onAppear {
                                if viewModel.hasReachedEnd(of: swac) {
                                    Task {
                                        await viewModel.loadMoreItems()
                                    }
                                }
                            }
                            .transition(.opacity.combined(with: .move(edge: .bottom)))
                        }
                        
                        // Load more indicator
                        if viewModel.isLoadingMore {
                            ProgressView()
                                .frame(maxWidth: .infinity)
                                .padding()
                                .transition(.opacity)
                        }
                        
                        // End of list indicator
                        if !viewModel.hasMorePages && !viewModel.swacList.isEmpty && !viewModel.isLoadingMore {
                            Text("general_no_more_data".localized())
                                .appFont(.robotoRegular, size: 14)
                                .foregroundColor(.Neutral500)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .transition(.opacity)
                        }
                    }
                }
                .background(
                    GeometryReader { geo in
                        Color.clear.preference(key: HeightPreferenceKey.self, value: geo.size.height)
                    }
                )
                .padding(.vertical, 8)
            }
            .contentMargins(.horizontal, 24, for: .scrollContent)
            .frame(height: scrollViewHeight)
            .animation(.easeInOut(duration: 0.3), value: scrollViewHeight)
            .animation(.easeInOut(duration: 0.2), value: viewModel.swacList.count)
            .onPreferenceChange(HeightPreferenceKey.self) { newHeight in
                if !isKeyboardVisible && calculatedHeight == nil {
                    calculatedHeight = newHeight + 30
                }
            }
            .refreshable {
                await viewModel.refreshList()
            }
            
            // Continue Button
            CommonButton(
                title: "general_continue".localized(),
                style: .contained,
                enabled: selectedID != nil,
                maxWidth: .infinity
            ) {
                onContinue(selectedSWAC)
            }
            .padding(.horizontal, 24)
        }
        .padding(.top, 24)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.white)
        .cornerRadius(24)
        .onAppear {
            observeKeyboard()
            // Fetch SWAC list when sheet appears
            Task {
                await viewModel.fetchSWACList(reset: true)
            }
        }
        .onDisappear {
            // Reset state when sheet is dismissed
            viewModel.reset()
        }
        .onChange(of: isKeyboardVisible) { _, newValue in
            if !newValue {
                calculatedHeight = nil
            }
        }
    }
    
    // MARK: - Keyboard Observer
    private func observeKeyboard() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = true
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation(.easeInOut(duration: 0.3)) {
                isKeyboardVisible = false
            }
        }
    }
}

// MARK: - Height Preference Key
struct HeightPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = max(value, nextValue())
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    HomeSelectSWACBottomSheetView(
        selectedID: .constant(""),
        usageType: .siteDiary
    ) { _ in
        
    }
}
#endif
