//
//  IncidentReportListViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 9/2/2026.
//

import Foundation
import Combine

@MainActor
class IncidentReportListViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var incidentReport: [IncidentReport] = []
    @Published var isLoading: Bool = false
    @Published var isLoadingMore: Bool = false
    @Published var hasMorePages: Bool = true
    @Published var errorMessage: String? = nil
    
    // MARK: - Pagination State
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    
    // Task Management
    private var fetchTask: Task<Void, Never>?
    
    init() {
        print("IncidentReportListViewModel initialized")
    }
    
    deinit {
        fetchTask?.cancel()
    }
    
    // MARK: - Public Methods
    
    /// Returns true if the specified item is the last one in the current list.
    func hasReachedEnd(of item: IncidentReport) -> Bool {
        return incidentReport.last?.id == item.id
    }
    
    /// Fetch the Incident Report list (used for initial load and refresh).
    /// - Parameter reset: Reset pagination and data if true; load next page if false.
    func loadData(reset: Bool = false) async {
        guard !isLoading else { return }
        
        // Guard: if not resetting and no more pages, do nothing.
        if !reset && !hasMorePages {
            return
        }
        
        // Cancel previous task ONLY on reset
        if reset {
            fetchTask?.cancel()
        }
        
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }
        
        // Reset pagination state if needed
        if reset {
            currentPage = 1
            hasMorePages = true
        }
        
        fetchTask = Task {
            do {
                let responseList = try await APIService.getIncidentList(
                    page: currentPage,
                    pageSize: pageSize
                )
                
                // Ignore results if this task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Incident fetch task was cancelled")
                    return
                }
                
                // Convert Response to Domain Model
                let newItems = responseList.map { IncidentReport(from: $0) }
                
                // Update pagination flags
                hasMorePages = newItems.count >= pageSize
                
                // On reset, replace entire list; otherwise append
                if reset {
                    self.incidentReport = newItems
                } else {
                    self.incidentReport.append(contentsOf: newItems)
                }
                
                // Increment page only if got data
                if !newItems.isEmpty {
                    currentPage += 1
                }
                
                print("✅ Incident fetched \(newItems.count) items, page: \(currentPage - 1), total: \(incidentReport.count)")
                
            } catch {
                // Gracefully ignore expected cancel/cancellation errors
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    print("⚠️ Incident request was cancelled (normal when switching views)")
                    return
                }
                
                if error is CancellationError {
                    print("⚠️ Incident task was cancelled")
                    return
                }
                
                print("❌ Incident fetch list error:", error)
                Logger.error(tag: "IncidentList", "Load Data failed: \(error)")
                
                // Only set error message on initial load to avoid disrupting UX on load more
                if reset {
                    self.errorMessage = "Failed to load incident reports."
                }
                
                hasMorePages = false
            }
        }
        
        await fetchTask?.value
    }
    
    /// Load more items (pagination). Used by infinite scroll.
    func loadMoreItems() async {
        guard hasMorePages && !isLoading && !isLoadingMore else {
            print("⚠️ Incident cannot load more: hasMore=\(hasMorePages), isLoading=\(isLoading), isLoadingMore=\(isLoadingMore)")
            return
        }
        
        print("📥 Incident loading more items, current page: \(currentPage)")
        isLoadingMore = true
        
        do {
            let responseList = try await APIService.getIncidentList(
                page: currentPage,
                pageSize: pageSize
            )
            
            guard !Task.isCancelled else {
                print("⚠️ Incident load more task was cancelled")
                isLoadingMore = false
                return
            }
            
            let newItems = responseList.map { IncidentReport(from: $0) }
            
            if !newItems.isEmpty {
                incidentReport.append(contentsOf: newItems)
                hasMorePages = newItems.count >= pageSize
                currentPage += 1
                print("✅ Incident loaded page \(currentPage - 1): \(newItems.count) items, total: \(incidentReport.count), hasMore: \(hasMorePages)")
            } else {
                hasMorePages = false
                print("🏁 Incident no more items to load")
            }
            
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ Incident request was cancelled")
                isLoadingMore = false
                return
            }
            print("❌ Incident load more error:", error)
            Logger.error(tag: "IncidentList", "Load More failed: \(error)")
        }
        
        isLoadingMore = false
    }
    
    /// Pull-to-refresh action: resets state and reloads list from server.
    func refreshList() async {
        print("🔄 Incident refreshing list...")
        fetchTask?.cancel()
        
        // 確保重置狀態
        currentPage = 1
        hasMorePages = true
        
        await loadData(reset: true)
    }
    
    /// Cancels the currently running fetch task if any.
    func cancelCurrentTask() {
        fetchTask?.cancel()
        fetchTask = nil
    }
}
