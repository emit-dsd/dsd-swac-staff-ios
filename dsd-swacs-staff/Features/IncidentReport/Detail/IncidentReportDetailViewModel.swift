//
//  IncidentReportDetailViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 10/2/2026.
//

import Foundation
import Combine

@MainActor
class IncidentReportDetailViewModel: ObservableObject {
    @Published var report: IncidentReport?
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    let reportId: Int
    
    init(reportId: Int) {
        self.reportId = reportId
    }
    
    func loadDetail() async {
        isLoading = true
        errorMessage = nil
        
        do {
            let response = try await APIService.getIncidentDetail(id: reportId)
            self.report = IncidentReport(from: response)
            
        } catch {
            Logger.error(tag: "IncidentDetail", "Failed: \(error)")
            errorMessage = "Failed to load report."
        }
        
        isLoading = false
    }
}
