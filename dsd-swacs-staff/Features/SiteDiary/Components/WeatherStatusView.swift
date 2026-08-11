//
//  WeatherStatusView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 1/9/2025.
//

import SwiftUI

struct WeatherStatusView: View {
    let weatherAM: WeatherStatus?
    let weatherPM: WeatherStatus?
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("site_diary_card_label_status_of_weather".localized())
                .appFont(.robotoRegular, size: 14)
                .foregroundColor(Color.Neutral500)
            
            HStack(alignment: .center, spacing: 0) {
                weatherColumn(
                    title: "site_diary_detail_label_am".localized(),
                    status: weatherAM
                )
                weatherColumn(
                    title: "site_diary_detail_label_pm".localized(),
                    status: weatherPM
                )
            }
            .padding(.top, 12)
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
    
    @ViewBuilder
    private func weatherColumn(title: String, status: WeatherStatus?) -> some View {
        
        HStack(alignment: .center, spacing: 10) {
            HStack(alignment: .center, spacing: 10){
                Text(title)
                    .appFont(.robotoRegular, size: 10)
                    .foregroundColor(Color.Primary800)
            }
            .padding(0)
            
            HStack(alignment: .center, spacing: 10){
                if let status = status {
                    WeatherIconView(status: status)
                } else {
                    Text("--")
                        .appFont(.robotoRegular, size: 14)
                        .foregroundColor(Color.Neutral500)
                }
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

#if DEBUG
#Preview {
    VStack(spacing: 16) {
        WeatherStatusView(weatherAM: .fine, weatherPM: .rainy)
        WeatherStatusView(weatherAM: .cloudy, weatherPM: nil)
        WeatherStatusView(weatherAM: nil, weatherPM: nil)
    }
    .padding()
}
#endif
