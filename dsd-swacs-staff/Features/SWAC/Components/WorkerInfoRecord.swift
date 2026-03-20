//
//  WorkerInfoRecord.swift
//  dsd-swacs-staff
//
//  Created by Andy on 22/10/2025.
//
import SwiftUI

struct WorkerInfoRecord: View {
    let attendance: Attendance
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .center, spacing: 8) {
                Text(attendance.dateFormatted)
                    .font(
                        Font.custom("Roboto", size: 14)
                            .weight(.bold)
                    )
                    .foregroundColor(Color.Neutral500)
                
                Rectangle()
                    .foregroundColor(.clear)
                    .frame(maxWidth: .infinity, maxHeight: 1)
//                    .frame(width: 277, height: 1)
                    .background(Color.Neutral500)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)
            
            HStack(alignment:.top, spacing: 24) {
                InfoRowView(title: "staff_card_label_sign_in".localized(), value: attendance.signInTimeFormatted)
                InfoRowView(title: "staff_card_label_sign_out".localized(), value: attendance.signOutTimeFormatted)
            }
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .topLeading)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.Primary100, location: 0.00),
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
}

#if DEBUG
struct WorkerInfoRecord_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ScrollView{
                WorkerInfoRecord(attendance: Attendance.signedInExample)
            }
        }
    }
}
#endif
