//
//  CameraPermissionAlertModifier.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/10/2025.
//

import SwiftUI

// MARK: - Camera Permission Alert Modifier
struct CameraPermissionAlertModifier: ViewModifier {
    
    @ObservedObject var cameraManager: CameraPermissionManager
    @EnvironmentObject var alertManager: AlertManager
    
    init(cameraManager: CameraPermissionManager) {
        self.cameraManager = cameraManager
    }
    
    func body(content: Content) -> some View {
        content
            .onChange(of: cameraManager.showCameraAlert) { _, newValue in
                if newValue {
                    showCameraPermissionAlert()
                }
            }
    }
    
    private func showCameraPermissionAlert() {
        let buttons: [CommonButtonModel] = [
            CommonButtonModel(
                title: "camera_button_settings".localized(),
                style: .contained,
                enabled: true,
                maxWidth: .infinity,
                backgroundColor: .red,
                action: {
                    cameraManager.openSettings()
                    cameraManager.showCameraAlert = false
                }
            ),
            CommonButtonModel(
                title: "general_cancel".localized(),
                style: .outlined,
                enabled: true,
                maxWidth: .infinity,
                action: {
                    cameraManager.showCameraAlert = false
                }
            )
        ]
        
        alertManager.show(
            title: "camera_alertTitle_camera_required".localized(),
            message: "camera_alertMessage_camera_required".localized(),
            buttons: buttons
        )
    }
}

// MARK: - View Extension
extension View {
    func cameraPermissionAlert(
        cameraManager: CameraPermissionManager = .shared
    ) -> some View {
        self.modifier(
            CameraPermissionAlertModifier(cameraManager: cameraManager)
        )
    }
}

// MARK: - Legacy Support (向後兼容)
extension View {
    @available(*, deprecated, message: "請使用 cameraPermissionAlert 替代")
    func permissionAlert(
        isPresented: Binding<Bool>,
        presentationMode: Binding<PresentationMode>
    ) -> some View {
        self.cameraPermissionAlert()
    }
}
