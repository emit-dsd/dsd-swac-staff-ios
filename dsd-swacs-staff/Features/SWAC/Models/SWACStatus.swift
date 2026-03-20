//
//  SWACStatus.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/11/2025.
//

import Foundation
import SwiftUI

enum SWACStatus: String,CaseIterable {
    case unknown
    case draft
    case submitted
    case vetting
    case pending
    case approved
    case rejected
    
    var displayText: String {
        return "swac_status_label_\(self.rawValue)".localized()
    }
    
    var color: Color {
        switch self {
        case .unknown: return Color.Neutral500
        case .draft: return Color.Neutral500
        case .submitted: return Color(hex: "18AE0B")
        case .vetting: return Color.orange
        case .pending: return Color.yellow
        case .approved: return .Primary800
        case .rejected: return Color.red
        }
    }
    
    var backgroundColor: Color {
        switch self {
        case .unknown: return Color.Neutral200
        case .draft: return  .Neutral200
        case .submitted: return Color(hex: "F3FAF2")
        case .vetting: return Color(hex: "FFFBF5")
        case .pending: return  Color(hex: "FFFDF5")
        case .approved: return Color(hex: "F6FCFF")
        case .rejected: return Color(hex: "FFEAEF")
        }
    }
    
    var gradientdColor: Color {
        switch self {
        case .unknown: return Color.Neutral200
        case .draft: return  .Neutral200
        case .submitted: return Color(hex: "E9FEEB")
        case .vetting: return Color(hex: "FFE8C4")
        case .pending: return  Color(hex: "FFE8C4")
        case .approved: return .Primary100
        case .rejected: return Color(hex: "FFEAEF")
        }
    }
    
    init?(stateInt: Int) {
        switch stateInt {
        case 0: self = .unknown
        case 1: self = .draft
        case 2: self = .submitted
        case 3: self = .vetting
        case 4: self = .pending
        case 5: self = .approved
        case 6: self = .rejected
        default:
            return nil
        }
    }
}
