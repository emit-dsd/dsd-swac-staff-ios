//
//  IncidentReportCard.swift
//  dsd-swacs-staff
//
//  Created by Andy on 9/2/2026.
//

import SwiftUI

struct IncidentReportCard: View {
    let report: IncidentReport
    
    var body: some View{
        VStack(alignment: .leading, spacing: 12) {

            InfoRowView(title: "incident_report_list_label_reference_no".localized(), value: report.reportNumber)
            HStack(alignment: .top, spacing: 12) {
                InfoRowView(title: "incident_report_list_label_incident_date".localized(), value: report.formattedOccurenceDateTime)
                InfoRowView(title: "incident_report_list_label_create_date".localized(), value: report.formattedSubmissionDateTime)
            }
            HStack(alignment: .top, spacing: 12) {
                InfoRowView(title: "incident_report_list_label_swac_no".localized(), value: report.swac)
                InfoRowView(title: "incident_report_list_label_location".localized(), value: report.location)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.Neutral100)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(Color.Primary800),
            alignment: .leading
        )
    }
}
