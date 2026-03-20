//
//  SafetyInspectionChecklistViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//

import Foundation
import Combine

@MainActor
class SafetyInspectionChecklistViewModel: ObservableObject {
    
    @Published var checklistItems: [ChecklistItem] = []
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?
    
    let isReadOnly: Bool
    let part: SafetyInspectionPart
    var currentDraft: SafetyInspectionDraft?
    private var initialResults: [SafetyInspectionChecklistResult]?
    
    private var allOriginalItems: [ChecklistItem] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    
    /// Case 1: Edit Mode (Draft)
    init(draft: SafetyInspectionDraft, part: SafetyInspectionPart = .partA) {
        self.isReadOnly = false
        self.currentDraft = draft
        self.part = part
        self.initialResults = nil
        
        if !draft.checklistItems.isEmpty {
            self.assignParentSortOrder(items: draft.checklistItems)
            self.allOriginalItems = draft.checklistItems
            self.checklistItems = self.filterChecklistByPart(items: draft.checklistItems)
        }
    }
    
    /// Case 2: ReadOnly Mode (Results)
    init(results: [SafetyInspectionChecklistResult], part: SafetyInspectionPart = .partA) {
        self.isReadOnly = true
        self.currentDraft = nil
        self.part = part
        self.initialResults = results
    }
    
    // MARK: - Section Filter Logic
    private func filterChecklistByPart(items: [ChecklistItem]) -> [ChecklistItem] {
        switch part {
        case .partA:
            return items.filter { !($0.level == 0 && $0.sortOrder == 9) }
        case .partB:
            return items.filter { $0.level == 0 && $0.sortOrder == 9 }
        case .full:
            return items
        }
    }
    
    // MARK: - Computed Properties
    var isChecklistComplete: Bool {
        return checklistItems.allSatisfy { $0.hasAnswer }
    }
    
    // MARK: - API Methods
    func fetchChecklist() async {
        if !isReadOnly, !checklistItems.isEmpty { return }
        
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        /*
        // Simulate API delay
        try? await Task.sleep(for: .seconds(1))
        
        // Use example data for now
        
        let items = LocalDataLoader.loadChecklist(filename: "checklist_mock")
        
        await MainActor.run {
            self.checklistItems = items
            self.isLoading = false
        }
        
        print("✅ Loaded \(checklistItems.count) checklist sections (using example data)")
        */
        
        
        do {
            let items = try await APIService.fetchSafetyInspectionFormat()
            
            await MainActor.run {
                self.assignParentSortOrder(items: items)
                
                self.allOriginalItems = items
                let filteredItems = self.filterChecklistByPart(items: items)
                
                if self.isReadOnly, let results = self.initialResults, !results.isEmpty {
                    print("🔄 ReadOnly Mode: Mapping \(results.count) results to checklist...")
                    self.applyAnswers(items: filteredItems, results: results)
                }
                
                self.checklistItems = filteredItems
                self.isLoading = false
            }
            
            print("✅ Loaded \(checklistItems.count) checklist sections from API")
            
        } catch {
            print("❌ Fetch checklist error:", error)
            await MainActor.run {
                self.errorMessage = "Failed to load checklist: \(error.localizedDescription)"
                self.isLoading = false
            }
        }
    }
    
    // MARK: - Mapping Logic
    
    private func applyAnswers(items: [ChecklistItem], results: [SafetyInspectionChecklistResult]) {
        let resultMap = Dictionary(uniqueKeysWithValues: results.map { ($0.category, $0) })
        fillItems(items, using: resultMap)
    }
    
    private func fillItems(_ items: [ChecklistItem], using resultMap: [Int: SafetyInspectionChecklistResult]) {
        for item in items {
            
            if let result = resultMap[item.rowID] {
                // Remarks
                if let remark = result.remarks, !remark.isEmpty {
                    item.remark = remark
                }
                
                // Text / Number
                if let text = result.text, !text.isEmpty {
                    item.textAnswer = text
                } else if let num = result.number {
                    item.textAnswer = String(num)
                }
                
                // Choices
                switch item.itemType {
                case .singleChoice:
                    if let boolVal = result.boolean {
                        item.selectSingleChoice(boolVal)
                    }
                case .checkboxChoice:
                    if let optionId = result.option {
                        // 假設 option 直接對應 Choice ID
                        if let index = item.choices.firstIndex(where: { $0.id == optionId }) {
                            item.choices[index].isChecked = true
                        }
                    }
                default: break
                }
            }

            if !item.childs.isEmpty {
                fillItems(item.childs, using: resultMap)
            }
        }
    }
    
