//
//  HomeViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 5/11/2025.
//

import SwiftUI

@MainActor
final class HomeViewModel: ObservableObject {
    
    @Published var todaySWACList: [SWACListItem] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    @Published var allSWACList: [SWACListItem] = []
    @Published var isLoadingAll = false
    
    // Pagination state
    private var currentPage: Int = 1
    private let pageSize: Int = 20
    
    private var fetchTask: Task<Void, Never>?
    private var fetchAllTask: Task<Void, Never>?
    
    /// Returns true if the specified item is the last one in the current list.
    func hasReachedEnd(of item: SWACListItem) -> Bool {
        return todaySWACList.last?.id == item.id
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
                    state: nil,
                    number: nil,
                    startDate: nil,
                    finishDate: nil,
                    isSiteWorkRegistered: nil
                )
                
                let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
                
                // Ignore results if this task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Fetch task was cancelled")
                    return
                }
                
                let newItems = responseList.map { SWACListItem(from: $0) }
                
                // Update pagination flags
                hasMorePages = newItems.count >= pageSize
                
                // On reset, replace entire list; otherwise append
                if reset {
                    self.todaySWACList = newItems
                } else {
                    self.todaySWACList.append(contentsOf: newItems)
                }
                
                // Increment page only if got data
                if !newItems.isEmpty {
                    currentPage += 1
                }
                
                print("✅ Fetched \(newItems.count) SWAC items, page: \(currentPage - 1), total: \(todaySWACList.count)")
                
            } catch {
                // Gracefully ignore expected cancel/cancellation errors
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    print("⚠️ Request was cancelled (normal when switching views)")
                    return
                }
                
                if error is CancellationError {
                    print("⚠️ Task was cancelled")
                    return
                }
                
                print("❌ Fetch SWAC list error:", error)
                hasMorePages = false
            }
        }
        
        await fetchTask?.value
    }
    
    /// Load more SWAC items (pagination). Used by infinite scroll.
    func loadMoreItems() async {
        guard hasMorePages && !isLoading && !isLoadingMore else {
            print("⚠️ Cannot load more: hasMore=\(hasMorePages), isLoading=\(isLoading), isLoadingMore=\(isLoadingMore)")
            return
        }
        
        print("📥 Loading more items, current page: \(currentPage)")
        isLoadingMore = true
        
        do {
            let request = SwacSearchRequest(
                page: currentPage,
                pageSize: pageSize,
                state: nil,
                number: nil,
                startDate: nil,
                finishDate: nil,
                isSiteWorkRegistered: nil
            )
            
            let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
            
            guard !Task.isCancelled else {
                print("⚠️ Load more task was cancelled")
                return
            }
            
            let newItems = responseList.map { SWACListItem(from: $0) }
            
            if !newItems.isEmpty {
                todaySWACList.append(contentsOf: newItems)
                hasMorePages = newItems.count >= pageSize
                currentPage += 1
                print("✅ Loaded page \(currentPage - 1): \(newItems.count) items, total: \(todaySWACList.count), hasMore: \(hasMorePages)")
            } else {
                hasMorePages = false
                print("🏁 No more items to load")
            }
        } catch {
            if let urlError = error as? URLError, urlError.code == .cancelled {
                print("⚠️ Request was cancelled")
                return
            }
            print("❌ Load more error:", error)
        }
        
        isLoadingMore = false
    }
    
    /// Pull-to-refresh action: resets state and reloads list from server.
    func refreshList() async {
        print("🔄 Refreshing list...")
        fetchTask?.cancel()
        currentPage = 1
        hasMorePages = true
        await fetchSWACList(reset: true)
    }
    
    /// Fetch ALL SWAC items by loading all pages sequentially.
    /// Used for bottom sheet selection where all items are needed.
    func fetchAllSWACList() async {
        fetchAllTask?.cancel()
        
        guard !isLoadingAll else { return }
        
        fetchAllTask = Task {
            isLoadingAll = true
            defer {
                isLoadingAll = false
            }
            
            print("📥 Starting to fetch all SWAC...")
            
            var allItems: [SWACListItem] = []
            var currentPage = 1
            var hasMore = true
            
            do {
                while hasMore && !Task.isCancelled {
                    print("  📄 Fetching page \(currentPage)...")
                    
                    let request = SwacSearchRequest(
                        page: currentPage,
                        pageSize: pageSize,
                        state: nil,
                        number: nil,
                        startDate: nil,
                        finishDate: nil,
                        isSiteWorkRegistered: nil
                    )
                    
                    let responseList: [SWACListItemResponse] = try await APIService.swacSearch(request: request)
                    let newItems = responseList.map { SWACListItem(from: $0) }
                    
                    allItems.append(contentsOf: newItems)
                    
                    print("  ✅ Page \(currentPage): got \(newItems.count) items. Total: \(allItems.count)")
                    
                    // Check if there are more pages
                    if newItems.count < 20 {
                        hasMore = false
                        print("  🏁 No more pages (got \(newItems.count) < 20)")
                    } else {
                        currentPage += 1
                        // Small delay to avoid overwhelming server
                        try? await Task.sleep(for: .milliseconds(100))
                    }
                }
                
                if !Task.isCancelled {
                    await MainActor.run {
                        self.allSWACList = allItems
                    }
                    print("✅ Loaded all SWAC: \(allItems.count) items in \(currentPage) pages")
                }
                
            } catch {
                if let urlError = error as? URLError, urlError.code == .cancelled {
                    print("⚠️ Fetch all was cancelled")
                    return
                }
                print("❌ Fetch all SWAC list error:", error)
            }
        }
        
        await fetchAllTask?.value
    }
    
    /// Cancel the fetch-all task (e.g., when bottom sheet is dismissed).
    func cancelFetchAll() {
        fetchAllTask?.cancel()
        isLoadingAll = false
    }
    
    /// Cancel the main fetch task.
    func cancelCurrentTask() {
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    // MARK: - Sign In/Out Methods
    
    func signIn(accessCode: String) async -> Result<StaffSignInOutResponse, APIError> {
        do {
            let response = try await APIService.staffSignIn(accessCode: accessCode)
            return .success(response)
        } catch let apiError as APIError {
            return .failure(apiError)
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }
    
    func signOut(accessCode: String) async -> Result<StaffSignInOutResponse, APIError> {
        do {
            let response = try await APIService.staffSignOut(accessCode: accessCode)
            return .success(response)
        } catch let apiError as APIError {
            return .failure(apiError)
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }
    
    func inspectAccessCode(accessCode: String) async -> Result<InspectAccessCodeResponse, APIError> {
        do {
            let response = try await APIService.inspectAccessCode(accessCode: accessCode)
            return .success(response)
        } catch let apiError as APIError {
            return .failure(apiError)
        } catch {
            fatalError("Unexpected error: \(error)")
        }
    }
    
    deinit {
        fetchTask?.cancel()
        fetchAllTask?.cancel()
    }
}
