//
//  HomeSelectSWACViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 5/12/2025.
//

import SwiftUI
import Combine

@MainActor
class HomeSelectSWACViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var swacList: [SWACListItem] = []
    @Published var searchText: String = ""
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    // Debounced search text for internal use
    @Published private var debouncedSearchText: String = ""
    
    // MARK: - Computed Properties
    
    /// Check if search is active
    var isSearchActive: Bool {
        !debouncedSearchText.isEmpty
    }
    
    // MARK: - Private Properties
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    private var fetchTask: Task<Void, Never>?
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupSearchDebounce()
        setupSearchTriggers()
    }
    
    // MARK: - Setup Methods
    
    /// Configure debounce for search text input
    /// Delays search execution by 500ms after user stops typing
    private func setupSearchDebounce() {
        $searchText
            .debounce(for: .milliseconds(500), scheduler: DispatchQueue.main)
            .removeDuplicates()
            .sink { [weak self] newValue in
                self?.debouncedSearchText = newValue
            }
            .store(in: &cancellables)
    }
    
    /// Configure automatic search triggers
    /// Triggers search when debounced text changes
    private func setupSearchTriggers() {
        $debouncedSearchText
            .dropFirst() // Skip initial value
            .sink { [weak self] searchText in
                guard let self = self else { return }
                
                Task { @MainActor in
                    print("🔍 Bottom Sheet Search: '\(searchText)'")
                    await self.fetchSWACList(reset: true)
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Returns true if the specified item is the last one in the current list
    func hasReachedEnd(of item: SWACListItem) -> Bool {
        return swacList.last?.id == item.id
    }
    
    /// Clear search text
    func clearSearch() {
        searchText = ""
    }
    
    /// Fetch SWAC list (used for initial load and refresh)
    /// - Parameter reset: If true, resets pagination and clears existing data
    func fetchSWACList(reset: Bool = false) async {
        guard !isLoading else { return }
        
        if !reset && !hasMorePages {
            return
        }
        
        if reset {
            fetchTask?.cancel()
        }
        
        isLoading = true
        defer { isLoading = false }
        
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
                
                guard !Task.isCancelled else {
                    print("⚠️ Bottom Sheet fetch task was cancelled")
                    return
                }
                
                let newItems = responseList.map { SWACListItem(from: $0) }
                
                hasMorePages = newItems.count >= pageSize
                
                if reset {
                    self.swacList = newItems
                } else {
                    self.swacList.append(contentsOf: newItems)
                }
                
                if !newItems.isEmpty {
                    currentPage += 1
                }
                
                print("✅ Bottom Sheet fetched \(newItems.count) SWAC items, page: \(currentPage - 1), total: \(swacList.count)")
                
            } catch {
                handleFetchError(error)
            }
        }
        
        await fetchTask?.value
    }
    
    /// Load more SWAC items (pagination)
    func loadMoreItems() async {
        guard hasMorePages && !isLoading && !isLoadingMore else {
            print("⚠️ Bottom Sheet cannot load more: hasMore=\(hasMorePages), isLoading=\(isLoading), isLoadingMore=\(isLoadingMore)")
            return
        }
        
        print("📥 Bottom Sheet loading more items, current page: \(currentPage)")
        isLoadingMore = true
        defer { isLoadingMore = false }
        
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
                print("⚠️ Bottom Sheet load more task was cancelled")
                return
            }
            
            let newItems = responseList.map { SWACListItem(from: $0) }
            
            if !newItems.isEmpty {
                swacList.append(contentsOf: newItems)
                hasMorePages = newItems.count >= pageSize
                currentPage += 1
                print("✅ Bottom Sheet loaded page \(currentPage - 1): \(newItems.count) items, total: \(swacList.count)")
            } else {
                hasMorePages = false
                print("🏁 Bottom Sheet no more items to load")
            }
        } catch {
            handleFetchError(error)
        }
    }
    
    /// Pull-to-refresh action
    func refreshList() async {
        print("🔄 Bottom Sheet refreshing list...")
        fetchTask?.cancel()
        currentPage = 1
        hasMorePages = true
        await fetchSWACList(reset: true)
    }
    
    /// Reset all state (called when sheet is dismissed)
    func reset() {
        fetchTask?.cancel()
        currentPage = 1
        hasMorePages = true
        swacList = []
        clearSearch()
        print("🔄 Bottom Sheet state reset")
    }
    
    /// Cancel current fetch task
    func cancelCurrentTask() {
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    // MARK: - Private Helper Methods
    
    /// Handle fetch errors
    private func handleFetchError(_ error: Error) {
        if let urlError = error as? URLError, urlError.code == .cancelled {
            print("⚠️ Bottom Sheet request was cancelled")
            return
        }
        
        if error is CancellationError {
            print("⚠️ Bottom Sheet task was cancelled")
            return
        }
        
        print("❌ Bottom Sheet fetch SWAC list error:", error)
        hasMorePages = false
    }
    
    // MARK: - Deinit
    deinit {
        fetchTask?.cancel()
        cancellables.removeAll()
        print("🗑️ HomeSelectSWACViewModel deinitialized")
    }
}
