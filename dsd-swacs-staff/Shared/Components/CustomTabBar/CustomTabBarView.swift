//
//  CustomTabBarView.swift
//  
//
//  Created by User on 18/7/2025.
//

import SwiftUI

struct CustomTabBarView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    
    let tabs: [TabBarItem]
    @Binding var selection: TabBarItem
    @Namespace private var namespace
    @State var localSelection: TabBarItem
    
    var body: some View {
        tabBarVersion1
            .onChange(of: selection) {
                withAnimation(.easeInOut) {
                    localSelection = selection
                }
            }
    }
}

struct CustomTabBarView_Previews: PreviewProvider {
    
    static let tabs: [TabBarItem] = [
        .home, .swac, .siteDiary, .checklist, .setting
    ]
    
    static var previews: some View {
        VStack {
            Spacer()
            CustomTabBarView(tabs: tabs, selection: .constant(tabs.first!), localSelection: tabs.first!)
        }
    }
}

extension CustomTabBarView {
    
    private func tabView(tab: TabBarItem) -> some View {
        VStack {
            Image(localSelection == tab ? tab.selectedIconName: tab.iconName)
                .resizable()
                .renderingMode(.template)
                .foregroundColor(localSelection == tab ? .Primary500 : .Neutral500)
                .frame(width: 24, height: 24)
            Text(tab.title.localized())
                .font(.system(size: 10, weight: .semibold, design: .rounded))
                .lineLimit(1)
        }
        .foregroundColor(localSelection == tab ? .Primary500 : .Neutral500)
        .frame(maxWidth: .infinity, minHeight: 48)
        .contentShape(Rectangle())
    }
    
    private var tabBarVersion1: some View {
        HStack {
            ForEach(tabs, id: \.self) { tab in
                tabView(tab: tab)
                    .onTapGesture {
                        switchToTab(tab: tab)
                    }
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical,12)
        .background(Color.white.ignoresSafeArea(edges: .bottom))
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 0)
    }
    
    private func switchToTab(tab: TabBarItem) {
        selection = tab
    }
    
}
