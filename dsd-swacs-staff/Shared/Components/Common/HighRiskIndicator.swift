//
//  HighRiskIndicatorView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

enum HighRiskType: String, CaseIterable, Identifiable {
    case confinedSpace
    case highTemperature
    case workAtHeight

    var id: String { self.rawValue }
    var imageName: String {
        switch self {
        case .confinedSpace: return "confined-space"
        case .highTemperature: return "high-temperature"
        case .workAtHeight: return "work-at-height"
        }
    }
}

struct HighRiskIndicator: View {
    let showTypes: [Bool]

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            ForEach(Array(HighRiskType.allCases.enumerated()), id: \.element) { idx, type in
                if showTypes.indices.contains(idx), showTypes[idx] {
                    VStack(spacing: 4) {
                        Image(type.imageName)
                            .resizable()
                            .frame(width: 36, height: 36)
                    }
                }
            }
        }
    }
}


#if DEBUG
#Preview {
    HighRiskIndicator(showTypes: [true,false,true])
}
#endif
