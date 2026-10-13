//
//  SWACViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/11/2025.
//

import Foundation
import Combine

@MainActor
class SWACViewModel: ObservableObject {
    
    enum SWACStatusFilter: CaseIterable {
        case approval
        case endorsement
        case reject
        case safetyVetting
        
        var localizationKey: String {
            switch self {
            case .approval:
                return "swac_status_label_cswr_approve"
            case .endorsement:
                return "swac_status_label_cswr_endorse"
            case .reject:
                return "swac_status_label_cswr_reject"
            case .safetyVetting:
                return "swac_status_label_vetting"
            }
        }

        var actionTitleKey: String? {
            switch self {
            case .approval:
                return "today_swac_button_approve_entry"
            case .endorsement:
                return "today_swac_button_endorse_registration"
            case .reject:
                return "today_swac_button_reject"
            case .safetyVetting:
                return nil
            }
        }
    }
    
    @Published var selectedStatus: SWACStatusFilter? = nil
    @Published var swacList: [SWACListItem] = []
    @Published var searchText: String = ""
    @Published var startDate: Date?
    @Published var finishDate: Date?
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    // Debounced search text for internal use
    @Published private var debouncedSearchText: String = ""
    
    // MARK: - Computed Properties
    
    /// Check if any search criteria is active
    var isSearchActive: Bool {
        !debouncedSearchText.isEmpty || startDate != nil || finishDate != nil
    }
    
