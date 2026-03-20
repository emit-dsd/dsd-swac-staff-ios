//
//  SiteDiarySWACCard.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 28/10/2025.
//

import SwiftUI

struct SafetyInspectionSWACCard: View {
    let swac: SWACListItem
    
    func formattedInspectionDate(_ date: Date?) -> String {
        guard let date = date else {
            return "-"  // 或者返回你想要的預設值
        }
        
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: date)
    }
    
    var body: some View{
        VStack(alignment: .leading, spacing: 12) {

            InfoRowView(title: "safety_inspection_main_label_contractor_name".localized(), value: swac.contractor, titleLineLimit: 1)
            HStack(alignment: .top, spacing: 12) {
                InfoRowView(title: "safety_inspection_main_label_swac_no".localized(), value: swac.number)
                InfoRowView(title: "safety_inspection_main_label_work_order_no".localized(), value: swac.worksOrderNumber ?? "-")
            }
//            InfoRowView(title: "safety_inspection_main_label_last_inspection_date".localized(), value: formattedInspectionDate(Date()))
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.Neutral100)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(swac.status.color),
            alignment: .leading
        )
    }
}

struct SafetyInspectionSWACCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ScrollView{
                SafetyInspectionSWACCard(
                    swac: SWACListItem(from: SWACListItemResponse(
                        number: "001D",
                        contractNumber: "4108CD",
                        contractor: "Comp Name",
                        contractTitle: "西九龍雨水排放系統改善計劃",
                        worksOrderNumber: "4108CD",
                        isConfinedSpaceWorks: false,
                        startTime: "2025-05-01T00:00:00Z",
                        finishTime: "2025-05-30T23:59:59Z",
                        state: 3,
                        needSiteWorkStartApproval: false,
                        canSubmitSafetyInspectionReport:false,
                        siteWorkID: 0,
                        siteWorkstate: 0,
                    ))
                )
            }
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
