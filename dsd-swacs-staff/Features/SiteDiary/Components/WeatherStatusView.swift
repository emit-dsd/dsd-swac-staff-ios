//
//  WeatherStatusView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 1/9/2025.
//

import SwiftUI

struct WeatherStatusView: View {
    let status: WeatherStatus
    
    var body: some View {
        VStack(alignment: .center, spacing: 8) {
            Text("site_diary_card_label_status_of_weather".localized())
                .appFont(.robotoRegular, size: 14)
              .foregroundColor(Color.Neutral500)
            
            HStack(alignment: .center, spacing: 10) {
                WeatherIconView(status: status)
            }
            .padding(0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        }
        .padding(.vertical, 4)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }
}

#if DEBUG
#Preview {
    WeatherStatusView(status: .cloudy)
}
#endif
