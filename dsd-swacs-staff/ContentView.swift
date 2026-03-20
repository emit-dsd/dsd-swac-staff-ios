//
//  ContentView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 31/7/2025.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthenticationManager
    
    var body: some View {
        Group {
            if authManager.isLoggedIn {
                MainTabBarView()
            } else {
                LoginMainView()
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthenticationManager.shared)
            .environmentObject(NotificationManager.shared)
            .environmentObject(AlertManager.shared)
            .environmentObject(AppLanguageManager.shared)
    }
}