    /// Check if should show empty prompt (no filter selected and no search)
    var shouldShowEmptyPrompt: Bool {
        selectedStatus == nil && !isSearchActive && swacList.isEmpty && !isLoading
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
    /// Triggers search when debounced text or date filters change
    private func setupSearchTriggers() {
        Publishers.CombineLatest3(
            $debouncedSearchText,
            $startDate,
            $finishDate
        )
        .dropFirst() // Skip initial values
        .sink { [weak self] searchText, startDate, finishDate in
            guard let self = self else { return }
            
            Task { @MainActor in
                print("🔍 Search criteria changed: text='\(searchText)', start=\(startDate?.description ?? "nil"), finish=\(finishDate?.description ?? "nil")")
                await self.fetchSWACList(reset: true)
            }
        }
        .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    
    /// Check if the specified item is the last one in the current list
    /// Used to trigger pagination when scrolling reaches the end
    func hasReachedEnd(of item: SWACListItem) -> Bool {
        return swacList.last?.id == item.id
    }
    
    /// Fetch SWAC list (used for initial load and refresh)
    /// - Parameter reset: If true, resets pagination and clears existing data
    func fetchSWACList(reset: Bool = false) async {
        // Don't fetch if no filter selected and no search active
        guard selectedStatus != nil || isSearchActive else {
            print("⚠️ No filter selected and no search active, skipping fetch")
            return
        }
        
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
                let newItems: [SWACListItem]
                
                if isSearchActive {
                    let request = buildSearchRequest()
                    let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
                    newItems = responseList.map { SWACListItem(from: $0) }
                } else if let selectedStatus {
                    let responseList: [SiteWorkProfileResponse]
                    switch selectedStatus {
                    case .approval:
                        responseList = try await APIService.getApprovalList(page: currentPage, pageSize: pageSize)
                    case .endorsement:
                        responseList = try await APIService.getEndorsementList(page: currentPage, pageSize: pageSize)
                    case .reject:
                        responseList = try await APIService.getRejectList(page: currentPage, pageSize: pageSize)
                    case .safetyVetting:
                        responseList = []
                    }
                    if selectedStatus == .safetyVetting {
                        let safetyVettingItems = try await APIService.getSafetyVettingList(page: currentPage, pageSize: pageSize)
                        newItems = safetyVettingItems.map { SWACListItem(from: $0) }
                    } else {
                        newItems = responseList.map { SWACListItem(from: $0) }
                    }
                } else {
                    newItems = []
                }
                
                guard !Task.isCancelled else {
                    print("⚠️ Fetch task was cancelled")
                    return
                }
                
                hasMorePages = newItems.count >= pageSize
                
                if reset {
                    self.swacList = newItems
                } else {
                    self.swacList.append(contentsOf: newItems)
                }
                
                if !newItems.isEmpty {
                    currentPage += 1
                }
                
                print("✅ Fetched \(newItems.count) SWAC items, page: \(currentPage - 1), total: \(swacList.count)")
                
            } catch {
                handleFetchError(error)
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
        
        await fetchTask?.value
    }
    
    /// Load more SWAC items (pagination)
    /// Used by infinite scroll when reaching the end of the list
    func loadMoreItems() async {
        guard hasMorePages && !isLoading && !isLoadingMore else {
            print("⚠️ Cannot load more: hasMore=\(hasMorePages), isLoading=\(isLoading), isLoadingMore=\(isLoadingMore)")
            return
        }
        
        print("📥 Loading more items, current page: \(currentPage)")
        isLoadingMore = true
        defer { isLoadingMore = false }
        
        do {
            let newItems: [SWACListItem]
            
            if isSearchActive {
                let request = buildSearchRequest()
                let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
                newItems = responseList.map { SWACListItem(from: $0) }
            } else if let selectedStatus {
                let responseList: [SiteWorkProfileResponse]
                switch selectedStatus {
                case .approval:
                    responseList = try await APIService.getApprovalList(page: currentPage, pageSize: pageSize)
                case .endorsement:
                    responseList = try await APIService.getEndorsementList(page: currentPage, pageSize: pageSize)
                case .reject:
                    responseList = try await APIService.getRejectList(page: currentPage, pageSize: pageSize)
                case .safetyVetting:
                    responseList = []
                }
                if selectedStatus == .safetyVetting {
                    let safetyVettingItems = try await APIService.getSafetyVettingList(page: currentPage, pageSize: pageSize)
                    newItems = safetyVettingItems.map { SWACListItem(from: $0) }
                } else {
                    newItems = responseList.map { SWACListItem(from: $0) }
                }
            } else {
                newItems = []
            }
            
            guard !Task.isCancelled else {
                print("⚠️ Load more task was cancelled")
                return
            }
            
            if !newItems.isEmpty {
                swacList.append(contentsOf: newItems)
                hasMorePages = newItems.count >= pageSize
                currentPage += 1
                print("✅ Loaded page \(currentPage - 1): \(newItems.count) items, total: \(swacList.count), hasMore: \(hasMorePages)")
            } else {
                hasMorePages = false
                print("🏁 No more items to load")
            }
        } catch {
            handleFetchError(error)
        }
    }
    
    /// Pull-to-refresh action
    /// Resets state and reloads data from the server
    func refreshList() async {
        print("🔄 Refreshing list...")
        fetchTask?.cancel()
        currentPage = 1
        hasMorePages = true
        await fetchSWACList(reset: true)
    }
    
    /// Clear all search filters and return to normal list mode
    func clearSearch() {
        searchText = ""
        startDate = nil
        finishDate = nil
    }
    
    /// Cancel the currently running fetch task
    func cancelCurrentTask() {
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    func approveEntry(item: SWACListItem) async {
        do {
            let entryId = item.siteWorkID
            let _ = try await APIService.cswrApproveEntry(entryId: entryId)

            await refreshList()
        } catch {
            print("❌ Approve entry failed: \(error)")
        }
    }

    func endorseRegistration(item: SWACListItem) async {
        do {
            try await APIService.cswrEndorseRegistration(entryId: item.siteWorkID)
            await refreshList()
        } catch {
            print("❌ Endorse registration failed: \(error)")
        }
    }

    func rejectEntry(item: SWACListItem) async {
        do {
            let entryId = item.siteWorkID
            let _ = try await APIService.cswrRejectEntry(entryId: entryId)

            await refreshList()
        } catch {
            print("❌ Reject entry failed: \(error)")
        }
    }

    // MARK: - Private Helper Methods
    
    /// Build search request based on current filter and search state
    private func buildSearchRequest() -> SwacSearchRequest {
        var stateValue: Int? = nil
        var isSiteWorkRegistered: Bool? = nil
        var numberValue: String? = nil
        
        // Priority: Search > Filter
        if isSearchActive {
            // When searching, use search text as number
            numberValue = debouncedSearchText.isEmpty ? nil : debouncedSearchText
        } else if let status = selectedStatus {
            // Apply filter parameters
            switch status {
            case .approval, .endorsement, .reject:
                isSiteWorkRegistered = true
            case .safetyVetting:
                stateValue = 3
            }
        }
        
        return SwacSearchRequest(
            page: currentPage,
            pageSize: pageSize,
            state: stateValue,
            number: numberValue,
            startDate: startDate?.toAPIDateString(),
            finishDate: finishDate?.toAPIDateString(),
            isSiteWorkRegistered: isSiteWorkRegistered
        )
    }
    
    /// Handle fetch errors
    private func handleFetchError(_ error: Error) {
        if let urlError = error as? URLError, urlError.code == .cancelled {
            print("⚠️ Request was cancelled (this is normal when switching filters)")
            return
        }
        
        if error is CancellationError {
            print("⚠️ Task was cancelled")
            return
        }
        
        print("❌ Fetch SWAC list error:", error)
        hasMorePages = false
    }
    
    // MARK: - Deinit
    deinit {
        fetchTask?.cancel()
        cancellables.removeAll()
    }
}
