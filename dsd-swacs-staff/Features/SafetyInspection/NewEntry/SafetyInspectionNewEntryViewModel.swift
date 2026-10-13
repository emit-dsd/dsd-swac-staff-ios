//
//  SafetyInspectionNewEntryViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//
import Foundation
import SwiftUI
import UIKit
import Combine

@MainActor
class SafetyInspectionNewEntryViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var isReadOnly: Bool = false
    @Published var swacDetail: SWACDetail?
    
    // Form fields
    @Published var date = Date()
    @Published var workDetails: String = ""
    @Published var typeOfConfinedSpace: String = ""
    
    // Images
    @Published var permitImages: [ImageAsset] = []
    @Published var raImages: [ImageAsset] = []
    @Published var permitCompleteImages: [ImageAsset] = []
    @Published var isLoadingAttachments: Bool = false
    
    let swacNumber: String
    let part: SafetyInspectionPart
    
    private var inspectionId: Int?
    
    private let subjectPermit = "Permit"
    private let subjectFreshRA = "FreshRA"
    private let subjectPermitComplete = "Permit-complete"

    private let targetImageSizeBytes = 1 * 1024 * 1024
    private let maxTotalImageSizeBytes = 20 * 1024 * 1024
    
    var apiResults: [SafetyInspectionChecklistResult]? = nil
    
    // MARK: - Permissions
    // Part A image (Permit, Fresh RA) can edit
    var canEditPartAImages: Bool {
        return part == .partA && !isReadOnly
    }
    
    // Part B image (Permit Complete) can edit
    var canEditPartBImages: Bool {
        return part == .partB
    }
    
    // MARK: - Computed Properties
    
    /// Check if all required fields are filled
    var isFormComplete: Bool {
        switch part {
        case .partA:
            return !workDetails.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !typeOfConfinedSpace.trimmingCharacters(in: .whitespaces).isEmpty &&
                   !permitImages.isEmpty &&
                   !raImages.isEmpty
        case .partB:
            return !permitCompleteImages.isEmpty
        case .full:
            return true
        }
    }
    
    /// Check if there are unsaved changes
    var shouldShowLeaveAlert: Bool {
        if part == .full || (isReadOnly && part == .partA) { return false }
        if part == .partB {
            return !permitCompleteImages.isEmpty
        }
        return !workDetails.isEmpty || !typeOfConfinedSpace.isEmpty || !permitImages.isEmpty || !raImages.isEmpty
    }
    
    var isEditingDraft: Bool = false
    var existingDraftId: UUID?
    var cachedChecklistItems: [ChecklistItem] = []

    // MARK: - Initialization

    init(swacNumber: String, draft: SafetyInspectionDraft? = nil, inspectionId: Int? = nil, part: SafetyInspectionPart = .partA) {
        self.swacNumber = swacNumber
        self.inspectionId = inspectionId
        self.part = part
        
        // only init Part A can edit, other only read
        self.isReadOnly = (inspectionId != nil) || (part != .partA)
        
        if let draft = draft {
            self.isEditingDraft = true
            self.existingDraftId = draft.id
            self.date = draft.checkingDate
            self.workDetails = draft.workDetails
            self.typeOfConfinedSpace = draft.typeOfConfinedSpace
            self.permitImages = draft.permitImages.map { ImageAsset(image: $0, caption: "") }
            self.raImages = draft.raImages.map { ImageAsset(image: $0, caption: "") }
            self.permitCompleteImages = draft.permitCompleteImages.map { ImageAsset(image: $0, caption: "") }
            self.cachedChecklistItems = draft.checklistItems
        }
    }
    
    // MARK: - Create Draft Payload
    func createDraftPayload() -> SafetyInspectionDraft {
        let pData = compressedData(for: permitImages)
        let rData = compressedData(for: raImages)
        let pcData = compressedData(for: permitCompleteImages)

        logDraftImageSizes(category: subjectPermit, data: pData)
        logDraftImageSizes(category: subjectFreshRA, data: rData)
        logDraftImageSizes(category: subjectPermitComplete, data: pcData)
        
        return SafetyInspectionDraft(
            id: existingDraftId ?? UUID(),
            apiId: self.inspectionId,
            swacNumber: swacNumber,
            checkingDate: date,
            workDetails: workDetails,
            typeOfConfinedSpace: typeOfConfinedSpace,
            permitImagesData: pData,
            raImagesData: rData,
            permitCompleteImagesData: pcData,
            checklistItems: cachedChecklistItems
        )
    }
    
    // MARK: - API Methods
    @MainActor
    func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        
        do {
            if let id = inspectionId {
                // SWAC Detail + Inspection Detail
                print("📡 Loading detail for ID: \(id)")
                
                async let swacTask = APIService.fetchSWACProfile(swacNumber: swacNumber)
                async let detailTask = APIService.getSafetyInspectionDetail(id: id)
                
                let (swac, detail) = try await (swacTask, detailTask)
                
                // 1. SWAC
                self.swacDetail = SWACDetail(from: swac)
                
                // 2. Inspection
                self.date = detail.reportTime.iso8601Date ?? Date()
                self.workDetails = detail.worksDetail
                self.typeOfConfinedSpace = detail.confinedSpaceType
                
                //  3. API Results
                self.apiResults = detail.result
                
                isLoading = false
                
                Task {
                    await loadAttachments(attachmentIds: detail.attachment)
                }
                
            } else {
                // Draft + SWAC Detail
                let swac = try await APIService.fetchSWACProfile(swacNumber: swacNumber)
                self.swacDetail = SWACDetail(from: swac)
            }
        } catch {
            print("❌ loadData error: \(error)")
        }
    }
    
    private func loadAttachments(attachmentIds: [String]) async {
        guard !attachmentIds.isEmpty else { return }
        guard !isLoadingAttachments else { return }
        
        isLoadingAttachments = true
        defer { isLoadingAttachments = false }

        do {
            permitImages.removeAll()
            raImages.removeAll()
            permitCompleteImages.removeAll()

            let items = try await APIService.getDocumentContentItems(attachmentIds: attachmentIds)

            for item in items {
                guard
                    let fileData = item.data.fileData,
                    let uiImage = UIImage(data: fileData)
                else { continue }

                let asset = ImageAsset(image: uiImage, caption: "")
                let subject = item.profile.subject ?? ""
                
                if subject.caseInsensitiveCompare(subjectPermit) == .orderedSame {
                    permitImages.append(asset)
                } else if subject.caseInsensitiveCompare(subjectFreshRA) == .orderedSame {
                    raImages.append(asset)
                } else if subject.caseInsensitiveCompare(subjectPermitComplete) == .orderedSame {
                    permitCompleteImages.append(asset)
                }else {
                    print("⚠️ Unknown attachment subject: \(subject)")
                    if permitImages.isEmpty {
                        permitImages.append(asset)
                    } else {
                        raImages.append(asset)
                    }
                }
            }
            
            print("✅ Loaded \(items.count) attachments")
        } catch {
            print("❌ loadAttachments error: \(error)")
        }
    }
    
    // MARK: - Image Management
    
    @discardableResult
    func addPermitImage(_ image: UIImage) -> Bool {
        addImage(image, to: &permitImages, category: subjectPermit)
    }
    
    func removePermitImage() {
        permitImages.removeAll()
    }
    
    @discardableResult
    func addRAImage(_ image: UIImage) -> Bool {
        addImage(image, to: &raImages, category: subjectFreshRA)
    }
    
    func removeRAImage() {
        raImages.removeAll()
    }
    
    @discardableResult
    func addPermitCompleteImage(_ image: UIImage) -> Bool {
        addImage(image, to: &permitCompleteImages, category: subjectPermitComplete)
    }
    
    func removePermitCompleteImage() {
        permitCompleteImages.removeAll()
    }

    var totalImageSizeMB: Double {
        let images: [ImageAsset]

        if part == .partB {
            // Part B uploads Permit-complete images independently.
            images = permitCompleteImages
        } else {
            images = permitImages + raImages + permitCompleteImages
        }

        let data = compressedData(for: images)
        return Double(data.reduce(0) { $0 + $1.count }) / (1024.0 * 1024.0)
    }

    // MARK: - Image Compression

    private func addImage(_ image: UIImage, to images: inout [ImageAsset], category: String) -> Bool {
        guard let compressedData = compressedData(for: image),
              let compressedImage = UIImage(data: compressedData) else {
            return false
        }

        let originalSize = image.jpegData(compressionQuality: 1.0)?.count ?? 0
        let compressedSize = compressedData.count
        let originalMB = Double(originalSize) / (1024.0 * 1024.0)
        let compressedMB = Double(compressedSize) / (1024.0 * 1024.0)
        let ratio = originalSize > 0 ? (1.0 - Double(compressedSize) / Double(originalSize)) * 100.0 : 0
        print("🗜️ [SafetyInspection] \(category) compressed: \(Int(image.size.width * image.scale))x\(Int(image.size.height * image.scale)) px / \(String(format: "%.2f", originalMB)) MB -> \(Int(compressedImage.size.width * compressedImage.scale))x\(Int(compressedImage.size.height * compressedImage.scale)) px / \(String(format: "%.2f", compressedMB)) MB (reduced \(String(format: "%.1f", ratio))%)")

        let existingSize = totalImageSizeMB
        let newSize = Double(compressedData.count) / (1024.0 * 1024.0)
        guard (existingSize + newSize) * 1024.0 * 1024.0 <= Double(maxTotalImageSizeBytes) else {
            return false
        }

        images.append(ImageAsset(image: compressedImage, caption: ""))
        return true
    }

    private func logDraftImageSizes(category: String, data: [Data]) {
        let totalBytes = data.reduce(0) { $0 + $1.count }
        let totalMB = Double(totalBytes) / (1024.0 * 1024.0)
        let sizes = data.map(\.count).map(String.init).joined(separator: ", ")
        print("📦 [SafetyInspection] Draft \(category): \(data.count) image(s), sizes=[\(sizes)] bytes, total=\(String(format: "%.2f", totalMB)) MB")
    }

    private func compressedData(for images: [ImageAsset]) -> [Data] {
        images.compactMap { $0.image.flatMap(compressedData(for:)) }
    }

    private func compressedData(for image: UIImage) -> Data? {
        var maxDimension: CGFloat = 2048

        while maxDimension >= 640 {
            let resizedImage = resizedImage(image, maxDimension: maxDimension)

            for quality in stride(from: 0.85, through: 0.35, by: -0.05) {
                guard let data = resizedImage.jpegData(compressionQuality: quality) else { continue }
                if data.count <= targetImageSizeBytes {
                    return data
                }
            }

            maxDimension *= 0.8
        }

        let finalImage = resizedImage(image, maxDimension: 640)
        return finalImage.jpegData(compressionQuality: 0.3)
    }

    private func resizedImage(_ image: UIImage, maxDimension: CGFloat) -> UIImage {
        let sourceSize = image.size
        let longestSide = max(sourceSize.width, sourceSize.height)
        guard longestSide > maxDimension, longestSide > 0 else { return image }

        let scale = maxDimension / longestSide
        let targetSize = CGSize(width: sourceSize.width * scale, height: sourceSize.height * scale)
        let format = UIGraphicsImageRendererFormat()
        format.scale = 1
        format.opaque = true

        return UIGraphicsImageRenderer(size: targetSize, format: format).image { _ in
            image.draw(in: CGRect(origin: .zero, size: targetSize))
        }
    }
    
    // MARK: - Reset
    
    func reset() {
        workDetails = ""
        typeOfConfinedSpace = ""
        permitImages.removeAll()
        raImages.removeAll()
    }
}
