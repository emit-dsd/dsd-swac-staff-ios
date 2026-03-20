//
//  SafetyInspectionMainViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 20/11/2025.
//

import Foundation
import Combine

@MainActor
class SafetyInspectionMainViewModel: ObservableObject {
    @Published var swacList: [SWACListItem] = []
    
    // UI Loading States
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    // Search States
    @Published var searchText: String = ""
    @Published private var debouncedSearchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    // Pagination state
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    
    private var fetchTask: Task<Void, Never>?
    
    init() {
        print("SafetyInspectionMainViewModel initialized")
        setupSearchDebounce()
    }
    
    // MARK: - Setup Search Debounce
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                self?.debouncedSearchText = newValue
            }
            .store(in: &cancellables)
        
        $debouncedSearchText
            .dropFirst()
            .sink { [weak self] _ in
                Task { @MainActor [weak self] in
                    await self?.fetchSWACList(reset: true)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Returns true if the specified item is the last one in the current list.
    func hasReachedEnd(of item: SWACListItem) -> Bool {
        return swacList.last?.id == item.id
    }
    
    /// Fetch the SWAC list (used for initial load and refresh).
    /// - Parameter reset: Reset pagination and data if true; load next page if false.
    func fetchSWACList(reset: Bool = false) async {
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
        defer { isLoading = false }
        
        // Reset pagination state if needed
        if reset {
            currentPage = 1
            hasMorePages = true
        }
        
        fetchTask = Task {
            do {
                let request = SwacSearchRequest(
                    page: currentPage,
                    pageSize: pageSize,
                    state: 5,
                    number: debouncedSearchText.isEmpty ? nil : debouncedSearchText,
                    startDate: nil,
                    finishDate: nil,
                    isSiteWorkRegistered: nil
                )
                
                let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
                
                // Ignore results if this task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Safety fetch task was cancelled")
                    return
                }
                
                let newItems = responseList.map { SWACListItem(from: $0) }
                
                // Update pagination flags
                hasMorePages = newItems.count >= pageSize
                
                // On reset, replace entire list; otherwise append
                if reset {
                    self.swacList = newItems
                } else {
                    self.swacList.append(contentsOf: newItems)
                }
                
                // Increment page only if got data
                if !newItems.isEmpty {
                    currentPage += 1
                }
                
                print("✅ Safety fetched \(newItems.count) SWAC items, page: \(currentPage - 1), total: \(swacList.count)")
                
            } catch {
                // Gracefully ignore expected cancel/cancellation errors
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    print("⚠️ Safety request was cancelled (normal when switching views)")
                    return
                }
                
                if error is CancellationError {
                    print("⚠️ Safety task was cancelled")
                    return
                }
                
                print("❌ Safety fetch SWAC list error:", error)
                hasMorePages = false
            }
        }
        
        await fetchTask?.value
    }
    
    /// Load more SWAC items (pagination). Used by infinite scroll.
    func loadMoreItems() async {
        guard hasMorePages && !isLoading && !isLoadingMore else {
            print("⚠️ Safety cannot load more: hasMore=\(hasMorePages), isLoading=\(isLoading), isLoadingMore=\(isLoadingMore)")
            return
        }
        
        print("📥 Safety loading more items, current page: \(currentPage)")
        isLoadingMore = true
        
        do {
            let request = SwacSearchRequest(
                page: currentPage,
                pageSize: pageSize,
                state: 5,
                number: debouncedSearchText.isEmpty ? nil : debouncedSearchText,
                startDate: nil,
                finishDate: nil,
                isSiteWorkRegistered: nil
            )
            
            let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
            
            guard !Task.isCancelled else {
                print("⚠️ Safety load more task was cancelled")
                return
            }
            
            let newItems = responseList.map { SWACListItem(from: $0) }
            
            if !newItems.isEmpty {
                swacList.append(contentsOf: newItems)
                hasMorePages = newItems.count >= pageSize
                currentPage += 1
                print("✅ Safety loaded page \(currentPage - 1): \(newItems.count) items, total: \(swacList.count), hasMore: \(hasMorePages)")
            } else {
                hasMorePages = false
                print("🏁 Safety no more items to load")
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ Safety request was cancelled")
                return
            }
            print("❌ Safety load more error:", error)
        }
        
        isLoadingMore = false
    }
    
    /// Pull-to-refresh action: resets state and reloads list from server.
    func refreshList() async {
        print("🔄 Safety refreshing list...")
        fetchTask?.cancel()
        currentPage = 1
        hasMorePages = true
        await fetchSWACList(reset: true)
    }
    
    /// Cancels the currently running fetch task if any.
    func cancelCurrentTask() {
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    deinit {
        fetchTask?.cancel()
        cancellables.removeAll()
    }
}
