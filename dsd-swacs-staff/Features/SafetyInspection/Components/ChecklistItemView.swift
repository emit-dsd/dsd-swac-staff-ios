//
//  ChecklistItemView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//

import SwiftUI

struct ChecklistItemView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    @ObservedObject var item: ChecklistItem
    @Binding var selectedItemId: String?
    @FocusState.Binding var focusedField: String?

    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    let isReadOnly: Bool

    init(
        item: ChecklistItem,
        selectedItemId: Binding<String?>,
        focusedField: FocusState<String?>.Binding,
        isReadOnly: Bool = false
    ) {
        self.item = item
        self._selectedItemId = selectedItemId
        self._focusedField = focusedField
        self.isReadOnly = isReadOnly
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            switch item.itemType {
            case .section:
                sectionView
            case .singleChoice:
                singleChoiceView
            case .checkboxChoice:
                checkboxChoiceView
            case .text:
                textInputView
            case .time:
                timeInputView
            }
        }
    }
    
    // MARK: - Computed Properties
    private var backgroundColor: Color {
        if item.itemType == .section && item.level != 0 {
            return Color.red
        }
        return Color.white
    }
    
    private var canExpand: Bool {
        return item.level == 0 || item.level == 1
    }
    
    private var displayTitle: String {
        return item.getDisplayTitle(isEnglish: languageManager.currentLanguage == .en)
    }
    
    // MARK: - Section View
    
    @ViewBuilder
    private var sectionView: some View {
        VStack(alignment: .leading, spacing: 0) {
            Button(action: {
                withAnimation {
                    item.toggleExpand()
                }
            }) {
                HStack(spacing: 8) {
                    if item.level == 0 {
                        Text(getPrefix(for: item))
                            .appFont(.robotoBold, size: 18)
                            .foregroundColor(.white)
                    } else {
                        Text(getPrefix(for: item))
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                    }
                    
                    Text(displayTitle)
                        .appFont(.robotoBold, size: item.level == 0 ? 18 : 16)
                        .foregroundColor(item.level == 0 ? .white : .Neutral800)
                        .multilineTextAlignment(.leading)
                    
                    Spacer()
                    
                    Image(systemName: item.isExpanded ? "chevron.down" : "chevron.up")
                        .foregroundColor(item.level == 0 ? .white : .Primary800)
                }
                .contentShape(Rectangle())
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(item.level == 0 ? Color.Primary500 : Color.Neutral200)
            .buttonStyle(PlainButtonStyle())
            
            if item.isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(item.childs.enumerated()), id: \.element.id) { _, child in
                        ChecklistItemView(
                            item: child,
                            selectedItemId: $selectedItemId,
                            focusedField: $focusedField,
                            isReadOnly: isReadOnly
                        )
                    }
                }
            }
        }
        .overlay(
            Rectangle()
                .frame(height: item.level == 0 ? 1 : 0)
                .foregroundColor(Color.Neutral300),
            alignment: .bottom
        )
    }
    
    // MARK: - Single Choice View
    
    @ViewBuilder
    private var singleChoiceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if canExpand {
                // Can expand/collapse
                Button(action: {
                    withAnimation {
                        item.toggleExpand()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(getPrefix(for: item))
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                        
                        Text(displayTitle)
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: item.isExpanded ? "chevron.down" : "chevron.up")
                            .foregroundColor(Color.Primary800)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.Neutral200)
            } else {
                // No expand/collapse
                HStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 4, height: 18)
                        .background(Color.Primary500)
                        .cornerRadius(2)
                    
                    Text(getPrefix(for: item))
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                    
                    Text(displayTitle)
                        .appFont(.robotoRegular, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                    
//                    Spacer()
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.white)
            }
            
            if !canExpand || item.isExpanded {
                VStack(spacing: 16) {
                    // Choices
                    HStack(alignment: .center, spacing: 16) {
                        ForEach(item.choices) { choice in
                            ChoiceButton(
                                title:  choice.getDisplayValue(isEnglish: languageManager.currentLanguage == .en),
                                isSelected: choice.isChecked,
                                color: getColorForChoice(choice),
                                backgroundColor: canExpand ? .white : .Neutral200,
                                isEnabled: !isReadOnly,
                                action: {
                                    guard !isReadOnly else { return }
                                    item.selectSingleChoice(choice.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Remarks
                    RemarksInputView(
                        text: Binding(
                            get: { item.remark },
                            set: { item.remark = $0 }
                        ),
                        isReadOnly: isReadOnly
                    )
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .if(!isReadOnly) { view in
                        view.focused($focusedField, equals: item.id)
                    }
                }
                .padding(.bottom, 16)
                .background(canExpand ? Color.Neutral200 : Color.white)
            }
            Divider()
            
            if item.isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(item.childs.enumerated()), id: \.element.id) { _, child in
                        ChecklistItemView(
                            item: child,
                            selectedItemId: $selectedItemId,
                            focusedField: $focusedField,
                            isReadOnly: isReadOnly
                        )
                    }
                }
            }
        }
        .id(item.id)
    }
    
    // MARK: - Checkbox Choice View
    
    @ViewBuilder
    private var checkboxChoiceView: some View {
        VStack(alignment: .leading, spacing: 0) {
            
            if canExpand {
                // Can expand/collapse
                Button(action: {
                    withAnimation {
                        item.toggleExpand()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(getPrefix(for: item))
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                        
                        Text(displayTitle)
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: item.isExpanded ? "chevron.down" : "chevron.up")
                            .foregroundColor(Color.Primary800)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.Neutral200)
            } else {
                // No expand/collapse
                HStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 4, height: 18)
                        .background(Color.Primary500)
                        .cornerRadius(2)
                    
                    Text(getPrefix(for: item))
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                    
                    Text(displayTitle)
                        .appFont(.robotoRegular, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.white)
            }
            
            if !canExpand || item.isExpanded {
                VStack(spacing: 16) {
                    // Choices
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(item.choices) { choice in
                            CheckboxButton(
                                title: choice.getDisplayValue(isEnglish: languageManager.currentLanguage == .en),
                                isChecked: choice.isChecked,
                                isEnabled: !isReadOnly,
                                action: {
                                    guard !isReadOnly else { return }
//                                    item.toggleCheckboxChoice(choice.id)
                                    item.selectSingleChoice(choice.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    
                    // Remarks
                    RemarksInputView(
                        text: Binding(
                            get: { item.remark },
                            set: { item.remark = $0 }
                        ),
                        isReadOnly: isReadOnly
                    )
                    .padding(.horizontal, 16)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .if(!isReadOnly) { view in
                        view.focused($focusedField, equals: item.id)
                    }
                }
                .padding(.bottom, 16)
                .background(canExpand ? Color.Neutral200 : Color.white)
                
                Divider()
            }
            
            if item.isExpanded {
                VStack(spacing: 0) {
                    ForEach(Array(item.childs.enumerated()), id: \.element.id) { _, child in
                        ChecklistItemView(
                            item: child,
                            selectedItemId: $selectedItemId,
                            focusedField: $focusedField,
                            isReadOnly: isReadOnly
                        )
                    }
                }
            }
        }
        .id(item.id)
    }
    
    // MARK: - Text Input View
    
    @ViewBuilder
    private var textInputView: some View {
        VStack(alignment: .leading, spacing: 0) {
            if canExpand {
                // Can expand/collapse
                Button(action: {
                    withAnimation {
                        item.toggleExpand()
                    }
                }) {
                    HStack(spacing: 8) {
                        Text(getPrefix(for: item))
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                        
                        Text(displayTitle)
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                            .multilineTextAlignment(.leading)
                        
                        Spacer()
                        
                        Image(systemName: item.isExpanded ? "chevron.down" : "chevron.up")
                            .foregroundColor(Color.Primary800)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.Neutral200)
            } else {
                // No expand/collapse
                HStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 4, height: 18)
                        .background(Color.Primary500)
                        .cornerRadius(2)
                    
                    Text(getPrefix(for: item))
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                    
                    Text(displayTitle)
                        .appFont(.robotoRegular, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.white)
            }
            
            if !canExpand || item.isExpanded {
                VStack(spacing: 16) {
                    if isReadOnly {
                        Text(item.textAnswer.isEmpty ? "-" : item.textAnswer)
                            .appFont(.robotoRegular, size: 14)
                            .foregroundColor(item.textAnswer.isEmpty ? .Neutral500 : .Neutral800)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.Neutral100)
                            .cornerRadius(4)
                    } else {
                        let textBinding = Binding(
                            get: { item.textAnswer },
                            set: { item.textAnswer = $0 }
                        )
                        
                        TextField(
                            "",
                            text: textBinding
                        )
                        .blockEmoji(textBinding)
                        .appFont(.robotoRegular, size: 14)
                        .padding(12)
                        .background(Color.Neutral100)
                        .cornerRadius(4)
                        .focused($focusedField, equals: item.id)
                    }
                    
                    // Remarks
                    RemarksInputView(
                        text: Binding(
                            get: { item.remark },
                            set: { item.remark = $0 }
                        ),
                        isReadOnly: isReadOnly
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .if(!isReadOnly) { view in
                        view.focused($focusedField, equals: item.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(canExpand ? Color.Neutral200 : Color.white)
                
                Divider()
            }
        }
        .id(item.id)
    }
    
    // MARK: - Time Input View
    @ViewBuilder
    private var timeInputView: some View {
        let timeBinding = Binding<Date>(
            get: {
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                return formatter.date(from: item.textAnswer) ?? Date()
            },
            set: { newDate in
                let formatter = DateFormatter()
                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                item.textAnswer = formatter.string(from: newDate)
            }
        )
        
        VStack(alignment: .leading, spacing: 0) {
            if canExpand {
                Button(action: { withAnimation { item.toggleExpand() } }) {
                    HStack(spacing: 8) {
                        Text(getPrefix(for: item))
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                        Text(displayTitle)
                            .appFont(.robotoBold, size: 16)
                            .foregroundColor(.Neutral800)
                            .multilineTextAlignment(.leading)
                        Spacer()
                        Image(systemName: item.isExpanded ? "chevron.down" : "chevron.up")
                            .foregroundColor(Color.Primary800)
                    }
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .contentShape(Rectangle())
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color.Neutral200)
            } else {
                HStack(alignment: .center) {
                    Rectangle()
                        .foregroundColor(.clear)
                        .frame(width: 4, height: 18)
                        .background(Color.Primary500)
                        .cornerRadius(2)
                    Text(getPrefix(for: item))
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                    Text(displayTitle)
                        .appFont(.robotoRegular, size: 18)
                        .foregroundColor(.Primary500)
                        .multilineTextAlignment(.leading)
                }
                .padding(.vertical, 16)
                .padding(.horizontal, 16)
                .background(Color.white)
            }
            
            if !canExpand || item.isExpanded {
                VStack(spacing: 16) {
                    if isReadOnly {
                        Text(item.textAnswer.isEmpty ? "-" : item.textAnswer)
                            .appFont(.robotoRegular, size: 14)
                            .foregroundColor(item.textAnswer.isEmpty ? .Neutral500 : .Neutral800)
                            .padding(12)
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.Neutral100)
                            .cornerRadius(4)
                    } else {
                        CustomTimePickerView(
                            title: "",
                            time: timeBinding,
                            placeholder: "",
                            timeFormat: .twentyFourHour // 24小時制
                        )
                        .onAppear {
                            if item.textAnswer.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                                let formatter = DateFormatter()
                                formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
                                item.textAnswer = formatter.string(from: Date())
                            }
                        }
                    }
                    
                    RemarksInputView(
                        text: Binding(get: { item.remark }, set: { item.remark = $0 }),
                        isReadOnly: isReadOnly
                    )
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .if(!isReadOnly) { view in
                        view.focused($focusedField, equals: item.id)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, 16)
                .background(canExpand ? Color.Neutral200 : Color.white)
            }
            
            Divider()
        }
        .id(item.id)
    }

}


// MARK: - Choice Button

func getColorForChoice(_ choice: ChecklistChoice) -> Color {
    switch choice.value {
    case "Yes":
        return Color.Primary500
    case "No":
        return Color.red
    case "N/A":
        return Color.yellow
    default:
        return Color.Primary500
    }
}

struct ChoiceButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let backgroundColor: Color
    let isEnabled: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 2) {
                Text(title)
                    .appFont(.robotoRegular, size: 14)
                    .foregroundColor(isSelected ? .white : .Neutral500)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .frame(maxWidth: .infinity, alignment: .center)
            .background(isSelected ? color : backgroundColor)
            .cornerRadius(100)
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Checkbox Button

struct CheckboxButton: View {
    let title: String
    let isChecked: Bool
    let isEnabled: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                HStack(spacing: 8) {
                    Text(title)
                        .appFont(isChecked ? .robotoBold : .robotoRegular, size: 16)
                        .foregroundColor(isChecked ? .Primary500 : .Neutral500)
                    
                    Spacer()
                    
                    Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                        .foregroundColor(isChecked ? .Primary500 : .Neutral300)
                        .font(.system(size: 20))
                }
            }
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.white)
            .cornerRadius(16)
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .inset(by: 0.5)
                    .stroke(isChecked ? Color.Primary500 : Color.Neutral300, lineWidth: isChecked ? 2 : 1)
            )
        }
        .disabled(!isEnabled)
    }
}

