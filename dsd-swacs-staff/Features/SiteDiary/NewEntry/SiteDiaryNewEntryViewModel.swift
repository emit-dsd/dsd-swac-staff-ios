//
//  SiteDiaryNewEntryViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SiteDiaryNewEntryViewModel: ObservableObject {
    @Published var swacDetail: SWACDetail?
    @Published var isLoading = false
    @Published var isSaving = false
    @Published var errorMessage: String?

    @Published var selectedApprove: DropdownItem? = nil
    @Published var approverList: [DropdownItem] = []

    @Published var date = Date()
    @Published var selectedWeatherAM: WeatherSelectorStatus? = nil
    @Published var selectedWeatherPM: WeatherSelectorStatus? = nil
    @Published var labour: Int? = nil
    @Published var descriptionText: String = ""
    @Published var instructionText: String = ""
    @Published var responseText: String = ""
    @Published var images: [ImageAsset] = []
    
    let swacNumber: String
    
    init(swacNumber: String) {
        self.swacNumber = swacNumber
    }
    
    // MARK: - Validation & State
    var hasUnsavedChanges: Bool {
        let hasDesc = !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasInstruction = !instructionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasResponse = !responseText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasImages = !images.isEmpty
        let hasWeatherAM = selectedWeatherAM != nil
        let hasWeatherPM = selectedWeatherPM != nil
        let hasSelectedApprove = selectedApprove != nil

        return hasDesc || hasInstruction || hasImages || hasWeatherAM || hasWeatherPM || hasSelectedApprove
    }
    
    var isFormValid: Bool {
        let hasDescription = !descriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        let hasApprover = selectedApprove != nil
        let hasWeather = selectedWeatherAM != nil || selectedWeatherPM != nil
        let hasLabour = labour != nil
        return hasDescription && hasApprover && hasWeather && hasLabour
    }
    
    var canSubmit: Bool {
        !isSaving && swacDetail != nil && isFormValid
    }
    
    // MARK: - API Actions
    func fetchSWACDetail() async {
        guard !isLoading else { return }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            let response = try await APIService.fetchSWACProfile(swacNumber: swacNumber)
            let detail = SWACDetail(from: response)
            self.swacDetail = detail
            
            await fetchApprovers(rcc: detail.regionalControlCentre)
            
        } catch {
            Logger.error(tag: "SiteDiary", "Failed to load SWAC details: \(error)")
            errorMessage = "Failed to load SWAC details"
        }
    }
    
    func fetchApprovers(rcc: Int) async {
        do {
            let approvers = try await APIService.getApproverByRCC(rcc: rcc)
            
            self.approverList = approvers.map { approver in
                DropdownItem(id: approver.id, displayText: approver.displayName)
            }

            if self.approverList.count == 1 {
                self.selectedApprove = self.approverList.first
            }
            
        } catch {
            Logger.error(tag: "SiteDiary", "Failed to load Approvers: \(error)")
        }
    }
    
    func submitSiteDiary() async throws -> Int {
        guard let approver = selectedApprove else {
            throw NSError(domain: "SiteDiary", code: -2, userInfo: [NSLocalizedDescriptionKey: "Approver is required"])
        }

        isSaving = true
        defer { isSaving = false }
        
        let dateString = formatDate(date)
        let (attachments, attachmentFiles) = prepareAttachments(images)

        let weatherAMValue = selectedWeatherAM?.apiValue
        let weatherPMValue = selectedWeatherPM?.apiValue
        let labourValue = labour

        let response = try await APIService.submitSiteDiary(
            instruction: instructionText,
            response: responseText,
            swac: swacNumber,
            weatherAM: weatherAMValue,
            weatherPM: weatherPMValue,
            labour: labourValue,
            workActivity: descriptionText,
            date: dateString,
            approver: approver.id,
            attachments: attachments,
            attachmentFiles: attachmentFiles
        )

        Logger.debug(tag: "SiteDiary", "✅ Site Diary created with ID: \(response.id)")
        return response.id
    }
    
    // MARK: - Image Logic
    func addImage(_ asset: ImageAsset) {
        images.append(asset)
    }
    
    func updateImage(_ asset: ImageAsset) {
        if let idx = images.firstIndex(where: { $0.id == asset.id }) {
            images[idx] = asset
        }
    }
    
    func removeImage(_ asset: ImageAsset) {
        images.removeAll { $0.id == asset.id }
    }
    
    func validateImageSize(_ image: UIImage, maxSizeMB: Double = 5.0) -> (isValid: Bool, sizeMB: Double) {
        guard let data = image.jpegData(compressionQuality: 0.8) else {
            return (false, 0)
        }
        let sizeMB = Double(data.count) / (1024.0 * 1024.0)
        return (sizeMB <= maxSizeMB, sizeMB)
    }
    
    // MARK: - Private Helpers
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    private func prepareAttachments(_ images: [ImageAsset]) -> ([SiteDiaryAttachment], [Data]) {
        var attachments: [SiteDiaryAttachment] = []
        var attachmentFiles: [Data] = []
        
        for (index, imageAsset) in images.enumerated() {
            guard let image = imageAsset.image,
                  let imageData = image.jpegData(compressionQuality: 0.8) else {
                Logger.warning(tag: "SiteDiary", "Skipping image at index \(index)")
                continue
            }
            
            let subject = imageAsset.caption.isEmpty ? "Image \(index + 1)" : imageAsset.caption
            let remarks = imageAsset.caption.isEmpty ? nil : imageAsset.caption
            
            attachments.append(SiteDiaryAttachment(subject: subject, remarks: remarks))
            attachmentFiles.append(imageData)
        }
        
        return (attachments, attachmentFiles)
    }
}
