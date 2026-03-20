//
//  CameraPermissionManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/10/2025.
//

import AVFoundation
import SwiftUI

// MARK: - Camera Permission Status
enum CameraPermissionStatus: Equatable {
    case authorized
    case denied
    case restricted
    case notDetermined
    
    var isAuthorized: Bool {
        self == .authorized
    }
}

// MARK: - Camera Permission Manager
final class CameraPermissionManager: ObservableObject {
    
    // MARK: - Singleton
    static let shared = CameraPermissionManager()
    
    // MARK: - Published Properties
    @Published var showCameraAlert = false
    @Published var currentStatus: CameraPermissionStatus = .notDetermined
    
    // MARK: - Initializer
    private init() {
        updateStatus()
    }
    
    // MARK: - Public Properties
    var isAuthorized: Bool {
        currentStatus.isAuthorized
    }
    
    // MARK: - Public Methods
    
    /// 更新當前權限狀態
    func updateStatus() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        currentStatus = mapStatus(status)
    }
    
    /// 檢查並請求相機權限
    @MainActor
    func checkAndRequestPermission() async -> CameraPermissionStatus {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch status {
        case .authorized:
            currentStatus = .authorized
            return .authorized
            
        case .restricted:
            currentStatus = .restricted
            return .restricted
            
        case .denied:
            currentStatus = .denied
            showCameraAlert = true
            return .denied
            
        case .notDetermined:
            let granted = await requestPermission()
            currentStatus = granted ? .authorized : .denied
            
            if !granted {
                showCameraAlert = true
            }
            
            return currentStatus
            
        @unknown default:
            currentStatus = .restricted
            return .restricted
        }
    }
    
    /// 靜默檢查權限（不顯示提示）
    func checkPermissionSilently() {
        updateStatus()
    }
    
    /// 驗證相機權限以執行操作
    func validateCameraForAction(completion: @escaping (Bool) -> Void) {
        Task { @MainActor in
            let status = await checkAndRequestPermission()
            completion(status.isAuthorized)
        }
    }
    
    /// 打開系統設置
    func openSettings() {
        guard let url = URL(string: UIApplication.openSettingsURLString),
              UIApplication.shared.canOpenURL(url) else {
            return
        }
        
        UIApplication.shared.open(url, options: [:], completionHandler: nil)
    }
    
    // MARK: - Private Methods
    
    /// 請求相機權限
    private func requestPermission() async -> Bool {
        await withCheckedContinuation { continuation in
            AVCaptureDevice.requestAccess(for: .video) { granted in
                Task { @MainActor in
                    continuation.resume(returning: granted)
                }
            }
        }
    }
    
    /// 映射 AVAuthorizationStatus 到 CameraPermissionStatus
    private func mapStatus(_ status: AVAuthorizationStatus) -> CameraPermissionStatus {
        switch status {
        case .authorized:
            return .authorized
        case .denied:
            return .denied
        case .restricted:
            return .restricted
        case .notDetermined:
            return .notDetermined
        @unknown default:
            return .restricted
        }
    }
}
