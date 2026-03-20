//
//  ChecklistItem.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//

import SwiftUI
import Foundation

// MARK: - Checklist Item Type

enum ChecklistItemType: Int, Codable {
    case section = 0            // dataType: null
    case text = 1               // dataType: 1 or 2
    case checkboxChoice = 2     // dataType: 3 (Was multiChoice)
    case singleChoice = 3       // dataType: 4
    case time = 4               // dataType: 5
}

// MARK: - Checklist Choice

struct ChecklistChoice: Codable, Identifiable, Equatable {
    let id: Int
    let nameEng: String
    let nameChi: String?
    var isChecked: Bool

    var value: String {
        return nameEng
    }

    enum CodingKeys: String, CodingKey {
        case id = "rowID"
        case nameEng = "nameEng"
        case nameChi = "nameChi"
        case isChecked = "isChecked"
    }
    
    init(id: Int, nameEng: String, nameChi: String? = nil, isChecked: Bool = false) {
        self.id = id
        self.nameEng = nameEng
        self.nameChi = nameChi
        self.isChecked = isChecked
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(Int.self, forKey: .id)
        nameEng = try container.decode(String.self, forKey: .nameEng)
        nameChi = try container.decodeIfPresent(String.self, forKey: .nameChi)
        isChecked = try container.decodeIfPresent(Bool.self, forKey: .isChecked) ?? false
    }
    
    // Helper method to get display text
    func getDisplayValue(isEnglish: Bool) -> String {
        if isEnglish {
            return nameEng
        } else {
            return nameChi ?? nameEng
        }
    }
    
    static func == (lhs: ChecklistChoice, rhs: ChecklistChoice) -> Bool {
        return lhs.id == rhs.id && lhs.nameEng == rhs.nameEng && lhs.isChecked == rhs.isChecked
    }
}

// MARK: - Checklist Item

class ChecklistItem: ObservableObject, Identifiable, Codable {
    
    let id: String      // layoutID (String)
    let rowID: Int      // rowID (Int)
    let level: Int
    var sortOrder: Int
    var parentSortOrder: Int?
    let title: String?
    let titleChi: String?
    let itemType: ChecklistItemType
    
    @Published var choices: [ChecklistChoice]
    @Published var textAnswer: String  // Dedicated for dataType 1/2 TextField input
    @Published var remark: String // Dedicated for all item types' Remarks input
    @Published var childs: [ChecklistItem]
    @Published var isExpanded: Bool = true

    // Backend JSON Keys
    enum CodingKeys: String, CodingKey {
        case id = "layoutID"
        case rowID
        case level
        case sortOrder = "index"
        case title = "nameEng"
        case titleChi = "nameChi"
        case dataType
        case childs
        case optionCategories
        case text
        case number
        case option
        case boolean
        case dateTime
        case remarks
    }
    
    private static var standardYesNoChoices: [ChecklistChoice] {
        [
            ChecklistChoice(id: 1,
                            nameEng: "Yes",
                            nameChi: "是"),
            ChecklistChoice(id: 2,
                            nameEng: "No",
                            nameChi: "否"),
            ChecklistChoice(id: 3,
                            nameEng: "N/A",
                            nameChi: "不適用")
        ]
    }

    // MARK: - Initializer (Manual Creation)
    init(
        id: String,
        rowID: Int,
        level: Int,
        sortOrder: Int,
        title: String?,
        titleChi: String?,
        itemType: ChecklistItemType,
        choices: [ChecklistChoice] = [],
        textAnswer: String = "",
        remark: String = "",
        childs: [ChecklistItem] = []
    ) {
        self.id = id
        self.rowID = rowID
        self.level = level
        self.sortOrder = sortOrder
        self.title = title
        self.titleChi = titleChi
        self.itemType = itemType
        self.choices = choices
        self.textAnswer = textAnswer
        self.remark = remark
        self.childs = childs
    }

    // MARK: - Decoder Init
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        id = try container.decode(String.self, forKey: .id)
        rowID = try container.decode(Int.self, forKey: .rowID)
        level = try container.decode(Int.self, forKey: .level)
        sortOrder = try container.decode(Int.self, forKey: .sortOrder)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        titleChi = try container.decodeIfPresent(String.self, forKey: .titleChi)

