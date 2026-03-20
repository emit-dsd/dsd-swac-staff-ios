//
//  DateChip.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

struct DateChip: View {
    let dateText: String
    var fillWidth: Bool = false
    
    var body: some View {
           HStack(alignment: .center, spacing: 4) {
               Image("date-chip")
                   .resizable()
                   .frame(width: 12, height: 12)
               Text(dateText)
                   .appFont(.robotoRegular, size: 14)
                   .foregroundColor(Color.Neutral500)
           }
           .padding(.horizontal, 8)
           .padding(.vertical, 4)
           .frame(maxWidth: fillWidth ? .infinity : nil, alignment: .center)
           .background(Color.Neutral200)
           .cornerRadius(100)
       }
}

#if DEBUG
#Preview {
    DateChip(dateText:"12-04-2002")
}
#endif
