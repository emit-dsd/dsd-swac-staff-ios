//
//  SWACInfoView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

struct SWACInfoView: View {
    let swacDetail: SWACDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRowView(title: "site_diary_list_label_name_of_contractor".localized(), value: swacDetail.contractor)
            
            HStack(alignment: .top, spacing: 8) {
                InfoRowView(title: "site_diary_list_label_work_order_no".localized(), value: swacDetail.worksOrderNumber)
                InfoRowView(title: "site_diary_list_label_name_of_plant".localized(), value: swacDetail.regionalControlCentreEng + " " +  swacDetail.regionalControlCenterChi)
            }
            
            HStack(spacing: 4) {
                DateChip(dateText:swacDetail.startTime.toString(format: "yyyy-MM-dd"))
                
                Image("right-arrow-Icon")
                    .resizable()
                    .frame(width: 16, height: 16)
                
                DateChip(dateText:swacDetail.finishTime.toString(format: "yyyy-MM-dd"))
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .cornerRadius(16)
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .inset(by: 0.5)
                .stroke(Color.Neutral300, lineWidth: 1)
        )
    }
}

#if DEBUG
#Preview {
    SWACInfoView(swacDetail: SWACDetail(from: .preview))
}

#Preview("Vetting Status") {
    SWACInfoView(swacDetail: SWACDetail(from: .previewVetting))
}
#endif
