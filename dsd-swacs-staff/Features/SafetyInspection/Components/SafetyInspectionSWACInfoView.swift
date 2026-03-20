//
//  SafetyInspectionSWACInfoView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 29/10/2025.
//

import SwiftUI

struct SafetyInspectionSWACInfoView: View {
    let swacDetail: SWACDetail
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            InfoRowView(title: "safety_inspection_detail_label_contract_title".localized(), value: swacDetail.contractTitle)
            
            HStack(alignment: .top, spacing: 8) {
                InfoRowView(title: "safety_inspection_detail_label_contract_no".localized(), value: swacDetail.contractNumber)
                InfoRowView(title: "safety_inspection_detail_label_swac_no".localized(), value: swacDetail.number)
            }
            
            HStack(alignment: .top, spacing: 8) {
                InfoRowView(title: "safety_inspection_detail_label_work_order_no".localized(), value: swacDetail.worksOrderNumber)
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
