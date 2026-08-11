//
//  SiteDiaryCard.swift
//  dsd-swacs-staff
//
//  Created by Andy on 2/9/2025.
//

import SwiftUI

struct SiteDiaryCard: View {
    let siteDiary: SiteDiary
    
    var body: some View{
        VStack(alignment: .leading, spacing: 12) {
            InfoRowView(title: "site_diary_card_label_brief_description".localized(), value: siteDiary.workActivity)
            
            HStack(spacing: 12) {
                VStack(alignment: .leading, spacing: 12) {
                    InfoRowView(title: "site_diary_card_label_contractor_rep".localized(), value: siteDiary.contractor ?? "-")
                    InfoRowView(title: "site_diary_card_label_dsd_rep".localized(), value: siteDiary.siteInCharge ?? "-")
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                
                WeatherStatusView(
                    weatherAM: siteDiary.weatherStatusAM,
                    weatherPM: siteDiary.weatherStatusPM
                )
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
            
//            SignedStatus(siteDiary: siteDiary)
            
            HStack(spacing: 2) {
                StatusTag(status: siteDiary.status)
                Spacer()
                DateChip(dateText: siteDiary.dateDisplayString)
            }
            
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 24)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: siteDiary.status.gradientColor, location: 0.00),
                    Gradient.Stop(color: .white, location: 1.00),
                ],
                startPoint: UnitPoint(x: 0.5, y: 0),
                endPoint: UnitPoint(x: 0.5, y: 0.5)
            )
        )
        .cornerRadius(8)
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .inset(by: 0.5)
                .stroke(Color.Neutral200, lineWidth: 1)
        )
    }
}

#if DEBUG
struct SiteDiaryCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ScrollView {
                ForEach(SiteDiary.previewList) { diary in
                    SiteDiaryCard(siteDiary: diary)
                }
            }
        }
    }
}
#endif
