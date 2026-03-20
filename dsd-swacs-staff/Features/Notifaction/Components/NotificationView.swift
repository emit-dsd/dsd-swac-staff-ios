//
//  NotificationView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

struct NotificationView: View {
    let item: NotificationItem
    
    // Icon and colors based on read status
    private var iconName: String {
        "attendance-icon-selected"
    }
    
    private var colors: (iconBG: Color, iconFG: Color, title: Color, border: Color) {
        if item.isRead {
            return (Color.Neutral300,
                    Color.Neutral500,
                    Color.Neutral500,
                    Color.Neutral500)
        } else {
            return (Color(hex: "FFEAEF"),
                    Color.red,
                    Color.red,
                    Color.red)
        }
    }
    
    var body: some View {
        HStack(alignment: .top, spacing: 12) {

            Image(iconName)
                .renderingMode(.template)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
                .foregroundColor(colors.iconFG)
                .padding(8)
                .background(colors.iconBG)
                .clipShape(Circle())
            
       
            VStack(alignment: .leading, spacing: 12) {
               
                Text(item.topic)
                    .appFont(.robotoBold, size: 16)
                    .foregroundColor(colors.title)
                    .frame(maxWidth: .infinity, alignment: .leading)
                
                HStack {
                    Text(item.displayTime)
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                    
                    Spacer()
                    
                    Text(item.timeAgo)
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(.Neutral500)
                }
            }
        }
        .padding(12)
        .background(Color.Neutral100)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(colors.border),
            alignment: .leading
        )
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        // Unread notification
        NotificationView(
            item: NotificationItem(
                id: 1,
                topic: "Attendance 97",
                content: "Missing worker 97",
                isRead: false,
                sender: "administrator",
                sentTime: Date().addingTimeInterval(-300)
            )
        )
        
        // Read notification
        NotificationView(
            item: NotificationItem(
                id: 2,
                topic: "Attendance 96",
                content: "Missing worker 96",
                isRead: true,
                sender: "administrator",
                sentTime: Date().addingTimeInterval(-3600)
            )
        )
    }
    .padding()
}
#endif
