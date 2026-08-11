//
//  SWACDetailViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/11/2025.
//

import Foundation
import Combine

@MainActor
class SWACDetailViewModel: ObservableObject {
    @Published var swacDetail: SWACDetail?
    @Published var isLoading = false
    @Published var isSubmitting = false
    @Published var errorMessage: String?
    
    let swacNumber: String
    
    init(swacNumber: String) {
        self.swacNumber = swacNumber
    }
    
    /// Fetch SWAC detail from API
    func fetchDetail() async {
        // Prevent duplicate loading
        guard !isLoading else {
            return
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.fetchSWACProfile(swacNumber: swacNumber)
            self.swacDetail = SWACDetail(from: response)
        } catch {
            print("Fetch SWAC detail error:", error)
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    /// Submit Safety Vetting Action
    func submitSafetyVetting(isApprove: Bool, remarks: String) async -> Bool {
        guard !isSubmitting else { return false }
        isSubmitting = true
        errorMessage = nil
        
        do {
            let request = SafetyVettingRequest(swac: swacNumber, remarks: remarks)
            if isApprove {
                try await APIService.passSafetyVetting(request: request)
            } else {
                try await APIService.failSafetyVetting(request: request)
            }
            
            isSubmitting = false
            await fetchDetail()
            
            return true
        } catch {
            print("Submit safety vetting error:", error)
            self.errorMessage = error.localizedDescription
            self.isSubmitting = false
            return false
        }
    }
}
