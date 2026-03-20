//
//  CommonScannerView.swift
//  DSD_SWACS
//
//  Created by Andy on 29/7/2025.
//

import SwiftUI
import CodeScanner

struct CommonScannerView: View {
    @Binding var isScanning: Bool
    @Binding var isPaused: Bool
    @Binding var isGalleryPresented: Bool
    var onScanCompleted: (String) -> Void
    var onScanFail: () -> Void
    
    var body: some View {
//        if isScanning {
        CodeScannerView(
            codeTypes: [.qr],
            scanMode: .continuous,
            isPaused: isPaused,
            isGalleryPresented: $isGalleryPresented,
            completion: handleScanResult
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.clear)
        .clipped()
        .statusBar(hidden: false)
//        }
    }

    private func handleScanResult(_ result: Result<ScanResult, ScanError>) {
        switch result {
        case .success(let scanResult):
            // Scan completed successfully
            onScanCompleted(scanResult.string)
            
        case .failure(let error):
            // Handle different error types
            handleScanError(error)
        }
    }
    
    private func handleScanError(_ error: ScanError) {
        switch error {
        case .badInput:
            // Camera access issue (usually permission denied)
            print("⚠️ Scan Error: Bad Input")
        case .badOutput:
            // Camera cannot detect code
            print("❌ Scan Fail: Cannot read QR Code")
            onScanFail()
        case .initError(let underlyingError):
            print("❌ Scan Fail: Init Error - \(underlyingError.localizedDescription)")
        case .permissionDenied:
            print("⚠️ Scan Error: Unable to access camera Permission Denied")
        @unknown default:
            print("❌ Scan Fail: Unknown")
        }
    }
}

#if DEBUG
#Preview {
    CommonScannerView(
        isScanning: .constant(true),
        isPaused: .constant(false),
        isGalleryPresented: .constant(false)
    ) { result in
        
    } onScanFail: {
        
    }
}
#endif
