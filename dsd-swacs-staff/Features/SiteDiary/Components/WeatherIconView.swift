//
//  WeatherIconView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 30/10/2025.
//
import SwiftUI

struct WeatherIconView: View {
    let status: WeatherStatus

    var body: some View {
        VStack(alignment: .center, spacing: 2) {
            Image(status.imageName)
                .frame(width: 24, height: 24)
            Text(status.label)
                .appFont(.robotoRegular, size: 10)
                .foregroundColor(Color.Neutral500)
        }
    }
}
