//
//  ScanView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 29/7/2025.
//

import SwiftUI
import PDFKit
import Vision
import UIKit
import AVFoundation

// MARK: - ScanMode Extension
extension ScanMode {
    var tintColor: Color {
        switch self {
        case .signIn:
            return Color(hex: "0068A6")
        case .signOut:
            return Color(hex: "FF3665")
        case .verify:
            return Color(hex: "DFBA00")
        }
    }
    
    var title: String {
        switch self {
        case .signIn:
            return "scan_qr_code_label_sign_in_title".localized()
        case .signOut:
            return "scan_qr_code_label_sign_out_title".localized()
        case .verify:
            return "scan_qr_code_label_swac_check_title".localized()
        }
    }
}

// MARK: - ScanMode Enum
enum ScanMode {
    case signIn
    case signOut
    case verify
}

// MARK: - ScanView
struct ScanView: View {
    // MARK: - Environment
    @EnvironmentObject var tabStore: TabNavigationStore
    @Environment(\.presentationMode) var presentationMode
    
    // MARK: - Properties
    @Binding var isPaused: Bool
    let scanMode: ScanMode
    let showButton: Bool
    let onComplete: (String) -> Void
    let onFail: () -> Void
    
    // MARK: - State
    @State private var isScanning = true
    @State private var isGalleryPresented = false
    @State private var showingDocumentPicker = false
    @StateObject private var permissionManager = CameraPermissionManager.shared
    
    // MARK: - Initializer
    init(
        scanMode: ScanMode,
        showButton: Bool,
        isPaused: Binding<Bool>,
        onComplete: @escaping (String) -> Void,
        onFail: @escaping () -> Void
    ) {
        self.scanMode = scanMode
        self.showButton = showButton
        self._isPaused = isPaused
        self.onComplete = onComplete
        self.onFail = onFail
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
            CustomNavBarView(type: .backOnly, title: scanMode.title)
            
            scannerContentView
        }
        .sheet(isPresented: $showingDocumentPicker) {
            DocumentPicker { url in
                handleDocumentSelection(url: url)
            }
        }
        .cameraPermissionAlert(cameraManager: permissionManager)
        .onAppear {
            setupView()
        }
    }
    
    // MARK: - Scanner Content View
    private var scannerContentView: some View {
        ZStack {
            // Camera Scanner View
            CommonScannerView(
                isScanning: $isScanning,
                isPaused: $isPaused,
                isGalleryPresented: $isGalleryPresented
            ) { result in
                handleScanSuccess(result: result)
            } onScanFail: {
                handleScanFailure()
            }
            .ignoresSafeArea()
            
            // Scan Zone Overlay
            scanZoneOverlay
            
            // Bottom Buttons
            if showButton {
                bottomButtonsView
            }
        }
        .padding(.top, -2)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
    
    // MARK: - Scan Zone Overlay
    private var scanZoneOverlay: some View {
        Image("scan-zone")
            .renderingMode(.template)
            .foregroundColor(scanMode.tintColor)
            .frame(width: 300, height: 300)
        #if targetEnvironment(simulator)
            .offset(y: -100)
        #endif
    }
    
    // MARK: - Bottom Buttons View
    private var bottomButtonsView: some View {
        VStack {
            Spacer()
            HStack(alignment: .center, spacing: 24) {
                // Gallery Button
                CommonButton(
                    title: "scan_qr_code_label_gallery".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    icon: Image("icon-scan-image"),
                    iconColor: Color.white,
                    iconSize: 16,
                    textColor: Color.white,
                    backgroundColor: Color.Primary500
                ) {
                    isGalleryPresented = true
                }
                
                // PDF Button
                CommonButton(
                    title: "scan_qr_code_label_pdf".localized(),
                    style: .contained,
                    enabled: true,
                    maxWidth: .infinity,
                    icon: Image("icon-scan-pdf"),
                    iconColor: Color.white,
                    iconSize: 16,
                    textColor: Color.white,
                    backgroundColor: Color.Primary500
                ) {
                    showingDocumentPicker = true
                }
            }
            .padding(.horizontal, 35)
            .padding(.bottom, 100)
        }
    }
    
    // MARK: - Setup Methods
    private func setupView() {
        withAnimation {
            isPaused = false
        }
        
        Task {
            await checkCameraPermission()
        }
    }
    
    private func checkCameraPermission() async {
        let status = await permissionManager.checkAndRequestPermission()
        
        await MainActor.run {
            switch status {
            case .authorized:
                isScanning = true
            case .denied, .restricted, .notDetermined:
                isScanning = false
            }
        }
    }
    
    // MARK: - Scan Handlers
    private func handleScanSuccess(result: String) {
        isPaused = false
        onComplete(result)
    }
    
    private func handleScanFailure() {
        isPaused = false
        onFail()
    }
    
    // MARK: - Document Handling
    private func handleDocumentSelection(url: URL) {
        showingDocumentPicker = false
        
        Task {
            await scanQRCodeFromPDF(url: url)
        }
    }
    
    // MARK: - PDF QR Code Scanning
    private func scanQRCodeFromPDF(url: URL) async {
        guard let image = imageFromPDF(url: url) else {
            await MainActor.run {
                onFail()
            }
            return
        }
        
        await scanQRCode(from: image) { code in
            if let result = code {
                onComplete(result)
            } else {
                onFail()
            }
        }
    }
    
    private func imageFromPDF(url: URL, page: Int = 0) -> UIImage? {
        guard let pdf = PDFDocument(url: url),
              let pdfPage = pdf.page(at: page) else {
            return nil
        }
        
        let pageRect = pdfPage.bounds(for: .mediaBox)
        let renderer = UIGraphicsImageRenderer(size: pageRect.size)
        
        return renderer.image { ctx in
            UIColor.white.set()
            ctx.fill(pageRect)
            pdfPage.draw(with: .mediaBox, to: ctx.cgContext)
        }
    }
    
    private func scanQRCode(from image: UIImage, completion: @escaping (String?) -> Void) async {
        guard let cgImage = image.cgImage else {
            await MainActor.run {
                completion(nil)
            }
            return
        }
        
        let request = VNDetectBarcodesRequest { request, error in
            if let error = error {
                print("QR Code 掃描錯誤: \(error.localizedDescription)")
                Task { @MainActor in
                    completion(nil)
                }
                return
            }
            
            guard let results = request.results as? [VNBarcodeObservation] else {
                Task { @MainActor in
                    completion(nil)
                }
                return
            }
            
            for result in results {
                if let payload = result.payloadStringValue {
                    Task { @MainActor in
                        completion(payload)
                    }
                    return
                }
            }
            
            Task { @MainActor in
                completion(nil)
            }
        }
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        do {
            try handler.perform([request])
        } catch {
            print("Vision 請求失敗: \(error.localizedDescription)")
            await MainActor.run {
                completion(nil)
            }
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    ScanView(
        scanMode: .signIn,
        showButton: true,
        isPaused: .constant(false),
        onComplete: { _ in },
        onFail: { }
    )
}
#endif