    // MARK: - Helper: Parent Sort Order
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
    
    // MARK: - Draft & Submit Actions (Only for Edit Mode)
    
    func saveAsDraft() async -> Bool {
        guard !isReadOnly, var draft = currentDraft else { return false }
        
        guard part == .partA else { return false }
        
        isSaving = true
        defer { isSaving = false }
        
        draft.checklistItems = self.allOriginalItems
        draft.savedDate = Date()
        
        do {
            try DraftManager.shared.save(draft)
            self.currentDraft = draft
            return true
        } catch {
            errorMessage = "儲存草稿失敗: \(error.localizedDescription)"
            return false
        }
    }
    

    func submitInspection() async -> Bool {
        guard !isReadOnly, var draft = currentDraft else { return false }
        guard !isSaving else { return false }
        
        isSaving = true
        errorMessage = nil
        
        draft.checklistItems = self.checklistItems
        
        let df = DateFormatter()
        df.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let reportTimeStr = df.string(from: draft.checkingDate)
        
        do {
            if part == .partA {
                print("Opening Inspection for SWAC \(draft.swacNumber)")
                let _ = try await APIService.openSafetyInspection(
                    reportTime: reportTimeStr,
                    worksDetail: draft.workDetails,
                    confinedSpaceType: draft.typeOfConfinedSpace,
                    swac: draft.swacNumber,
                    items: self.allOriginalItems,
                    permitImages: draft.permitImagesData,
                    raImages: draft.raImagesData
                )
            } else if part == .partB {
                print("Closing Inspection for SWAC \(draft.swacNumber)")
                guard let apiId = draft.apiId else {
                    throw NSError(domain: "Missing API ID for Part B", code: 0, userInfo: nil)
                }
                
                let _ = try await APIService.closeSafetyInspection(
                    id: apiId,
                    items: self.checklistItems,
                    permitCompleteImages: draft.permitCompleteImagesData
                )
            }
            
            DraftManager.shared.delete(draft.id)
            return true
            
        } catch {
            print("❌ Submission failed: \(error)")
            errorMessage = "提交失敗: \(error.localizedDescription)" // 顯示具體錯誤
            
            _ = await saveAsDraft()
            
            isSaving = false
            return false
        }
    }
    
//    private func countItems(in items: [ChecklistItem]) -> Int {
//        var count = 0
//        for item in items {
//            if item.itemType != .section {
//                count += 1
//            }
//            count += countItems(in: item.childs)
//        }
//        return count
//    }
//    
//    private func countAnsweredItems(in items: [ChecklistItem]) -> Int {
//        var count = 0
//        for item in items {
//            if item.itemType != .section && item.hasAnswer {
//                count += 1
//            }
//            count += countAnsweredItems(in: item.childs)
//        }
//        return count
//    }
//    
//    func clearAllAnswers() {
//        for item in checklistItems {
//            item.clearAnswers()
//        }
//    }
    
    private func printChecklistAnswers() {
        print("\n📋 Checklist Answers:")
        printItemAnswers(items: checklistItems, indent: 0)
    }
    
    private func printItemAnswers(items: [ChecklistItem], indent: Int) {
        let prefix = String(repeating: "  ", count: indent)
        for item in items {
            if item.itemType == .section {
                print("\(prefix)📁 \(item.title ?? "") \(item.titleChi ?? "")")
            } else {
                print("\(prefix)📁 \(item.title ?? "") \(item.titleChi ?? "")")
                
                if !item.choices.isEmpty {
                    let selected = item.choices.filter { $0.isChecked }.map { $0.value }
                    print("\(prefix)   Selected: \(selected.joined(separator: ", "))")
                }
                
                if !item.remark.isEmpty {
                    print("\(prefix)   Remarks: \(item.remark)")
                }
            }
            
            if !item.childs.isEmpty {
                printItemAnswers(items: item.childs, indent: indent + 1)
            }
        }
    }
}