// MARK: - Remarks Input View

struct RemarksInputView: View {
    @Binding var text: String
    let isReadOnly: Bool

    init(text: Binding<String>, isReadOnly: Bool = false) {
        self._text = text
        self.isReadOnly = isReadOnly
    }

    var body: some View {
        if isReadOnly {
            Text(text.isEmpty ? "-" : text)
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(text.isEmpty ? .Neutral500 : .Neutral800)
                .padding(12)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.Neutral100)
                .cornerRadius(4)
                .allowsHitTesting(false)
        } else {
            CustomInputView(
                title: "safety_inspection_checklist_label_remark".localized(),
                text: $text,
                placeholder: "safety_inspection_checklist_placeholder_remark".localized(),
                mode: .default
            )
        }
    }
}

// MARK: - View helper
private extension View {
    @ViewBuilder
    func `if`<Content: View>(_ condition: Bool, transform: (Self) -> Content) -> some View {
        if condition {
            transform(self)
        } else {
            self
        }
    }
}

#if DEBUG
#Preview {
    PreviewWrapper()
}

private struct PreviewWrapper: View {
    @FocusState private var focusedField: String?
    @State private var selectedItemId: String?

    var body: some View {
        ScrollView {
            LazyVStack(spacing: 0) {
                ForEach(LocalDataLoader.loadChecklist(filename: "checklist_mock")) { item in
                    ChecklistItemView(
                        item: item,
                        selectedItemId: $selectedItemId,
                        focusedField: $focusedField,
                        isReadOnly: true
                    )
                }
            }
        }
        .background(Color.Neutral100)
        .environmentObject(AppLanguageManager.shared)
    }
}
#endif
