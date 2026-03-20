//
//  RetryAlert.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

import SwiftUI

// MARK: - Network Error Alert Modifier
struct NetworkErrorAlertModifier: ViewModifier {
    @ObservedObject var api = APIManager.shared
    @ObservedObject var alertManager = AlertManager.shared
    
    func body(content: Content) -> some View {
        content
            .onChange(of: api.showRetryAlert) {
                if api.showRetryAlert && !api.showErrorAlert{
                    alertManager.show(
                        title: "general_alertTitle_no_network".localized(),
                        message: "general_alertMessage_no_network".localized(),
                        buttons: [
                            CommonButtonModel(
                                title: "general_confirm".localized(),
                                style: .contained,
                                enabled: true,
                                maxWidth: .infinity,
                                textColor: .white,
                                backgroundColor: .red,
                                action: {
                                    alertManager.close()
                                    api.showRetryAlert = false
                                    api.cancelRetry()
                                }
                            )
                        ]
                    )
                    
                }
            }
            .globalAlertOverlay(alertManager: alertManager)
   
    }
}

extension View {
    func networkErrorAlert() -> some View {
        modifier(NetworkErrorAlertModifier())
    }
}


struct APIErrorAlertModifier: ViewModifier {
    @ObservedObject var api = APIManager.shared
    @ObservedObject var alertManager =  AlertManager.shared
    
    func body(content: Content) -> some View {
        content
            .onChange(of: api.showErrorAlert) {
                if api.showErrorAlert && !api.showRetryAlert{
                    alertManager.show(
                        title: "general_alertTitle_server_error".localized(),
                        message: api.errorMessage?.localized() ?? "Unknown Error",
                        buttons: [
                            CommonButtonModel(
                                title: "general_confirm".localized(),
                                style: .contained,
                                enabled: true,
                                maxWidth: .infinity,
                                textColor: .white,
                                backgroundColor: .red,
                                action: {
                                    alertManager.close()
                                    api.showErrorAlert = false
                                }
                            )
                        ]
                    )
                }
            }
            .globalAlertOverlay(alertManager: alertManager)
    }
}
extension View {
    func apiErrorAlert() -> some View {
        modifier(APIErrorAlertModifier())
    }
}

// MARK: - Loading UI
struct GlobalLoadingOverlay: ViewModifier {
    @ObservedObject var api = APIManager.shared
    
    func body(content: Content) -> some View {
        ZStack {
            content
                .disabled(api.isLoading)
            
            if api.isLoading {
                Color.black.opacity(0.3).ignoresSafeArea()
                
                VStack(spacing: 16) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(1.5) // 放大spinner
                    
                }
                .padding(20)
                .background(Color.black.opacity(0.8))
                .cornerRadius(10)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .animation(.easeInOut, value: api.isLoading)
    }
}

extension View {
    func globalLoadingOverlay() -> some View {
        self.modifier(GlobalLoadingOverlay())
    }
}