        // Read answer fields from backend
        let textAnswerFromAPI = try container.decodeIfPresent(String.self, forKey: .text)
        let numberAnswerFromAPI = try container.decodeIfPresent(Int.self, forKey: .number)
        let optionAnswer = try container.decodeIfPresent(Int.self, forKey: .option)
        let booleanAnswer = try container.decodeIfPresent(Int.self, forKey: .boolean)
//        let dateTimeAnswer = try container.decodeIfPresent(String.self, forKey: .dateTime)
        let remarksAnswer = try container.decodeIfPresent(String.self, forKey: .remarks)
        
        /*
         Answer Mapping Logic:
         ┌──────────┬──────────────────────────┬───────────────────────────────────────┐
         │ dataType │ Answer Source Field      │ Destination                           │
         ├──────────┼──────────────────────────┼───────────────────────────────────────┤
         │    1     │ text                     │ textAnswer (TextField)                │
         │    2     │ number                   │ textAnswer (TextField, as String)     │
         │    3     │ option (rowID)           │ choices[i].isChecked = true           │
         │    4     │ boolean (1=Yes/2=No/3=NA)│ choices[i].isChecked = true           │
         │   null   │ -                        │ Section (no answer)                   │
         └──────────┴──────────────────────────┴───────────────────────────────────────┘
         
         Additional: All types use `remarks` field for the Remarks input box
         */
        
        
        // Process dataType logic
        let dataType = try container.decodeIfPresent(Int.self, forKey: .dataType)
        
        switch dataType {
        case 1: // Text Input
            itemType = .text
            choices = []
            textAnswer = textAnswerFromAPI ?? ""   // dataType 1: Read text field into textAnswer
            remark = remarksAnswer ?? ""
            
        case 2: // Number Input
            itemType = .text
            choices = []
            if let num = numberAnswerFromAPI {
                textAnswer = String(num)   // dataType 2: Read number field and convert to String for textAnswer
            } else {
                textAnswer = ""
            }
            remark = remarksAnswer ?? ""
            
        case 3: // Checkbox / Option Choice
            itemType = .checkboxChoice
            var loadedChoices = try container.decodeIfPresent([ChecklistChoice].self, forKey: .optionCategories) ?? []
            
            if let selectedOptionID = optionAnswer {   // dataType 3: Mark choice as checked based on option (rowID)
                for i in loadedChoices.indices {
                    if loadedChoices[i].id == selectedOptionID {
                        loadedChoices[i].isChecked = true
                    }
                }
            }
            
            choices = loadedChoices
            textAnswer = ""
            remark = remarksAnswer ?? ""
            
        case 4: // Single Choice (Yes/No/N/A)
            itemType = .singleChoice
            var standardChoices = ChecklistItem.standardYesNoChoices.map {
                ChecklistChoice(id: $0.id, nameEng: $0.nameEng, nameChi: $0.nameChi, isChecked: false)
            }
            
            if let selectedBool = booleanAnswer {    // dataType 4: Mark choice as checked based on boolean (1/2/3)
                for i in standardChoices.indices {
                    if standardChoices[i].id == selectedBool {
                        standardChoices[i].isChecked = true
                    }
                }
            }
            
            choices = standardChoices
            textAnswer = ""
            remark = remarksAnswer ?? ""
        case 5:
            itemType = .time
            choices = []
            textAnswer = textAnswerFromAPI ?? ""
            remark = remarksAnswer ?? ""
        default: // null or other -> Section
            itemType = .section
            choices = []
            textAnswer = ""
            remark = ""
        }
        
        // Recursively process child items
        childs = try container.decodeIfPresent([ChecklistItem].self, forKey: .childs) ?? []
        
