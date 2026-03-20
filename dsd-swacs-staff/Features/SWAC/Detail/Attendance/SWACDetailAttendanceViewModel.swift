//
//  SWACDetailAttendanceViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/11/2025.
//

import Foundation
import Combine

@MainActor
class SWACDetailAttendanceViewModel: ObservableObject {
    @Published var attendanceRecords: [Attendance] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    
    let swacNumber: String
    @Published var selectedDate: Date
    
    private var currentPage = 1
    private let pageSize = 20
    
    private var currentTask: Task<Void, Never>?
    
    init(swacNumber: String, selectedDate: Date = Date()) {
        self.swacNumber = swacNumber
        self.selectedDate = selectedDate
    }
    
    var totalCount: Int {
        attendanceRecords.count
    }
    
    var memberTotalCount: Int {
        Set(attendanceRecords.map { $0.memberID }).count
    }
    
    var signedOutMemberCount: Int {
        let grouped = Dictionary(grouping: attendanceRecords, by: { $0.memberID })
        
        return grouped.values.filter { records in
            records.allSatisfy { $0.signOut != nil }
        }.count
    }
    
    // MARK: - Public Methods
    /// Fetch initial attendance records
    func fetchAttendanceRecords() async {
        guard !isLoading else { return }
        
        // Cancel previous task
        currentTask?.cancel()
        
        isLoading = true
        currentPage = 1
        errorMessage = nil
        
        currentTask = Task {
            do {
                let responses = try await APIService.attendanceList(
                    swac: swacNumber,
                    date: selectedDate,
                    page: currentPage,
                    pageSize: pageSize
                )
                
                // Check if task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Attendance fetch task was cancelled")
                    return
                }
                
                let records = responses.map { Attendance(from: $0) }
                self.attendanceRecords = records
                self.hasMorePages = responses.count >= pageSize
                
                print("✅ Fetched \(records.count) attendance records")
                
            } catch {
                handleError(error, operation: "fetching")
            }
            
            await MainActor.run {
                self.isLoading = false
            }
        }
        
        await currentTask?.value
    }
    
    /// Load more attendance records (pagination)
    func loadMoreRecords() async {
        guard !isLoadingMore && !isLoading && hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let responses = try await APIService.attendanceList(
                swac: swacNumber,
                date: selectedDate,
                page: currentPage,
                pageSize: pageSize
            )
            
            // Check if task was cancelled
            guard !Task.isCancelled else {
                print("⚠️ Load more task was cancelled")
                currentPage -= 1
                return
            }
            
            if !responses.isEmpty {
                let newRecords = responses.map { Attendance(from: $0) }
                attendanceRecords.append(contentsOf: newRecords)
                hasMorePages = responses.count >= pageSize
                print("✅ Loaded page \(currentPage), total: \(attendanceRecords.count)")
            } else {
                hasMorePages = false
            }
        } catch {
            handleError(error, operation: "loading more")
            currentPage -= 1
        }
        
        isLoadingMore = false
    }
    
    /// Refresh attendance records (for pull-to-refresh)
    func refreshRecords() async {
        // Cancel previous task
        currentTask?.cancel()
        
        await Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                let responses = try await APIService.attendanceList(
                    swac: self.swacNumber,
                    date: self.selectedDate,
                    page: 1,
                    pageSize: self.pageSize
                )
                
                // Check if task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Refresh task was cancelled")
                    return
                }
                
                await MainActor.run {
                    self.currentPage = 1
                    let records = responses.map { Attendance(from: $0) }
                    self.attendanceRecords = records
                    self.hasMorePages = responses.count >= self.pageSize
                    print("✅ Refreshed \(self.attendanceRecords.count) records")
                }
            } catch {
                await self.handleError(error, operation: "refreshing")
            }
        }.value
    }
    
    /// Update selected date
    func updateDate(_ newDate: Date) async {
        // Cancel current task
        currentTask?.cancel()
        
        self.selectedDate = newDate
        await refreshRecords()
    }
    
    // MARK: - Private Methods
    
    /// Handle errors with proper cancellation checking
    private func handleError(_ error: Error, operation: String) {
        // Check for cancellation errors (ignore silently)
        if let urlError = error as? URLError, urlError.code == .cancelled {
            print("⚠️ Request was cancelled during \(operation)")
            return
        }
        
        if error is CancellationError {
            print("⚠️ Task was cancelled during \(operation)")
            return
        }
        
        // Log and show real errors
        let errorMsg = error.localizedDescription
        print("❌ Error during \(operation): \(errorMsg)")
        
        Task { @MainActor in
            self.errorMessage = errorMsg
        }
    }
    
    /// Cancel current task
    func cancelCurrentTask() {
        currentTask?.cancel()
        currentTask = nil
    }
    
    deinit {
        currentTask?.cancel()
    }
}
