//
//  NotificationDetailView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

struct NotificationDetailView: View {
    let item: NotificationItem
    let onMarkAsRead: () async -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            InfoRowView(
                title: "notification_label_remark".localized(),
                value: item.content
            )
            
            if !item.isRead {
                HStack(spacing: 8) {
                    CommonButton(
                        title: "notification_button_mark_as_read".localized(),
                        style: .contained,
                        enabled: true,
                        maxWidth: .infinity,
                        action: {
                            Task {
                                await onMarkAsRead()
                            }
                        }
                    )
                }
            }
        }
        .padding(16)
        .background(Color.Neutral200)
        .cornerRadius(8)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        // Unread notification
        NotificationDetailView(
            item: NotificationItem(
                id: 1,
                topic: "Attendance 97",
                content: "Missing worker 97. Please check the attendance record.",
                isRead: false,
                sender: "administrator",
                sentTime: Date()
            ),
            onMarkAsRead: {
                print("Mark as read called")
            }
        )
        
        // Read notification (no button)
        NotificationDetailView(
            item: NotificationItem(
                id: 2,
                topic: "Attendance 96",
                content: "Missing worker 96. Already handled.",
                isRead: true,
                sender: "administrator",
                sentTime: Date()
            ),
            onMarkAsRead: {
                print("Mark as read called")
            }
        )
    }
    .padding()
}
#endif
