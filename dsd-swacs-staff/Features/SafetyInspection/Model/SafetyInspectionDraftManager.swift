//
//  SafetyInspectionDraftManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 5/1/2026.
//

import Foundation
import UIKit


struct SafetyInspectionDraft: Codable, Identifiable {
    var id: UUID = UUID()
    var savedDate: Date = Date()
    
    var apiId: Int? = nil
    
    let swacNumber: String
    let checkingDate: Date
    let workDetails: String
    let typeOfConfinedSpace: String
    let permitImagesData: [Data]
    let raImagesData: [Data]
    var permitCompleteImagesData: [Data] = []
    
    var checklistItems: [ChecklistItem] = []
    
    var permitImages: [UIImage] {
        permitImagesData.compactMap { UIImage(data: $0) }
    }
    
    var raImages: [UIImage] {
        raImagesData.compactMap { UIImage(data: $0) }
    }
    
    var permitCompleteImages: [UIImage] {
        permitCompleteImagesData.compactMap { UIImage(data: $0) }
    }
}

class DraftManager {
    static let shared = DraftManager()
    private let folderName = "inspection_drafts"
    
    private init() { createFolderIfNeeded() }
    
    private var folderURL: URL? {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent(folderName)
    }
    
    private func createFolderIfNeeded() {
        guard let url = folderURL else { return }
        if !FileManager.default.fileExists(atPath: url.path) {
            try? FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
        }
    }
    
    func save(_ draft: SafetyInspectionDraft) throws {
        guard let url = folderURL?.appendingPathComponent("\(draft.id.uuidString).json") else { return }
        let data = try JSONEncoder().encode(draft)
        try data.write(to: url)
        print("💾 Draft saved to: \(url.path)")
    }
    
    func loadAll() -> [SafetyInspectionDraft] {
        guard let url = folderURL else { return [] }
        do {
            let fileURLs = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil)
            return fileURLs.compactMap { url in
                guard let data = try? Data(contentsOf: url) else { return nil }
                return try? JSONDecoder().decode(SafetyInspectionDraft.self, from: data)
            }.sorted { $0.savedDate > $1.savedDate }
        } catch {
            print("❌ Load drafts error: \(error)")
            return []
        }
    }
    
    func delete(_ draftId: UUID) {
        guard let url = folderURL?.appendingPathComponent("\(draftId.uuidString).json") else { return }
        try? FileManager.default.removeItem(at: url)
    }
}
