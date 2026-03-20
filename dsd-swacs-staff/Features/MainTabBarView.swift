//
//  MainTabBarView.swift
//
//
//  Created by User on 18/7/2025.
//

import SwiftUI
import Localize_Swift

struct MainTabBarView: View {
    @StateObject var tabStore = TabNavigationStore()
    @State private var isTabBarHidden: Bool = false
   
    //    @State private var selection: String = "home"
    //    @State private var tabSelection: TabBarItem = .home
    
    var body: some View {
        CustomTabBarContainerView(selection: $tabStore.tabSelection) {
            CustomNavView(path: $tabStore.homePath) {
                HomeView()
            }
            .tabBarItem(tab: .home, selection: $tabStore.tabSelection)
            .environmentObject(tabStore)
            
            CustomNavView(path: $tabStore.swacPath) {
                SWACMainView()
            }
            .tabBarItem(tab: .swac, selection: $tabStore.tabSelection)
            .environmentObject(tabStore)
            
            CustomNavView(path: $tabStore.siteDiaryPath) {
                SiteDiaryMainView()
            }
            .tabBarItem(tab: .siteDiary, selection: $tabStore.tabSelection)
            .environmentObject(tabStore)
            
            CustomNavView(path: $tabStore.checklistPath) {
                SafetyInspectionMainView()
            }
            .tabBarItem(tab: .checklist, selection: $tabStore.tabSelection)
            .environmentObject(tabStore)
            
            CustomNavView(path: $tabStore.settingPath) {
                SettingView()
            }
            .tabBarItem(tab: .setting, selection: $tabStore.tabSelection)
            .environmentObject(tabStore)
        }
        .environmentObject(tabStore)
        .environment(\.isTabBarHidden, $isTabBarHidden)
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onChange(of: tabStore.tabSelection) { _, _ in
            updateTabBarHidden()
        }
        .onChange(of: tabStore.homePath.count) { _, _ in
            if tabStore.tabSelection == .home { updateTabBarHidden() }
        }
        .onChange(of: tabStore.swacPath.count) { _, _ in
            if tabStore.tabSelection == .swac { updateTabBarHidden() }
        }
        .onChange(of: tabStore.siteDiaryPath.count) { _, _ in
            if tabStore.tabSelection == .siteDiary { updateTabBarHidden() }
        }
        .onChange(of: tabStore.checklistPath.count) { _, _ in
            if tabStore.tabSelection == .checklist { updateTabBarHidden() }
        }
        .onChange(of: tabStore.settingPath.count) { _, _ in
            if tabStore.tabSelection == .setting { updateTabBarHidden() }
        }
    }
    
    private func updateTabBarHidden() {
        let depth: Int
        switch tabStore.tabSelection {
        case .home:
            depth = tabStore.homePath.count
        case .swac:
            depth = tabStore.swacPath.count
        case .siteDiary:
            depth = tabStore.siteDiaryPath.count
        case .checklist:
            depth = tabStore.checklistPath.count
        case .setting:
            depth = tabStore.settingPath.count
        }

        withAnimation {
            isTabBarHidden = (depth > 0)
        }
    }
}

struct MainTabBarView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabBarView()
            .environmentObject(AuthenticationManager.shared)
            .environmentObject(NotificationManager.shared)
            .environmentObject(AlertManager.shared)
            .environmentObject(AppLanguageManager.shared)
    }
}