        isExpanded = true
    }

    // MARK: - Encoder
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        // 1. Encode Basic Fields
        try container.encode(id, forKey: .id)
        try container.encode(rowID, forKey: .rowID)
        try container.encode(level, forKey: .level)
        try container.encode(sortOrder, forKey: .sortOrder)
        try container.encode(title, forKey: .title)
        try container.encode(titleChi, forKey: .titleChi)
        
        // 2. Encode Answer Fields based on ItemType
        switch itemType {
        case .text:
            // dataType 1 or 2
            if let numberValue = Int(textAnswer) {
                // If text can be converted to Int, save as number (dataType 2)
                try container.encode(numberValue, forKey: .number)
                try container.encode(2, forKey: .dataType)
            } else {
                // Otherwise save as text (dataType 1)
                try container.encode(textAnswer, forKey: .text)
                try container.encode(1, forKey: .dataType)
            }
        case .time:
            try container.encode(textAnswer, forKey: .text)
            try container.encode(5, forKey: .dataType)
        case .checkboxChoice: // Changed from .multiChoice
            // dataType 3: Checkbox Choice
            try container.encode(3, forKey: .dataType)
            
            // Encode the FIRST selected option ID (Backward compatibility for API single field)
            if let selected = choices.first(where: { $0.isChecked }) {
                try container.encode(selected.id, forKey: .option)
            }
            
            // Encode full state (Important for Local Draft to keep multiple checks)
            try container.encode(choices, forKey: .optionCategories)
            
        case .singleChoice:
            // dataType 4: Find selected boolean (1/2/3)
            try container.encode(4, forKey: .dataType)
            
            // Encode selected boolean value (1=Yes, 2=No, 3=NA)
            if let selected = choices.first(where: { $0.isChecked }) {
                try container.encode(selected.id, forKey: .boolean)
            }
            
        case .section:
            // Section usually has null dataType
            break
        }
        
        // 3. Encode Remarks (Common for all types)
        if !remark.isEmpty {
            try container.encode(remark, forKey: .remarks)
        }
        
        if !childs.isEmpty {
            try container.encode(childs, forKey: .childs)
        }
    }


    // MARK: - Helpers
    
    func getDisplayTitle(isEnglish: Bool) -> String {
        if isEnglish {
            return title ?? ""
        } else {
            return titleChi ?? title ?? ""
        }
    }

    var hasAnswer: Bool {
//        if !remark.trimmingCharacters(in: .whitespaces).isEmpty {
//            return true
//        }
//        
        switch itemType {
        case .section:
            return childs.allSatisfy { $0.hasAnswer }
        case .singleChoice, .checkboxChoice:
            return choices.contains { $0.isChecked }
        case .text, .time:
            return !textAnswer.trimmingCharacters(in: .whitespaces).isEmpty
        }
    }

    func toggleExpand() {
        isExpanded.toggle()
    }

    func selectSingleChoice(_ choiceId: Int) {
        for i in choices.indices {
            choices[i].isChecked = (choices[i].id == choiceId)
        }
    }

    func toggleCheckboxChoice(_ choiceId: Int) {
        if let index = choices.firstIndex(where: { $0.id == choiceId }) {
            choices[index].isChecked.toggle()
        }
    }

    func clearAnswers() {
        for i in choices.indices {
            choices[i].isChecked = false
        }
        textAnswer = ""
        remark = ""
        for child in childs {
            child.clearAnswers()
        }
    }
}

// MARK: - ParentSortOrder Logic

@discardableResult
func assignParentSortOrder(items: [ChecklistItem], parentSortOrder: Int? = nil) -> [ChecklistItem] {
    for item in items {
        item.parentSortOrder = parentSortOrder
        if !item.childs.isEmpty {
            assignParentSortOrder(items: item.childs, parentSortOrder: item.sortOrder)
        }
    }
    return items
}

// MARK: - Prefix Logic

func getPrefix(for item: ChecklistItem) -> String {
    switch item.level {
    case 0: return "\(item.sortOrder)"
    case 1:
        if let p = item.parentSortOrder { return "\(p).\(item.sortOrder)" }
        else { return "\(item.sortOrder)" }
    case 2:
        let alphabet = "abcdefghijklmnopqrstuvwxyz"
        let idx = item.sortOrder - 1
        if idx >= 0 && idx < alphabet.count {
            let char = alphabet[alphabet.index(alphabet.startIndex, offsetBy: idx)]
            return "\(char)."
        }
        return ""
    default: return ""
    }
}
