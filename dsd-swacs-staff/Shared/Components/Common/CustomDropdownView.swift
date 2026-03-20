//
//  CustomDropdownView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 9/12/2025.
//

import SwiftUI

// MARK: - Dropdown Item Protocol
protocol DropdownItemProtocol: Identifiable, Hashable {
    var displayText: String { get }
}

// MARK: - Dropdown Item Model
struct DropdownItem: DropdownItemProtocol {
    let id: String
    let displayText: String
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: DropdownItem, rhs: DropdownItem) -> Bool {
        lhs.id == rhs.id
    }
}

// MARK: - Custom Dropdown View
struct CustomDropdownView<Item: DropdownItemProtocol>: View {
    // MARK: - Properties
    let titleType: TitleType
    @Binding var selectedItem: Item?
    let items: [Item]
    let placeholder: String
    let mode: InputMode
    let isMandatory: Bool
    
    @State private var isShowingSheet = false
    
    private var titleColor: Color {
        mode == .disabled ? Color.Neutral300 : Color.Primary800
    }
    
    private var textColor: Color {
        mode == .disabled ? Color.Neutral300 : Color.Neutral800
    }
    
    private var displayText: String {
        selectedItem?.displayText ?? placeholder
    }
    
    private var isPlaceholder: Bool {
        selectedItem == nil
    }
    
    // MARK: - Initializers
    
    /// Initializer for plain String
    init(
        title: String,
        selectedItem: Binding<Item?>,
        items: [Item],
        placeholder: String,
        mode: InputMode = .default,
        isMandatory: Bool = false
    ) {
        self.titleType = .plain(title)
        self._selectedItem = selectedItem
        self.items = items
        self.placeholder = placeholder
        self.mode = mode
        self.isMandatory = isMandatory
    }
    
    /// Initializer for AttributedString
    init(
        attributedTitle: AttributedString,
        selectedItem: Binding<Item?>,
        items: [Item],
        placeholder: String,
        mode: InputMode = .default,
        isMandatory: Bool = false
    ) {
        self.titleType = .attributed(attributedTitle)
        self._selectedItem = selectedItem
        self.items = items
        self.placeholder = placeholder
        self.mode = mode
        self.isMandatory = isMandatory
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            titleView
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            dropdownButton
        }
        .sheet(isPresented: $isShowingSheet) {
            bottomSheet
                .presentationDetents([.medium])
        }
    }
    
    // MARK: - Title View
    @ViewBuilder
    private var titleView: some View {
        HStack(spacing: 4) {
            switch titleType {
            case .plain(let string):
                Text(string)
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(titleColor)
                
            case .attributed(let attributedString):
                Text(attributedString)
            }
            
            if isMandatory {
                Text("*")
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(.red)
            }
        }
    }
    
    @ViewBuilder
    private var bottomSheetTitleView: some View {
        switch titleType {
        case .plain(let string):
            Text(string)
                .appFont(.robotoBold, size: 18)
                .foregroundColor(Color.Neutral800)
            
        case .attributed(let attributedString):
            Text(attributedString)
        }
    }
    
    // MARK: - Dropdown Button
    private var dropdownButton: some View {
        Button {
            if mode == .default {
                isShowingSheet = true
            }
        } label: {
            dropdownButtonContent
        }
        .disabled(mode != .default)
    }
    
    private var dropdownButtonContent: some View {
        HStack {
            Text(displayText)
                .font(.custom("Roboto", size: 16))
                .foregroundColor(isPlaceholder ? Color.Neutral300 : textColor)
            
            Spacer()
            
            chevronIcon
        }
        .padding(12)
        .background(Color.Neutral100)
        .cornerRadius(4)
    }
    
    private var chevronIcon: some View {
        Image(systemName: "chevron.down")
            .font(.system(size: 12))
            .foregroundColor(mode == .disabled ? Color.Neutral300 : Color.Primary800)
    }
    
    // MARK: - Bottom Sheet
    private var bottomSheet: some View {
        VStack(alignment: .leading, spacing: 24) {
            HStack(alignment: .center) {
                bottomSheetTitleView
                
                Spacer()
                
                Button(action: {
                    withAnimation {
                        isShowingSheet = false
                    }
                }) {
                    Image("close-button")
                        .resizable()
                        .frame(width: 22, height: 22)
                }
            }
            .padding(.horizontal, 24)
            .frame(maxWidth: .infinity, alignment: .center)
            
            // List
            ScrollView {
                VStack(spacing: 0) {
                    ForEach(items) { item in
                        dropdownItemRow(item)
                        if item.id != items.last?.id {
                            Divider()
                                .background(Color.Neutral200)
                        }
                    }
                }
            }
            .contentMargins(.bottom, 12, for: .scrollContent)
            
        }
        .padding(.top, 24)
        .background(Color.white)
    }
    
    private var sheetTitle: String {
        switch titleType {
        case .plain(let string):
            return string
        case .attributed(let attributedString):
            return String(attributedString.characters)
        }
    }
    
    // MARK: - Dropdown Item Row
    private func dropdownItemRow(_ item: Item) -> some View {
        Button {
            selectedItem = item
            isShowingSheet = false
        } label: {
            dropdownItemContent(item)
        }
    }
    
    private func dropdownItemContent(_ item: Item) -> some View {
        HStack {
            Text(item.displayText)
                .font(.custom("Roboto", size: 16))
                .foregroundColor(Color.Neutral800)
            
            Spacer()
            
            Image(selectedItem?.id == item.id  ? "radio-button-selected" : "radio-button")
                .resizable()
                .frame(width: 20, height: 20)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 16)
        .background(Color.white)
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScrollView {
        VStack(spacing: 24) {
            // Mandatory Field
            CustomDropdownView(
                title: "Select Country (Mandatory)",
                selectedItem: .constant(nil),
                items: [
                    DropdownItem(id: "hk", displayText: "Hong Kong"),
                    DropdownItem(id: "cn", displayText: "China")
                ],
                placeholder: "Please select a country",
                isMandatory: true
            )
            
            // Plain String
            CustomDropdownView(
                title: "Select Country",
                selectedItem: .constant(nil),
                items: [
                    DropdownItem(id: "hk", displayText: "Hong Kong"),
                    DropdownItem(id: "cn", displayText: "China")
                ],
                placeholder: "Please select a country"
            )
            
            // Pre-selected item
            CustomDropdownView(
                title: "Pre-selected",
                selectedItem: .constant(DropdownItem(id: "hk", displayText: "Hong Kong")),
                items: [
                    DropdownItem(id: "hk", displayText: "Hong Kong"),
                    DropdownItem(id: "cn", displayText: "China")
                ],
                placeholder: "Select..."
            )
            
            // Disabled mode
            CustomDropdownView(
                title: "Disabled Dropdown",
                selectedItem: .constant(DropdownItem(id: "disabled", displayText: "Cannot change")),
                items: [
                    DropdownItem(id: "disabled", displayText: "Cannot change"),
                    DropdownItem(id: "other", displayText: "Other option")
                ],
                placeholder: "Disabled",
                mode: .disabled
            )
        }
        .padding()
    }
}
#endif
