//
//  NotificationMainViewModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/11/2025.
//

import Foundation
import SwiftUI

@MainActor
class NotificationMainViewModel: ObservableObject {
    @Published var notifications: [NotificationItem] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var hasMorePages = true
    
    @Published var startDate: Date?
    @Published var endDate: Date?
    
    private var currentPage = 1
    private let pageSize = 20
    
    // MARK: - Computed Properties
    
    var totalCount: Int {
        notifications.count
    }
    
    var unreadCount: Int {
        notifications.filter { !$0.isRead }.count
    }
    
    var filteredNotifications: [NotificationItem] {
        var filtered = notifications
        
        if let start = startDate, let end = endDate {
            filtered = filtered.filter { notification in
                notification.sentTime >= start && notification.sentTime <= end
            }
        }
        
        return filtered
    }
    
    // MARK: - Public Methods
    
    /// Fetch initial notifications
    func fetchNotifications() async {
        guard !isLoading else { return }
        
        isLoading = true
        currentPage = 1
        
        do {
            let responses = try await APIService.getNotificationList(
                page: currentPage,
                pageSize: pageSize
            )
            
            notifications = responses.toNotificationItems()
            hasMorePages = responses.count >= pageSize
            
            print("✅ Fetched \(notifications.count) notifications")
        } catch {
            handleError(error, operation: "fetching")
        }
        
        isLoading = false
    }
    
    /// Load more notifications (pagination)
    func loadMoreNotifications() async {
        guard !isLoadingMore && !isLoading && hasMorePages else { return }
        
        isLoadingMore = true
        currentPage += 1
        
        do {
            let responses = try await APIService.getNotificationList(
                page: currentPage,
                pageSize: pageSize
            )
            
            if !responses.isEmpty {
                let newItems = responses.toNotificationItems()
                notifications.append(contentsOf: newItems)
                hasMorePages = responses.count >= pageSize
                print("✅ Loaded page \(currentPage), total: \(notifications.count)")
            } else {
                hasMorePages = false
            }
        } catch {
            handleError(error, operation: "loading more")
            currentPage -= 1
        }
        
        isLoadingMore = false
    }
    
    /// Refresh notifications (for pull-to-refresh)
    func refreshNotifications() async {
        await Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                let responses = try await APIService.getNotificationList(
                    page: 1,
                    pageSize: self.pageSize
                )
                
                await MainActor.run {
                    self.currentPage = 1
                    self.notifications = responses.toNotificationItems()
                    self.hasMorePages = responses.count >= self.pageSize
                    print("✅ Refreshed \(self.notifications.count) notifications")
                }
            } catch {
                await self.handleError(error, operation: "refreshing")
            }
        }.value
    }
    
    /// Mark notification as read
    /// - Parameter notification: The notification to mark as read
    func markAsRead(_ notification: NotificationItem) async {
        // If already read, do nothing
        guard !notification.isRead else {
            print("⚠️ Notification \(notification.id) is already read")
             return
         }
         
         do {
             // Call API
             try await APIService.markNotificationAsRead(notification.id)
             
             // Update local state optimistically
             if let index = notifications.firstIndex(where: { $0.id == notification.id }) {
                 var updatedNotification = notification
                 // Since NotificationItem is a struct, create a new one with updated isRead
                 let newNotification = NotificationItem(
                     id: updatedNotification.id,
                     topic: updatedNotification.topic,
                     content: updatedNotification.content,
                     isRead: true,  // Mark as read
                     sender: updatedNotification.sender,
                     sentTime: updatedNotification.sentTime
                 )
                 notifications[index] = newNotification
             }
             
             print("✅ Marked notification \(notification.id) as read")
         } catch {
             print("❌ Failed to mark notification as read: \(error)")
         }
     }
    
    /// Apply date filter
    func applyDateFilter(start: Date, end: Date) {
        startDate = start
        endDate = end
        print("📅 Applied date filter: \(start) to \(end)")
    }
    
    /// Clear date filter
    func clearDateFilter() {
        startDate = nil
        endDate = nil
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
        
        // Log real errors (but don't show to user)
        print("❌ Error during \(operation): \(error)")
    }
}
