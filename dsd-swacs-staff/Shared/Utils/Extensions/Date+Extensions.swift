//
//  Date+Extensions.swift
//  dsd-swacs-staff
//
//  Created by Andy on 26/8/2025.
//

import Foundation

extension Date {
    /// Convert date to string format
    /// - Parameter format: Date format string (default: "yyyy-MM-dd'T'HH:mm:ss")
    func toString(format: String = "yyyy-MM-dd'T'HH:mm:ss") -> String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = format
        return formatter.string(from: self)
    }
    
    /// Date Extension for API Format
    /// Convert date to API-compatible string format
    /// Format: yyyy-MM-dd in Hong Kong timezone
    /// Use this when API expects a date without time component, specifically in HK time
    func toAPIDateString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        formatter.locale = Locale(identifier: "en_US_POSIX")
        return formatter.string(from: self)
    }
}

extension String {
    /// Attempt to parse API ISO8601 String to Date
    /// Supports:
    /// 1. yyyy-MM-dd'T'HH:mm:ss (Standard)
    /// 2. yyyy-MM-dd'T'HH:mm:ss.SSS (With fractional seconds)
    /// 3. yyyy-MM-dd'T'HH:mm:ss (Without timezone/Z suffix fallback)
    var iso8601Date: Date? {
        if let date = ISO8601DateFormatter.shared.date(from: self) {
            return date
        }
        
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
        if let date = formatter.date(from: self) {
            return date
        }
        
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
        if let date = formatter.date(from: self) {
            return date
        }
        
        return nil
    }
}

extension ISO8601DateFormatter {
    /// Shared instance for performance optimization
    /// Pre-configured to handle Internet Date Time (RFC 3339) and Fractional Seconds
    static let shared: ISO8601DateFormatter = {
        let formatter = ISO8601DateFormatter()
        formatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        return formatter
    }()
    
    static let timeStringForAPI: ISO8601DateFormatter = {
           let formatter = ISO8601DateFormatter()
           formatter.timeZone = TimeZone(identifier: "Asia/Hong_Kong")!
           formatter.formatOptions = [
               .withFullDate,
               .withTime,
               .withColonSeparatorInTime,
           ]
           return formatter
       }()
}
