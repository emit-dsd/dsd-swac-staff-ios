//
//  CustomNavView.swift
//
//
//  Created by User on 18/7/2025.
//

import SwiftUI
import SwiftfulRouting

struct CustomNavView<Content:View>: View {
    @Binding var path: NavigationPath
    let content: Content

    init(path: Binding<NavigationPath>, @ViewBuilder content: () -> Content) {
        self._path = path
        self.content = content()
    }

    var body: some View {
   
        NavigationStack(path: $path) {
//            CustomNavBarContainerView {
//            RouterView { _ in
                content
//            }
            .navigationBarHidden(true)
            .appNavigationDestination() 
        }
    }
}

struct CustomNavView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State private var path = NavigationPath()

        var body: some View {
            CustomNavView(path: $path) {
                Color.red.ignoresSafeArea()
            }
        }
    }

    static var previews: some View {
        PreviewWrapper()
    }
}

extension UINavigationController {
    
    open override func viewDidLoad() {
        super.viewDidLoad()
        interactivePopGestureRecognizer?.delegate = nil
    }
}
