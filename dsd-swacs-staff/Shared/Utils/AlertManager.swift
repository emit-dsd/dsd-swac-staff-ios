//
//  AlertManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 26/8/2025.
//

import SwiftUI

@MainActor
final class AlertManager: ObservableObject {
    static let shared = AlertManager()
    
    // MARK: - Published Properties
    @Published var isShowing = false
    @Published private(set) var currentAlert: AlertItem?
    
    // MARK: - Alert Queue
    private var alertQueue: [AlertItem] = []
    private var isProcessingQueue = false
    
    private init() {}
    
    // MARK: - Alert Item
    struct AlertItem: Identifiable {
        let id = UUID()
        let title: String
        let message: String
        let image: String?
        let imageSize: CGFloat
        let buttons: [CommonButtonModel]
        let customContent: AnyView?
        let autoCloseButtons: Bool
        
        var isCustom: Bool {
            customContent != nil
        }
    }
    
    // MARK: - Public Methods
    
    /// Show a standard alert
    func show(
        title: String,
        message: String,
        image: String? = nil,
        imageSize: CGFloat = 260,
        buttons: [CommonButtonModel],
        autoCloseButtons: Bool = true
    ) {
        let item = AlertItem(
            title: title,
            message: message,
            image: image,
            imageSize: imageSize,
            buttons: buttons,
            customContent: nil,
            autoCloseButtons: autoCloseButtons
        )
        enqueue(item)
    }
    
    /// Show a custom view alert
    func showWithCustomView<Content: View>(content: Content) {
        let item = AlertItem(
            title: "",
            message: "",
            image: nil,
            imageSize: 0,
            buttons: [],
            customContent: AnyView(content),
            autoCloseButtons: true
        )
        enqueue(item)
    }
    
    /// Close the current alert
    func close() {
        guard isShowing else { return }
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowing = false
            currentAlert = nil
        }
        
        // Delay before processing the next alert in the queue
        Task {
            try? await Task.sleep(nanoseconds: 300_000_000) // 0.3 seconds
            processNextAlert()
        }
    }
    
    /// Clear the queue
    func clearQueue() {
        alertQueue.removeAll()
//        print("🗑️ Alert queue cleared")
    }
    
    // MARK: - Private Methods
    
    /// Enqueue an alert
    private func enqueue(_ item: AlertItem) {
        if isShowing {
            // If an alert is already showing, add to the queue
            alertQueue.append(item)
//            print("⏳ Alert enqueued: \(item.title) (queue count: \(alertQueue.count))")
        } else {
            // Show immediately
            showImmediate(item)
        }
    }
    
    /// Show alert immediately
    private func showImmediate(_ item: AlertItem) {
        currentAlert = item
        
        withAnimation(.easeInOut(duration: 0.2)) {
            isShowing = true
        }
        
//        print("✅ Alert displayed: \(item.title)")
    }
    
    /// Process the next alert in the queue
    private func processNextAlert() {
        guard !isProcessingQueue else { return }
        guard !alertQueue.isEmpty else {
//            print("✅ Alert queue empty")
            return
        }
        
        isProcessingQueue = true
        
        let nextItem = alertQueue.removeFirst()
        showImmediate(nextItem)
        
//        print("▶️ Displaying next alert in queue: \(nextItem.title) (remaining: \(alertQueue.count))")
        
        isProcessingQueue = false
    }
}

// MARK: - Global Alert Overlay

struct GlobalAlertOverlay: ViewModifier {
    @ObservedObject var alertManager: AlertManager

    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(alertManager.isShowing)

            if alertManager.isShowing, let alert = alertManager.currentAlert {
                // Dim background layer
                Color.black.opacity(0.3)
                    .ignoresSafeArea()

                VStack(spacing: 24) {
                    if let customContent = alert.customContent {
                        customContent
                    } else {
                        standardAlertContent(alert: alert)
                    }
                }
                .padding(24)
                .background(Color.white)
                .cornerRadius(24)
                .shadow(color: Color.black.opacity(0.15), radius: 10, x: 0, y: 4)
                .frame(width: UIScreen.main.bounds.width - 48)
                .transition(.scale.combined(with: .opacity))
            }
        }
        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: alertManager.isShowing)
    }
    
    // MARK: - Standard Alert Content
    @ViewBuilder
    private func standardAlertContent(alert: AlertManager.AlertItem) -> some View {
        VStack(spacing: 24) {
            VStack(spacing: 16) {
                if !alert.title.isEmpty {
                    Text(alert.title)
                        .appFont(.robotoBold, size: 18)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.Neutral800)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
                
                if !alert.message.isEmpty {
                    Text(alert.message)
                        .appFont(.robotoRegular, size: 16)
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color.Neutral500)
                        .frame(maxWidth: .infinity, alignment: .top)
                }
            }
            
            if let image = alert.image {
                Image(image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: alert.imageSize, height: alert.imageSize)
                    .frame(maxWidth: .infinity, alignment: .center)
            }
            
            if !alert.buttons.isEmpty {
                VStack(spacing: 12) {
                    ForEach(alert.buttons) { button in
                        CommonButton(
                            title: button.title,
                            style: button.style,
                            enabled: button.enabled,
                            width: button.width,
                            maxWidth: button.maxWidth,
                            icon: button.icon,
                            iconColor: button.iconColor,
                            textColor: button.textColor,
                            backgroundColor: button.backgroundColor,
                            action: {
                                button.action()
                                if alert.autoCloseButtons {
                                    alertManager.close()
                                }
                            }
                        )
                    }
                }
            }
        }
    }
}

extension View {
    func globalAlertOverlay(alertManager: AlertManager) -> some View {
        self.modifier(GlobalAlertOverlay(alertManager: alertManager))
    }
}

// MARK: - Preview
struct GlobalAlertOverlay_Previews: PreviewProvider {
    static var previews: some View {
        let previewAlert = AlertManager.shared
        
        previewAlert.show(
            title: "System Alert",
            message: "Are you sure you want to log out?",
            image: "icon-alert-fail",
            buttons: [
                CommonButtonModel(
                    title: "Cancel",
                    style: .outlined,
                    enabled: true,
                    maxWidth: .infinity,
                    action: {
                        print("Cancel")
                    }
                ),
                CommonButtonModel(
                    title: "Confirm",
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    backgroundColor: .red,
                    action: {
                        print("Confirm")
                    }
                )
            ]
        )
        
        return ZStack {
            Color.gray.opacity(0.2)
                .ignoresSafeArea()
            
            VStack {
                Text("Main Screen Content")
                    .padding()
                
                Button("Test multiple alerts") {
                    // Test the queue
                    AlertManager.shared.show(
                        title: "Alert 1",
                        message: "First alert",
                        buttons: [
                            CommonButtonModel(
                                title: "Confirm",
                                style: .contained,
                                enabled: true,
                                maxWidth: .infinity,
                                action: {}
                            )
                        ]
                    )
                    
                    AlertManager.shared.show(
                        title: "Alert 2",
                        message: "Second alert",
                        buttons: [
                            CommonButtonModel(
                                title: "Confirm",
                                style: .contained,
                                enabled: true,
                                maxWidth: .infinity,
                                action: {}
                            )
                        ]
                    )
                }
            }
        }
        .globalAlertOverlay(alertManager: previewAlert)
        .previewDisplayName("Global Alert Overlay Preview")
    }
}
