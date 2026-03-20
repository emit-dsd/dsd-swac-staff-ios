//
//  NotificationListView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

struct NotificationListView: View {
    let items: [NotificationItem]
    let onMarkAsRead: (NotificationItem) async -> Void
    
    @State private var expandedID: Int? = nil
    
    var body: some View {
        VStack(spacing: 12) {
            ForEach(items) { item in
                NotificationListRowView(
                    item: item,
                    isExpanded: expandedID == item.id,
                    onTap: {
                        withAnimation {
                            expandedID = (expandedID == item.id) ? nil : item.id
                        }
                    },
                    onMarkAsRead: {
                        await onMarkAsRead(item)
                    }
                )
            }
        }
    }
}

#if DEBUG
#Preview {
    ScrollView {
        NotificationListView(
            items: [
                NotificationItem(
                    id: 1,
                    topic: "Attendance 97",
                    content: "Missing worker 97",
                    isRead: false,
                    sender: "administrator",
                    sentTime: Date().addingTimeInterval(-300)
                ),
                NotificationItem(
                    id: 2,
                    topic: "Attendance 96",
                    content: "Missing worker 96",
                    isRead: true,
                    sender: "administrator",
                    sentTime: Date().addingTimeInterval(-3600)
                )
            ],
            onMarkAsRead: { notification in
                print("Mark notification \(notification.id) as read")
            }
        )
        .padding()
    }
}
#endif
