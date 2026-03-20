//
//  KeyboardResponder.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI
import Combine

class KeyboardResponder: ObservableObject {
    @Published var keyboardHeight: CGFloat = 0
    private var cancellableSet: Set<AnyCancellable> = []

    init() {
        NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillShowNotification)
            .merge(with: NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillChangeFrameNotification))
            .compactMap { $0.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect }
            .map { $0.height }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellableSet)

        NotificationCenter.Publisher(center: .default, name: UIResponder.keyboardWillHideNotification)
            .map { _ in CGFloat(0) }
            .sink { [weak self] height in
                self?.keyboardHeight = height
            }
            .store(in: &cancellableSet)
    }
}
