//
//  SafetyInspectionListViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 20/11/2025.
//

import Foundation
import Combine

@MainActor
class SafetyInspectionListViewModel: ObservableObject {
    @Published var swacDetail: SWACDetail?
    @Published var safetyInspectionItemList: [SafetyInspectionItem] = []

    // UI Loading States
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    // Store current filter state
    @Published var currentFilter: SafetyInspectionListView.SafetyInspectionStatusFilter = .all

    // Pagination
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    
    // Task management
    private var fetchTask: Task<Void, Never>?
    
    let swacNumber: String

    init(swacNumber: String) {
        self.swacNumber = swacNumber
    }
    
    deinit {
        fetchTask?.cancel()
    }

    // MARK: - loadData

    /// - Parameters:
    ///   - reset: Whether to reload from the first page
    ///   - filter: If switching tabs, pass the new filter
    func loadData(reset: Bool = false, filter: SafetyInspectionListView.SafetyInspectionStatusFilter? = nil) async {
        guard !isLoading else { return }
        
        // Cancel previous task ONLY on reset to avoid race conditions
        if reset {
            fetchTask?.cancel()
            if let newFilter = filter {
                self.currentFilter = newFilter
            }
            currentPage = 1
            hasMorePages = true
        }
        
        isLoading = true
        
        fetchTask = Task {
            defer { isLoading = false }
            
            // Load Drafts (Always loaded locally)
            let localDrafts = DraftManager.shared.loadAll()
                .filter { $0.swacNumber == self.swacNumber }
                .map { SafetyInspectionItem(from: $0) }
            
            do {
                // If swacDetail is nil, fetch SWAC Profile first
                if self.swacDetail == nil {
                    let swac = try await APIService.fetchSWACProfile(swacNumber: swacNumber)
                    guard !Task.isCancelled else { return }
                    self.swacDetail = SWACDetail(from: swac)
                }
                
                // If filter is .draft, skip API call entirely
                if self.currentFilter == .draft {
                    self.safetyInspectionItemList = localDrafts
                    self.hasMorePages = false
                    return
                }
                
                // Otherwise, call API based on the filter's isClosed mapping
                let isClosedValue = self.currentFilter.isClosedValue
                
                let apiList = try await APIService.getSafetyInspectionList(
                    swac: swacNumber,
                    page: 1,
                    pageSize: pageSize,
                    isClosed: isClosedValue
                )

                guard !Task.isCancelled else { return }

                let apiItems = apiList.map {
                    SafetyInspectionItem(from: $0, swacNumber: self.swacNumber)
                }

                // Draft + API (Only prepend Drafts if filter is .all)
                // For pendingClose or closed, only show data returned from the API
                if self.currentFilter == .all {
                    self.safetyInspectionItemList = localDrafts + apiItems
                } else {
                    self.safetyInspectionItemList = apiItems
                }

                self.hasMorePages = apiList.count >= pageSize
                
                // Update current page (Next page will be 2)
                if !apiList.isEmpty {
                    self.currentPage = 2
                }

            } catch {
                if Task.isCancelled { return }
                
                print("❌ loadData error:", error)
                
                if reset || self.safetyInspectionItemList.isEmpty {
                    // Fallback to local drafts if API fails and filter applies
                    if !localDrafts.isEmpty && (self.currentFilter == .all || self.currentFilter == .draft) {
                        self.safetyInspectionItemList = localDrafts
                    } else {
                        self.safetyInspectionItemList = []
                    }
                }
                
                self.hasMorePages = false
            }
        }
        
        await fetchTask?.value
    }

    // MARK: - refreshList

    func refreshList() async {
        print("🔄 SafetyInspection refreshing list...")
        fetchTask?.cancel()
        // Refresh without changing the filter, just reset pagination
        await loadData(reset: true)
    }

    // MARK: - Load More

    func loadMoreItems() async {
        guard hasMorePages, !isLoading, !isLoadingMore else { return }
        // Draft filter does not support load more pagination
        guard currentFilter != .draft else { return }
        
        isLoadingMore = true
        print("📥 SafetyInspection loading page: \(currentPage)")
        
        do {
            let isClosedValue = self.currentFilter.isClosedValue
            
            // API Request (Next Page)
            let apiList = try await APIService.getSafetyInspectionList(
                swac: swacNumber,
                page: currentPage,
                pageSize: pageSize,
                isClosed: isClosedValue
            )
            
            guard !Task.isCancelled else { return }
            
            let nextItems = apiList.map {
                SafetyInspectionItem(from: $0, swacNumber: self.swacNumber)
            }
            
            if !nextItems.isEmpty {
                self.safetyInspectionItemList.append(contentsOf: nextItems)
                
                self.currentPage += 1
                self.hasMorePages = apiList.count >= pageSize
                print("✅ SafetyInspection loaded \(nextItems.count) items. Next page: \(currentPage)")
            } else {
                self.hasMorePages = false
                print("🏁 SafetyInspection no more items.")
            }
            
        } catch {
            if Task.isCancelled { return }
            print("❌ loadMoreItems error:", error)
        }
        
        isLoadingMore = false
    }

    // MARK: - Helper
    func hasReachedEnd(of item: SafetyInspectionItem) -> Bool {
        return item.id == safetyInspectionItemList.last?.id
    }
    
    /// Cancels the currently running fetch task if any.
    func cancelCurrentTask() {
        fetchTask?.cancel()
        fetchTask = nil
    }
}
