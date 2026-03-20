//
//  SafetyInspectionNewEntryViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//
import Foundation
import SwiftUI
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
        let pData = permitImages.compactMap { $0.image?.jpegData(compressionQuality: 0.8) }
        let rData = raImages.compactMap { $0.image?.jpegData(compressionQuality: 0.8) }
        let pcData = permitCompleteImages.compactMap { $0.image?.jpegData(compressionQuality: 0.8) }
        
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
    
    func addPermitImage(_ image: UIImage) {
        permitImages.append(ImageAsset(image: image, caption: ""))
    }
    
    func removePermitImage() {
        permitImages.removeAll()
    }
    
    func addRAImage(_ image: UIImage) {
        raImages.append(ImageAsset(image: image, caption: ""))
    }
    
    func removeRAImage() {
        raImages.removeAll()
    }
    
    func addPermitCompleteImage(_ image: UIImage) {
        permitCompleteImages.append(ImageAsset(image: image, caption: ""))
    }
    
    func removePermitCompleteImage() {
        permitCompleteImages.removeAll()
    }
    
    // MARK: - Reset
    
    func reset() {
        workDetails = ""
        typeOfConfinedSpace = ""
        permitImages.removeAll()
        raImages.removeAll()
    }
}
