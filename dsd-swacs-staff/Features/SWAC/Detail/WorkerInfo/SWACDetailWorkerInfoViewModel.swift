//
//  SWACDetailWorkerInfoViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 10/11/2025.
//

import Foundation
import Combine
import SwiftUI

@MainActor
class SWACDetailWorkerInfoViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var workerInfo: WorkingTeamMemberResponse?
    @Published var attendanceRecords: [Attendance] = []
    @Published var isLoadingWorkerInfo = false
    @Published var isLoadingRecords = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    @Published var hasMorePages = true
    
    // MARK: - Private Properties
    private var currentPage = 1
    private let pageSize = 20
    
    private var workerInfoTask: Task<Void, Never>?
    private var attendanceTask: Task<Void, Never>?
    
    let memberID: Int
    let memberName: String
    
    // MARK: - Computed Properties
    
    var canMakePhoneCall: Bool {
        workerInfo?.phone != nil && !isLoadingWorkerInfo
    }
    
    var phoneNumber: String {
        workerInfo?.phone ?? "-"
    }
    
    // MARK: - Initialization
    
    init(memberID: Int, memberName: String) {
        self.memberID = memberID
        self.memberName = memberName
    }
    
    // MARK: - Public Methods
    
    /// Fetch initial worker info and attendance records
    func loadInitialData() async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.fetchWorkerInfo() }
            group.addTask { await self.fetchAttendanceRecords() }
        }
    }
    
    /// Refresh all data (for pull-to-refresh)
    func refreshData() async {
        // Cancel previous tasks
        attendanceTask?.cancel()
        
        await Task.detached { [weak self] in
            guard let self = self else { return }
            
            await MainActor.run {
                self.currentPage = 1
                self.hasMorePages = true
            }
            
            await self.fetchAttendanceRecords()
        }.value
    }
    
    /// Load more attendance records (pagination)
    func loadMoreRecords() async {
        guard hasMorePages && !isLoadingRecords && !isLoadingMore else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let responses = try await APIService.getAttendanceMember(
                memberID: memberID,
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
            handleError(error, operation: "loading more records")
            currentPage -= 1
        }
        
        isLoadingMore = false
    }
    
    /// Make phone call to worker
    func makePhoneCall() {
        guard let phone = workerInfo?.phone else { return }
        
        let cleanedPhone = phone
            .replacingOccurrences(of: " ", with: "")
            .replacingOccurrences(of: "-", with: "")
            .replacingOccurrences(of: "(", with: "")
            .replacingOccurrences(of: ")", with: "")
        
        guard let url = URL(string: "tel://\(cleanedPhone)"),
              UIApplication.shared.canOpenURL(url) else {
            print("❌ Invalid phone number: \(phone)")
            return
        }
        
        UIApplication.shared.open(url) { success in
            if success {
                print("✅ Phone call initiated: \(cleanedPhone)")
            } else {
                print("❌ Failed to open phone app")
            }
        }
    }
    
    // MARK: - Private Methods
    
    /// Fetch worker information
    private func fetchWorkerInfo() async {
        guard !isLoadingWorkerInfo else { return }
        
        // Cancel previous task
        workerInfoTask?.cancel()
        
        isLoadingWorkerInfo = true
        errorMessage = nil
        
        workerInfoTask = Task {
            do {
                let info = try await APIService.getWorkingTeamMember(memberID: memberID)
                
                // Check if task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Worker info fetch was cancelled")
                    return
                }
                
                await MainActor.run {
                    self.workerInfo = info
                    print("✅ Fetched worker info for member \(memberID)")
                }
            } catch {
                await handleError(error, operation: "fetching worker info")
            }
            
            await MainActor.run {
                self.isLoadingWorkerInfo = false
            }
        }
        
        await workerInfoTask?.value
    }
    
    /// Fetch initial attendance records
    private func fetchAttendanceRecords() async {
        guard !isLoadingRecords else { return }
        
        attendanceTask?.cancel()
        
        isLoadingRecords = true
        currentPage = 1
        errorMessage = nil
        
        attendanceTask = Task {
            do {
                let responses = try await APIService.getAttendanceMember(
                    memberID: memberID,
                    page: currentPage,
                    pageSize: pageSize
                )
                
                // Check if task was cancelled
                guard !Task.isCancelled else {
                    print("⚠️ Attendance fetch was cancelled")
                    return
                }
                
                let records = responses.map { Attendance(from: $0) }
                
                await MainActor.run {
                    self.attendanceRecords = records
                    self.hasMorePages = responses.count >= pageSize
                    print("✅ Fetched \(records.count) attendance records")
                }
            } catch {
                await handleError(error, operation: "fetching attendance records")
            }
            
            await MainActor.run {
                self.isLoadingRecords = false
            }
        }
        
        await attendanceTask?.value
    }
    
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
    
    /// Cancel current tasks
    func cancelCurrentTasks() {
        workerInfoTask?.cancel()
        attendanceTask?.cancel()
        workerInfoTask = nil
        attendanceTask = nil
    }
    
    deinit {
        workerInfoTask?.cancel()
        attendanceTask?.cancel()
    }
}
