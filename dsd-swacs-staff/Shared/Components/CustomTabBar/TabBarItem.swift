//
//  TabBarItem.swift
//
//
//  Created by User on 18/7/2025.
//

import Foundation
import SwiftUI

//struct TabBarItem: Hashable {
//    let iconName: String
//    let title: String
//    let color: Color
//}

enum TabBarItem: Hashable {
    case home, swac, siteDiary, checklist, setting
    
    var iconName: String {
        switch self {
        case .home: return "home-icon"
        case .swac: return "swac-icon"
        case .siteDiary: return "site-diary-icon"
        case .checklist: return "checklist-icon"
        case .setting: return "setting-icon"
        }
    }
    
    var selectedIconName: String {
        switch self {
        case .home: return "home-icon-selected"
        case .swac: return "swac-icon-selected"
        case .siteDiary: return "site-diary-icon-selected"
        case .checklist: return "checklist-icon-selected"
        case .setting: return "setting-icon-selected"
        }
    }

    var title: String {
        switch self {
        case .home: return "tab_bar_button_home"
        case .swac: return "tab_bar_button_swac"
        case .siteDiary: return "tab_bar_button_siteDiary"
        case .checklist: return "tab_bar_button_safety"
        case .setting: return "tab_bar_button_setting"
        }
    }
}
