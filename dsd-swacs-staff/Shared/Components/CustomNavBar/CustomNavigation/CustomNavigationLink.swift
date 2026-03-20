//
//  CustomNavigationLink.swift
//
//
//  Created by User on 18/7/2025.
//

import SwiftUI

struct CustomNavigationLink<Label: View>: View {
    @Binding var path: NavigationPath
    let screen: Screen
    let label: Label

    init(path: Binding<NavigationPath>, screen: Screen, @ViewBuilder label: () -> Label) {
        self._path = path
        self.screen = screen
        self.label = label()
    }

    var body: some View {
        Button {
            path.append(screen)
        } label: {
            label
        }
    }
}
