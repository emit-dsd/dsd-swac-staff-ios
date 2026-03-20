//
//  QuickActionView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 4/8/2025.
//

import SwiftUI

struct QuickActionView: View {
    let actions: [(imageName: String, caption: String, action: () -> Void)]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(alignment: .top) {
                ForEach(Array(actions.enumerated()), id: \.0) { index, actionItem in
                    QuickActionIcon(
                        imageName: actionItem.imageName,
                        caption: actionItem.caption,
                        action: actionItem.action
                    )
                }
            }
            .frame(maxWidth: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct QuickActionIcon: View {
    let imageName: String
    let caption: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .center, spacing: 8) {
                
                Image(imageName)
                    .frame(width: 48, height: 48, alignment: .center)
                    .background(Color(red: 0.91, green: 0.98, blue: 1))
                    .cornerRadius(100)
                
                // Caption/Regular
                Text(caption.localized())
                    .appFont(.robotoRegular, size: 12)
                    .multilineTextAlignment(.center)
                    .foregroundColor(Color.Neutral800)
                    .frame(maxWidth: .infinity, alignment: .top)
            }
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#if DEBUG
#Preview {
    QuickActionView(actions: [
        (imageName: "quick-action-scan-qrcode", caption: "Scan Access QR Code", action: { print("Scan Access QR Code pressed") }),
        (imageName: "quick-action-new-site-diary", caption: "New Site Diary", action: { print("New Site Diary pressed") }),
        (imageName: "quick-action-safety-inspection", caption: "Safety Inspection", action: { print("Safety Inspection pressed") }),
        (imageName: "quick-action-incident-report", caption: "Brief Incident Report", action: { print("Brief Incident Report pressed") })
    ])
}
#endif
