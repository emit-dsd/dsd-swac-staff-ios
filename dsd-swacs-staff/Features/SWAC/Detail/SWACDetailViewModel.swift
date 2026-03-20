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
}
