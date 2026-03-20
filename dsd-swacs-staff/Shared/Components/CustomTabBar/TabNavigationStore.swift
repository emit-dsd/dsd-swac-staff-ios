//
//  TabNavigationStore.swift
//  SiteWorkApp
//
//  Created by User on 21/7/2025.
//

import SwiftUI

final class TabNavigationStore: ObservableObject {
    @Published var tabSelection: TabBarItem = .home
    
    @Published var homePath = NavigationPath()
    @Published var swacPath = NavigationPath()
    @Published var siteDiaryPath = NavigationPath()
    @Published var checklistPath = NavigationPath()
    @Published var settingPath = NavigationPath()
    
    func resetHomePath() {
        homePath.removeLast(homePath.count)
    }
    
    func resetSwacPath() {
        swacPath.removeLast(swacPath.count)
    }
    
    func resetAttendancePath() {
        siteDiaryPath.removeLast(siteDiaryPath.count)
    }
    
    func resetChecklistPath() {
        checklistPath.removeLast(checklistPath.count)
    }
    
    func resetCurrentPath(){
        switch tabSelection {
        case .home:
            homePath.removeLast(homePath.count)
        case .swac:
            swacPath.removeLast(homePath.count)
        case .siteDiary:
            siteDiaryPath.removeLast(homePath.count)
        case .checklist:
            checklistPath.removeLast(homePath.count)
        case .setting:
            settingPath.removeLast(homePath.count)
        }
    }
}

extension TabNavigationStore {
    func getCurrentPath() -> NavigationPath {
        switch tabSelection {
        case .home:
            return homePath
        case .swac:
            return swacPath
        case .siteDiary:
            return siteDiaryPath
        case .checklist:
            return checklistPath
        case .setting:
            return settingPath
        }
    }
    
    func appendToCurrentPath(_ value: any Hashable) {
        switch tabSelection {
        case .home:
            homePath.append(value)
        case .swac:
            swacPath.append(value)
        case .siteDiary:
            siteDiaryPath.append(value)
        case .checklist:
            checklistPath.append(value)
        case .setting:
            settingPath.append(value)
        }
    }

    func popLastOnCurrentPath() {
        switch tabSelection {
        case .home:
            if !homePath.isEmpty { homePath.removeLast() }
        case .swac:
            if !swacPath.isEmpty { swacPath.removeLast() }
        case .siteDiary:
            if !siteDiaryPath.isEmpty { siteDiaryPath.removeLast() }
        case .checklist:
            if !checklistPath.isEmpty { checklistPath.removeLast() }
        case .setting:
            if !settingPath.isEmpty { settingPath.removeLast() }
        }
    }
    
    func popLastOnCurrentPath(count: Int) {
        guard count > 0 else { return }
        
        switch tabSelection {
        case .home:
            let actualCount = min(count, homePath.count)
            for _ in 0..<actualCount {
                if !homePath.isEmpty { homePath.removeLast() }
            }
            
        case .swac:
            let actualCount = min(count, swacPath.count)
            for _ in 0..<actualCount {
                if !swacPath.isEmpty { swacPath.removeLast() }
            }
            
        case .siteDiary:
            let actualCount = min(count, siteDiaryPath.count)
            for _ in 0..<actualCount {
                if !siteDiaryPath.isEmpty { siteDiaryPath.removeLast() }
            }
            
        case .checklist:
            let actualCount = min(count, checklistPath.count)
            for _ in 0..<actualCount {
                if !checklistPath.isEmpty { checklistPath.removeLast() }
            }
            
        case .setting:
            let actualCount = min(count, settingPath.count)
            for _ in 0..<actualCount {
                if !settingPath.isEmpty { settingPath.removeLast() }
            }
        }
    }

}

extension TabNavigationStore {
    func notifyIncidentReportListReload() {
        NotificationCenter.default.post(
            name: .incidentReportListReload,
            object: nil
        )
    }
}

extension Notification.Name {
    static let incidentReportListReload = Notification.Name("incidentReportListReload")
}
