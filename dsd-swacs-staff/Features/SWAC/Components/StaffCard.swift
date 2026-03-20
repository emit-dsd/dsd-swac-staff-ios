//
//  StaffCard.swift
//  dsd-swacs-staff
//
//  Created by Andy on 7/8/2025.
//

import SwiftUI

struct StaffCard: View {
    let attendance: Attendance
    
    func formattedTime(_ timestamp: Int?) -> String {
        guard let ts = timestamp, ts > 0 else { return "-" }
        let date = Date(timeIntervalSince1970: TimeInterval(ts))
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        return formatter.string(from: date)
    }
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment:.top, spacing: 24) {
                InfoRowView(title: "staff_card_label_name".localized(), value: attendance.member)
                InfoRowView(title: "staff_card_label_role".localized(), value: attendance.memberRole)
            }
            
            HStack(alignment:.top, spacing: 24) {
                InfoRowView(title: "staff_card_label_sign_in".localized(), value: attendance.signIn ?? "-")
                InfoRowView(title: "staff_card_label_sign_out".localized(), value: attendance.signOut ?? "-")
            }
            
            
            HStack(alignment: .center) {
                // Space Between
                StatusTag(status: attendance.status)
                Spacer()
//                HStack(alignment:.center, spacing: 24) {
//                    CommonButton(title: "staff_card_button_pdf".localized(),
//                                 style: .text,
//                                 enabled: true,
//                                 icon: Image("pdf-icon")) {
//                        
//                    }
//                    CommonButton(title: "staff_card_button_share_link".localized(),
//                                 style: .text,
//                                 enabled: true,
//                                 icon: Image("attendance-share-link-icon")) {
//                        
//                    }
//                }
            }
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: attendance.status.linearGradientColor, location: 0.00),
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
#Preview {
    VStack(spacing: 12) {
        StaffCard(attendance: .signedOutExample)
        StaffCard(attendance: .signedInExample)
        StaffCard(attendance: .noRecordExample)
    }
}
#endif
