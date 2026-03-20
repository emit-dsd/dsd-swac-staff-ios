//
//  Font.swift
//  SiteWorkApp
//
//  Created by User on 18/7/2025.
//

import SwiftUI

enum FontName: String {
    case robotoRegular = "Roboto-Regular"
    case robotoBold = "Roboto-Bold"
    case robotoLight = "Roboto-Light"
    case robotoMedium = "Roboto-Medium"
    case robotoSemiBold = "Roboto-SemiBold"
}

extension View {
    func appFont(_ font: FontName, size: CGFloat) -> some View {
        self.font(.custom(font.rawValue, size: size))
    }
}
