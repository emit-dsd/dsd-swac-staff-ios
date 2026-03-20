//
//  TabBarEnvironmentKey.swift
//  
//
//  Created by Andy on 25/7/2025.
//

import SwiftUI

struct IsTabBarHiddenKey: EnvironmentKey {
    static let defaultValue: Binding<Bool> = .constant(false)
}

extension EnvironmentValues {
    var isTabBarHidden: Binding<Bool> {
        get { self[IsTabBarHiddenKey.self] }
        set { self[IsTabBarHiddenKey.self] = newValue }
    }
}
