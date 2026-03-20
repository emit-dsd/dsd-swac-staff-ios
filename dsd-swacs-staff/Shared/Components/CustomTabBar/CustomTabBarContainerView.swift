//
//  CustomTabBarContainerView.swift
//
//
//  Created by User on 18/7/2025.
//

import SwiftUI
extension AnyTransition {
    static var customBottom: AnyTransition {
        .asymmetric(
            insertion: .move(edge: .bottom).combined(with: .opacity),
            removal: .move(edge: .bottom).combined(with: .opacity)
        )
    }
}

struct CustomTabBarContainerView<Content:View>: View {
    @Environment(\.isTabBarHidden) var isTabBarHidden
    @Binding var selection: TabBarItem
    let content: Content
    @State private var tabs: [TabBarItem] = []
    
    init(selection: Binding<TabBarItem>, @ViewBuilder content: () -> Content) {
        self._selection = selection
        self.content = content()
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            content
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .ignoresSafeArea()
            
            
            if !isTabBarHidden.wrappedValue {
                CustomTabBarView(tabs: tabs, selection: $selection, localSelection: selection)
                    .transition(.move(edge: .bottom).combined(with: .opacity))
                    .animation(.easeInOut(duration: 0.35), value: isTabBarHidden.wrappedValue)
            }
        }
        
        .onPreferenceChange(TabBarItemsPreferenceKey.self, perform: { value in
            self.tabs = value
        })
    }
}

struct CustomTabBarContainerView_Previews: PreviewProvider {
    
    static let tabs: [TabBarItem] = [
        .home, .swac, .siteDiary, .checklist, .setting
    ]
    
    static var previews: some View {
        CustomTabBarContainerView(selection: .constant(tabs.first!)) {
            Color.red
        }
        
    }
}
