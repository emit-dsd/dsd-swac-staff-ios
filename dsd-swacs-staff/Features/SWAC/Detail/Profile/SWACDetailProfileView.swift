//
//  SWACDetailProfileView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/8/2025.
//

import SwiftUI

struct SWACDetailProfileView: View {
    let swacDetail: SWACDetail
    
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    InfoRowView(title: "swac_card_label_contract_title".localized(), value: swacDetail.contractTitle)
                    HStack(spacing: 24) {
                        StatusTag(status: swacDetail.status)
                        
                        Spacer(minLength: 4)
                        
                        HighRiskIndicator(showTypes: [swacDetail.isConfinedSpaceWorks,false,false])
                    }
                }
                
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "swac_card_label_contract_no".localized(), value: swacDetail.contractNumber)
                    InfoRowView(title: "swac_card_label_swac_no".localized(), value: swacDetail.number)
                }
                
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "swac_detail_label_startTime".localized(), value: swacDetail.startTime.toString(format: "yyyy-MM-dd"))
                    InfoRowView(title: "swac_detail_label_endTime".localized(), value: swacDetail.finishTime.toString(format: "yyyy-MM-dd"))
                }
                
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "swac_card_label_work_order_no".localized(), value: swacDetail.worksOrderNumber)
//                    InfoRowView(title: "swac_card_label_reference_number".localized(), value: swac.referenceNumber)
                }
                
                HStack(alignment: .top, spacing: 24) {
                    InfoRowView(title: "swac_card_label_contractor_name".localized(), value: swacDetail.contractor)
                    InfoRowView(title: "swac_card_label_contractor_phone".localized(), value: swacDetail.contractorPhone)
                }
                
                InfoRowView(title: "swac_card_label_location".localized(), value: swacDetail.location)
                
                InfoRowView(title: "swac_card_label_regional_control_centre".localized(), value: swacDetail.regionalControlCentreEng + " " +  swacDetail.regionalControlCenterChi)
                
                InfoRowView(title: "swac_card_label_project_in_charge".localized(), value: swacDetail.projectInCharge)
                
                InfoRowView(title: "swac_card_label_site_in_charge".localized(), value: swacDetail.siteInCharge)
                
                InfoRowView(title: "swac_card_label_works_detail".localized(), value: swacDetail.worksDetailsPlainText)
                Spacer()
            }
            .padding(.top, 12)
            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .background(Color.white)
        }
        .contentMargins(.horizontal, 16, for: .scrollContent)
        .contentMargins(.bottom, 16, for: .scrollContent)
    }
}

// MARK: - Preview Helper
#if DEBUG
extension SWACDetail {
    static let preview = SWACDetail(
        from: SWACDetailResponse(
            number: "001D",
            contractNumber: "4108CD",
            contractTitle: "西九龍雨水排放系統改善計劃",
            worksOrderNumber: "4108CD",
            isConfinedSpaceWorks: false,
            startTime: "2025-05-01 09:00",
            finishTime: "2025-05-30 18:00",
            state: 5,
            createTime: "2025-05-01 08:00:00",
            submitTime: "2025-05-01 08:30:00",
            contractor: "Bouygues Travaux Publics",
            contractorID: "4108CD",
            contratcorPhone: "12345678",
            projectInCharge: "Ronnie Fong 方鎧山 PM(IT)/ST2/2",
            siteInCharge: "Ronnie Fong 方鎧山 PM(IT)/ST2/2",
            location: "九龍城區堅全下坑門水塘",
            worksDetails: "-",
            regionalControlCentreEng: "Kowloon City RCC",
            regionalControlCenterChi: "九龍城區域控制中心",
            latitude: 22.3193,
            longitude: 114.1694,
            regionalControlCentre: 7
        )
    )
}

struct SWACDetailProfileView_Previews: PreviewProvider {
    static var previews: some View {
        SWACDetailProfileView(swacDetail: .preview)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
#endif
