//
//  LocalDataLoader.swift
//  dsd-swacs-staff
//
//  Created by Andy on 18/12/2025.
//

import Foundation

class LocalDataLoader {
    
    /// 從 Bundle 讀取並 Decode JSON 檔案
    /// - Parameter filename: 檔案名稱 (不含 .json)
    static func loadChecklist(filename: String = "checklist_mock") -> [ChecklistItem] {
        // 1. 尋找檔案路徑
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("❌ Error: File \(filename).json not found in Bundle.")
            return []
        }
        
        do {
            // 2. 讀取 Data
            let data = try Data(contentsOf: url)
            
            // 3. Decode (這裡會自動觸發我們寫好的 init(from: decoder) 邏輯)
            let items = try JSONDecoder().decode([ChecklistItem].self, from: data)
            
            // 4. 重要：處理 Prefix 邏輯 (因為 JSON 本身沒有 Parent Sort Order)
            assignParentSortOrder(items: items)
            
            print("✅ Successfully loaded \(items.count) root items from \(filename).json")
            return items
            
        } catch {
            print("❌ JSON Decode Error: \(error)")
            return []
        }
    }
}
