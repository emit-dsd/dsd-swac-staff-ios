//
//  AppDelegate.swift
//  dsd-swacs-staff
//
//  Created by Andy on 11/11/2025.
//

import SwiftUI
import Firebase
import FirebaseMessaging
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // Configure Firebase
        FirebaseApp.configure()
        
        // Set delegates
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self
        
        // Request notification permission
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, error in
            print("Permission granted: \(granted)")
            
            if let error = error {
                print("Authorization error: \(error)")
            }
        }
        
        application.registerForRemoteNotifications()
        
        return true
    }
    
    // MARK: - APNs Token Registration
    
    /// Called when APNs successfully registers the device
    /// - Parameters:
    ///   - application: The application instance
    ///   - deviceToken: The APNs device token data
    func application(_ application: UIApplication,
                     didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data) {
        
        // Convert token data to hexadecimal string
        let tokenParts = deviceToken.map { data in String(format: "%02.2hhx", data) }
        let token = tokenParts.joined()
        
        print("📱 APNs Device Token: \(token)")
        
        // Pass APNs token to Firebase Messaging
        Messaging.messaging().apnsToken = deviceToken
    }
    
    /// Called when APNs registration fails
    /// - Parameters:
    ///   - application: The application instance
    ///   - error: The error that occurred during registration
    func application(_ application: UIApplication,
                     didFailToRegisterForRemoteNotificationsWithError error: Error) {
        print("❌ Failed to register for remote notifications: \(error)")
    }
    
    // MARK: - FCM Token Handling
    
    /// Called when FCM registration token is received or refreshed
    /// This method is triggered:
    /// - On app launch
    /// - When token is updated or invalidated
    /// - After app reinstallation or data clearing
    /// - Parameters:
    ///   - messaging: The Firebase Messaging instance
    ///   - fcmToken: The FCM registration token string
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        guard let fcmToken = fcmToken else {
            print("⚠️ FCM Token is nil")
            return
        }
        
        print("🔥 FCM Token: \(fcmToken)")
        
        // Handle token update via FCMTokenManager
        Task { @MainActor in
            await FCMTokenManager.shared.handleTokenRefresh(fcmToken)
        }
        
        // Post notification for other components to listen to (optional)
        NotificationCenter.default.post(
            name: Notification.Name("FCMTokenRefreshed"),
            object: nil,
            userInfo: ["token": fcmToken]
        )
    }
    
    // MARK: - Notification Handling
    
    /// Called when a notification is received while app is in the foreground
    /// - Parameters:
    ///   - center: The notification center instance
    ///   - notification: The notification object
    ///   - completionHandler: Handler to specify presentation options
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo
        print("📬 Notification received in foreground: \(userInfo)")
        
        // Display notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
    
    /// Called when user taps on a notification
    /// - Parameters:
    ///   - center: The notification center instance
    ///   - response: The user's response to the notification
    ///   - completionHandler: Handler to call when finished processing
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        print("👆 Notification tapped with data: \(userInfo)")
        
        // Handle notification tap and navigate accordingly
        handleNotificationTap(userInfo: userInfo)
        
        completionHandler()
    }
    
    // MARK: - Private Methods
    
    /// Handle navigation based on notification data
    /// - Parameter userInfo: The notification payload dictionary
    private func handleNotificationTap(userInfo: [AnyHashable: Any]) {
        // Navigate to specific screen based on notification data
        // Example implementation:
        // if let screen = userInfo["screen"] as? String {
        //     NotificationCenter.default.post(
        //         name: Notification.Name("NavigateToScreen"),
        //         object: screen
        //     )
        // }
        //
        // if let recordId = userInfo["recordId"] as? String {
        //     // Navigate to detail view with recordId
        // }
    }
}
