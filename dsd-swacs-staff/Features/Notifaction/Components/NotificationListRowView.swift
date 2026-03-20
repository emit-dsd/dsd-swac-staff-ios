//
//  NotificationListRowView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

struct NotificationListRowView: View {
    let item: NotificationItem
    let isExpanded: Bool
    let onTap: () -> Void
    let onMarkAsRead: () async -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Main notification card
            NotificationView(item: item)
                .onTapGesture {
                    onTap()
                }
            
            if isExpanded {
                NotificationDetailView(
                    item: item,
                    onMarkAsRead: onMarkAsRead,
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        NotificationListRowView(
            item: NotificationItem(
                id: 1,
                topic: "Attendance 97",
                content: "Missing worker 97. Please check the attendance record and update accordingly.",
                isRead: false,
                sender: "administrator",
                sentTime: Date().addingTimeInterval(-300)
            ),
            isExpanded: false,
            onTap: { print("Tapped") },
            onMarkAsRead: {print("onMarkAsRead") }
        )
        
        NotificationListRowView(
            item: NotificationItem(
                id: 2,
                topic: "Attendance 96",
                content: "Missing worker 96. Please verify and submit the report.",
                isRead: false,
                sender: "administrator",
                sentTime: Date().addingTimeInterval(-3600)
            ),
            isExpanded: true,
            onTap: { print("Tapped") },
            onMarkAsRead: {print("onMarkAsRead") }
        )
        NotificationListRowView(
            item: NotificationItem(
                id: 2,
                topic: "Attendance 98",
                content: "Missing worker 98. Please verify and submit the report.",
                isRead: true,
                sender: "administrator",
                sentTime: Date().addingTimeInterval(-3600)
            ),
            isExpanded: true,
            onTap: { print("Tapped") },
            onMarkAsRead: {print("onMarkAsRead") }
        )
    }
    .padding()
}
#endif
