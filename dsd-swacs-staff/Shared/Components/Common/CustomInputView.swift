//
//  CustomInputView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/10/2025.
//

import SwiftUI

// MARK: - Input Mode
enum InputMode {
    case `default`, placeholder, disabled
}

// MARK: - Title Type
enum TitleType {
    case plain(String)
    case attributed(AttributedString)
}

// MARK: - Custom Input View
struct CustomInputView: View {
    // MARK: - Properties
    let titleType: TitleType
    @Binding var text: String
    let placeholder: String
    let mode: InputMode
    let isSecureField: Bool
    @State private var isSecuredState: Bool
    
    private var titleColor: Color {
        mode == .disabled ? Color.Neutral300 : Color.Primary800
    }
    
    private var textColor: Color {
        mode == .disabled ? Color.Neutral300 : Color.Neutral800
    }
    
    // MARK: - Initializers
    
    init(
        title: String,
        text: Binding<String>,
        placeholder: String,
        mode: InputMode = .default,
        isSecure: Bool = false
    ) {
        self.titleType = .plain(title)
        self._text = text
        self.placeholder = placeholder
        self.mode = mode
        self.isSecureField = isSecure
        self._isSecuredState = State(initialValue: isSecure)
    }
    
    init(
        attributedTitle: AttributedString,
        text: Binding<String>,
        placeholder: String,
        mode: InputMode = .default,
        isSecure: Bool = false
    ) {
        self.titleType = .attributed(attributedTitle)
        self._text = text
        self.placeholder = placeholder
        self.mode = mode
        self.isSecureField = isSecure
        self._isSecuredState = State(initialValue: isSecure)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Title
            titleView
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            // Input Container
            HStack(spacing: 8) {
                inputField
                
                if isSecureField && mode != .disabled {
                    Button(action: {
                        isSecuredState.toggle()
                    }) {
                        Image(isSecuredState ? "eye-slash" : "eye")
                            .frame(width: 16, height: 16)
                    }
                }
            }
            .padding(12)
            .background(Color.Neutral100)
            .cornerRadius(4)
            .frame(height: 44)
        }
    }
    
    // MARK: - Input Field Builder
    @ViewBuilder
    private var inputField: some View {
        Group {
            if isSecuredState {
                SecureField(
                    placeholderText,
                    text: $text,
                    prompt: Text(placeholder).foregroundColor(Color.Neutral300)
                )
            } else {
                TextField(
                    placeholderText,
                    text: $text,
                    prompt: Text(placeholder).foregroundColor(Color.Neutral300)
                )
            }
        }
        .disabled(mode != .default)
        .font(.custom("Roboto", size: 16))
        .foregroundColor(textColor)
        .blockEmoji($text) 
    }
    
    // MARK: - Title View
    @ViewBuilder
    private var titleView: some View {
        switch titleType {
        case .plain(let string):
            Text(string)
                .font(.custom("Roboto", size: 14))
                .foregroundColor(titleColor)
            
        case .attributed(let attributedString):
            Text(attributedString)
        }
    }
    
    // MARK: - Helper
    private var placeholderText: String {
        switch titleType {
        case .plain(let string):
            return string
        case .attributed(let attributedString):
            return String(attributedString.characters)
        }
    }
}

// MARK: - Preview
#if DEBUG
#Preview {
    VStack(spacing: 24) {
        CustomInputView(
            title: "Username",
            text: .constant("andy_lee"),
            placeholder: "Enter username"
        )
        CustomInputView(
            title: "Password",
            text: .constant("123456"),
            placeholder: "Enter password",
            isSecure: true
        )
        CustomInputView(
            attributedTitle: {
                var attr = AttributedString("Confirm Password ")
                attr.font = .custom("Roboto", size: 14)
                var req = AttributedString("*")
                req.foregroundColor = .red
                return attr + req
            }(),
            text: .constant(""),
            placeholder: "Confirm password",
            isSecure: true
        )
        CustomInputView(
            title: "Disabled Password",
            text: .constant("secret"),
            placeholder: "Placeholder",
            mode: .disabled,
            isSecure: true
        )
    }
    .padding()
}
#endif
