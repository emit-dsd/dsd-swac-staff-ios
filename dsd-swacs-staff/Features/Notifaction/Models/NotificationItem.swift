//
//  NotificationItem.swift
//  dsd-swacs-staff
//
//  Created by Andy on 8/8/2025.
//

import Foundation
import Localize_Swift

struct NotificationItem: Identifiable, Equatable {
 
    let id: Int
    let topic: String        // Used as title
    let content: String      // Used as remarks/description
    let isRead: Bool
    let sender: String
    let sentTime: Date       // Parsed from sentTime string
    
    static var currentLanguage: String = "en"
    
    private var currentLocale: Locale {
        let languageCode = Localize.currentLanguage()
        return Locale(identifier: languageCode)
    }
    
    // Display formatted time
    var displayTime: String {
//        let calendar = Calendar.current
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter.string(from: sentTime)
//        formatter.locale = currentLocale
//        formatter.timeStyle = .short
        
//        if calendar.isDateInToday(sentTime) {
//            let todayText = "notification_label_time_today".localized()
//            return "\(todayText) \(formatter.string(from: sentTime))"
//        } else if calendar.isDateInYesterday(sentTime) {
//            let yesterdayText = "notification_label_time_yesterday".localized()
//            return "\(yesterdayText) \(formatter.string(from: sentTime))"
//        } else {
//            let dateFormatter = DateFormatter()
//            dateFormatter.locale = currentLocale
//            dateFormatter.dateStyle = .medium
//            
//            let timeFormatter = DateFormatter()
//            timeFormatter.locale = currentLocale
//            timeFormatter.timeStyle = .short
//            
//            let dateString = dateFormatter.string(from: sentTime)
//            let timeString = timeFormatter.string(from: sentTime)
//            
//            return "\(dateString) \(timeString)"
//        }
    }
    
    var timeAgo: String {
        let now = Date()
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second],from: sentTime, to: now)
        
        if let years = components.year, years >= 1 {
            return "notification_label_time_year_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(years)")
        }
        else if let months = components.month, months >= 1 {
            return "notification_label_time_months_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(months)")
        }
        else if let weeks = components.weekOfYear, weeks >= 1 {
            return "notification_label_time_weeks_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(weeks)")
        }
        else if let days = components.day, days >= 1 {
            return "notification_label_time_days_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(days)")
        }
        else if let hours = components.hour, hours >= 1 {
            return "notification_label_time_hours_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(hours)")
        }
        else if let minutes = components.minute, minutes >= 1 {
            return "notification_label_time_minutes_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(minutes)")
        }
        else if let second = components.second, second > 1 {
            return "notification_label_time_seconds_ago".localized()
                .replacingOccurrences(of: "{R1}", with: "\(second)")
        }
        else {
            return "notification_label_time_just_now".localized()
        }
    }

    
    // MARK: - Convert from API Response
    
    static func from(_ response: NotificationItemResponse) -> NotificationItem? {
        guard let date = parseSentTime(response.sentTime) else {
            print("⚠️ Failed to parse date: \(response.sentTime)")
            return nil
        }
        
        return NotificationItem(
            id: response.id,
            topic: response.topic,
            content: response.content,
            isRead: response.isRead,
            sender: response.sender,
            sentTime: date
        )
    }
    
    private static func parseSentTime(_ timeString: String) -> Date? {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        return formatter.date(from: timeString)
    }
    
}


// MARK: - Batch Conversion Extension
extension Array where Element == NotificationItemResponse {
    func toNotificationItems() -> [NotificationItem] {
        return self.compactMap { NotificationItem.from($0) }
    }
}
