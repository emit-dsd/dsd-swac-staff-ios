//
//  SignedStatus.swift
//  dsd-swacs-staff
//
//  Created by Andy on 1/9/2025.
//

import SwiftUI

struct SignedStatus: View {
    let siteDiary : SiteDiary

    var body: some View {
        HStack(alignment: .center, spacing: 0) {
//            signedItem(isSigned: siteDiary.siteRecord.contractorSigned, text: "site_diary_card_label_contractor_signed".localized())
//            signedItem(isSigned: siteDiary.siteRecord.staffSigned, text: "site_diary_card_label_staff_signed".localized())
//            signedItem(isSigned: siteDiary.siteRecord.erSigned, text: "site_diary_card_label_er_signed".localized())
        }
        .padding(0)
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    @ViewBuilder
    private func signedItem(isSigned: Bool, text: String) -> some View {
        HStack(alignment: .center, spacing: 8) {
            Image(isSigned ? "radio-button-selected" : "radio-button")
                .resizable()
                .frame(width: 20, height: 20)
            Text(text)
                .appFont(.robotoRegular, size: 10)
                .multilineTextAlignment(.center)
                .foregroundColor(Color.Neutral500)
                .frame(width: 60, alignment: .top)
        }
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: .center)
    }
}
