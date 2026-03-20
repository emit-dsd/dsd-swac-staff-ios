//
//  String+Emoji.swift
//  dsd-swacs-staff
//
//  Created by Andy on 26/2/2026.
//
import SwiftUI

extension Character {
    var isEmoji: Bool {
        guard let scalar = unicodeScalars.first else { return false }
        return scalar.properties.isEmoji &&
        (scalar.value > 0x238C || unicodeScalars.count > 1)
    }
}

extension String {
    func removingEmojis() -> String {
        self.filter { !$0.isEmoji }
    }
}
