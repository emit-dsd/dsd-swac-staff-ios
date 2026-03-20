//
//  SiteDiaryListViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import Foundation
import Combine

@MainActor
class SiteDiaryListViewModel: ObservableObject {
    
    @Published var swacDetail: SWACDetail?
    @Published var diaries: [SiteDiary] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var isRefreshing = false
    @Published var hasMorePages = true
    
    @Published var startDate: Date?
    @Published var endDate: Date?
    @Published var selectedState: Int?
    
    @Published var searchText: String = ""
    @Published private var debouncedSearchText: String = ""
    private var cancellables = Set<AnyCancellable>()
    
    let swacNumber: String
    
    private var currentPage = 1
    private let pageSize = 20
    private var fetchTask: Task<Void, Never>?
    private var loadMoreTask: Task<Void, Never>?
    
    init(swacNumber: String) {
        self.swacNumber = swacNumber
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
                    await self?.refreshList()
                }
            }
            .store(in: &cancellables)
    }
    
    // MARK: - Computed Properties
    
    /// Check if date range filter is active
    var isDateFilterActive: Bool {
        return startDate != nil && endDate != nil
    }
    
    /// Check if state filter is active
    var isStateFilterActive: Bool {
        return selectedState != nil
    }
    
    // MARK: - Public Methods
    
    /// Check if the specified item is the last one in the current list
    func hasReachedEnd(of diary: SiteDiary) -> Bool {
        return diaries.last?.id == diary.id
    }
    
    /// Apply state filter (clear date filter)
    func applyStateFilter(state: Int?) async {
        self.startDate = nil
        self.endDate = nil
        self.selectedState = state
        
        await refreshList()
    }
    
    /// Apply date range filter (clear state filter)
    func applyDateFilter(startDate: Date?, endDate: Date?) async {
        self.selectedState = nil
        self.startDate = startDate
        self.endDate = endDate
        
        await refreshList()
    }
    
    /// Clear all filters
    func clearAllFilters() async {
        self.startDate = nil
        self.endDate = nil
        self.selectedState = nil
        
        await refreshList()
    }
    
    /// Initial data load (SWAC + Site Diary List)
    func loadData() async {
        guard !isLoading else { return }
        
        fetchTask?.cancel()
        
        isLoading = true
        defer { isLoading = false }
        
        fetchTask = Task {
            do {
                try Task.checkCancellation()
                
                let searchWorkActivity = debouncedSearchText.isEmpty ? nil : debouncedSearchText
                
                // Fetch SWAC detail and diaries in parallel
                async let swacResponse = APIService.fetchSWACProfile(swacNumber: swacNumber)
                async let diariesResponse = APIService.getSiteDiaryList(
                    swac: swacNumber,
                    page: 1,
                    pageSize: pageSize,
                    startDate: startDate?.toAPIDateString(),
                    endDate: endDate?.toAPIDateString(),
                    states: selectedState != nil ? [selectedState!] : nil,
                    workActivity: searchWorkActivity
                )
                
                let (swac, diaryList) = try await (swacResponse, diariesResponse)
                
                try Task.checkCancellation()
                
                self.swacDetail = SWACDetail(from: swac)
                self.diaries = diaryList.map { SiteDiary(from: $0) }
                self.currentPage = 1
                self.hasMorePages = diaryList.count >= pageSize
                
                print("✅ Loaded \(diaryList.count) diaries, page: 1, total: \(self.diaries.count)")
                
            } catch is CancellationError {
                print("⚠️ loadData cancelled")
            } catch {
                print("❌ loadData error:", error)
                self.hasMorePages = false
            }
        }
        
        await fetchTask?.value
    }
    
    /// Refresh list (reset to first page)
    func refreshList() async {
        guard !isRefreshing else { return }
        
        print("🔄 Refreshing diary list...")
        
        fetchTask?.cancel()
        loadMoreTask?.cancel()
        
        isRefreshing = true
        currentPage = 1
        hasMorePages = true
        defer { isRefreshing = false }
        
        fetchTask = Task {
            do {
                try Task.checkCancellation()
                
                let searchWorkActivity = debouncedSearchText.isEmpty ? nil : debouncedSearchText
                
                let diaryList = try await APIService.getSiteDiaryList(
                    swac: swacNumber,
                    page: 1,
                    pageSize: pageSize,
                    startDate: startDate?.toAPIDateString(),
                    endDate: endDate?.toAPIDateString(),
                    states: selectedState != nil ? [selectedState!] : nil,
                    workActivity: searchWorkActivity
                )
                
                try Task.checkCancellation()
                
                self.diaries = diaryList.map { SiteDiary(from: $0) }
                self.currentPage = 1
                self.hasMorePages = diaryList.count >= pageSize
                
                print("✅ Refreshed \(diaryList.count) diaries, total: \(self.diaries.count)")
                
            } catch is CancellationError {
                print("⚠️ refreshList cancelled")
            } catch {
                handleFetchError(error)
            }
        }
        
        await fetchTask?.value
    }
    
    /// Load more items (pagination)
    func loadMoreItems() async {
        guard hasMorePages && !isLoading && !isLoadingMore else {
            print("⚠️ Cannot load more: hasMore=\(hasMorePages), isLoading=\(isLoading), isLoadingMore=\(isLoadingMore)")
            return
        }
        
        print("📥 Loading more items, current page: \(currentPage)")
        
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        let nextPage = currentPage + 1
        
        loadMoreTask = Task {
            do {
                try Task.checkCancellation()
                
                let searchWorkActivity = debouncedSearchText.isEmpty ? nil : debouncedSearchText
                
                let diaryList = try await APIService.getSiteDiaryList(
                    swac: swacNumber,
                    page: nextPage,
                    pageSize: pageSize,
                    startDate: startDate?.toAPIDateString(),
                    endDate: endDate?.toAPIDateString(),
                    states: selectedState != nil ? [selectedState!] : nil,
                    workActivity: searchWorkActivity
                )
                
                try Task.checkCancellation()
                
                if diaryList.isEmpty {
                    hasMorePages = false
                    print("🏁 No more items to load")
                } else {
                    let newDiaries = diaryList.map { SiteDiary(from: $0) }
                    self.diaries.append(contentsOf: newDiaries)
                    self.currentPage = nextPage
                    self.hasMorePages = diaryList.count >= pageSize
                    
                    print("✅ Loaded page \(nextPage): \(newDiaries.count) items, total: \(self.diaries.count), hasMore: \(hasMorePages)")
                }
                
            } catch is CancellationError {
                print("⚠️ loadMoreItems cancelled")
            } catch {
                handleFetchError(error)
            }
        }
        
        await loadMoreTask?.value
    }
    
    // MARK: - Private Helper Methods
    
    private func handleFetchError(_ error: Error) {
        if let urlError = error as? URLError, urlError.code == .cancelled {
            print("⚠️ Request was cancelled")
            return
        }
        
        if error is CancellationError {
            print("⚠️ Task was cancelled")
            return
        }
        
        print("❌ Fetch diary list error:", error)
        hasMorePages = false
    }
    
    // MARK: - Deinit
    
    deinit {
        fetchTask?.cancel()
        loadMoreTask?.cancel()
        fetchTask = nil
        loadMoreTask = nil
        cancellables.removeAll()
    }
}
