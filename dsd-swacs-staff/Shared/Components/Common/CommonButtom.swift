//
//  CommonButton.swift
//  DSD_SWACS
//
//  Created by Andy on 28/7/2025.
//

import SwiftUI


enum CommonButtonStyle {
    case contained
    case outlined
    case text
}

struct CommonButtonModel: Identifiable {
    let id = UUID()
    let title: String
    let style: CommonButtonStyle
    let enabled: Bool
    var width: CGFloat?
    var maxWidth: CGFloat?
    var icon: Image?
    var iconColor: Color?
    var iconSize: CGFloat?
    var textColor: Color?
    var backgroundColor: Color?
    var isUnderline: Bool?
    let action: () -> Void
}

struct CommonButton: View {
    let title: String
    let style: CommonButtonStyle
    let enabled: Bool
    var width: CGFloat? = nil
    var maxWidth: CGFloat? = nil
    var icon: Image? = nil
    var iconColor: Color? = nil
    var iconSize: CGFloat? = nil
    var textColor: Color? = nil
    var backgroundColor: Color? = nil
    var isUnderline: Bool = false
    let action: () -> Void
    
    
    private var defaultForeground: Color {
        switch style {
        case .contained:
            return enabled ? .white : Color.Neutral500
        case .outlined:
            return enabled ? Color.Primary600 : Color.Neutral500
        case .text:
            return enabled ? Color.Primary800 : Color.Neutral500
        }
    }
    
    var body: some View {
        Button(action: action) {
            Group {
                HStack(spacing: 4) {
                    if let icon = icon {
                        icon
                            .renderingMode(.template)
                            .resizable()
                            .scaledToFit()
                            .frame(width: iconSize ?? 16, height: iconSize ?? 16)
                            .foregroundColor(iconColor ?? defaultForeground)
                    }
                    Text(title)
                        .fontWeight(.bold)
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(textColor ?? defaultForeground)
                        .underline(isUnderline, pattern: .solid)
                }
                .padding(.horizontal, style == .text ? 0 : 24)
                .padding(.vertical, 12)
                .frame(maxWidth: (width == nil && maxWidth == nil) ? nil : .infinity)
            }
        }
        .modifier(FrameModifier(width: width, maxWidth: maxWidth))
        .buttonStyle(CommonButtonStyleConfig(style: style, enabled: enabled, backgroundColor: backgroundColor))
        .disabled(!enabled)
    }
}

struct FrameModifier: ViewModifier {
    let width: CGFloat?
    let maxWidth: CGFloat?
    
    func body(content: Content) -> some View {
        if let w = width {
            content.frame(width: w)
        } else if let mw = maxWidth {
            content.frame(maxWidth: mw)
        } else {
            content
        }
    }
}


struct CommonButtonStyleConfig: ButtonStyle {
    let style: CommonButtonStyle
    let enabled: Bool
    var backgroundColor: Color? = nil
    
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        
        let background: Color
        let foreground: Color
        let border: Color?
        
        switch style {
        case .contained:
            background = backgroundColor
            ?? (enabled
                ? (isPressed ? Color.Primary600.opacity(0.7) : Color.Primary600)
                : Color.Neutral300)
            foreground = enabled ? Color.white : Color.Neutral500
            border = nil
            
        case .outlined:
            background = enabled ? (isPressed ? Color.white.opacity(0.7) : Color.white) : Color.Neutral300
            foreground = enabled ? Color.Primary600 : Color.Neutral500
            border = backgroundColor ?? (enabled ? Color.Primary600 : nil)
            
        case .text:
            background = backgroundColor ?? .clear
            foreground = enabled
            ? (isPressed ? Color.Primary800.opacity(0.5) : Color.Primary800)
            : Color.Neutral500
            border = nil
        }
        
        
        return configuration.label
            .background(background)
            .foregroundColor(foreground)
            .overlay(
                RoundedRectangle(cornerRadius: 100)
                    .inset(by: 1)
                    .stroke(border ?? .clear, lineWidth: style == .outlined ? 2 : 0)
            )
            .cornerRadius(style == .text ? 0 : 100)
            .opacity(enabled ? 1 : 0.6)
    }
}

#if DEBUG
#Preview {
    CommonButton(title: "Label",
                 style: .contained,
                 enabled: true,
                 icon:Image("home-icon")) {
        
    }
    CommonButton(title: "Label",
                 style: .outlined,
                 enabled: true,
                 icon:Image("home-icon")) {
        
    }
    CommonButton(title: "Label",
                 style: .text,
                 enabled: true,
                 icon:Image("home-icon"),
                 isUnderline: true) {
        
    }
}
#endif
