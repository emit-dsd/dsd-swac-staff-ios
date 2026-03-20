//
//  AttendanceView.swift
//  SiteWorkApp
//
//  Created by User on 21/7/2025.
//

import SwiftUI

struct AttendanceView: View {
    @EnvironmentObject var tabStore: TabNavigationStore
    
    // Sample site work data
    private let siteWorks = [
        SiteWork(
            contractTitle: "西九龍雨水排放系統改善計劃",
            workOrderNo: "4108CD",
            swacNo: "001D",
            signedIn: 12,
            signedOut: 6,
            totalWorkers: 12

        ),
        SiteWork(
            contractTitle: "新界北部雨水排放系統改善計劃",
            workOrderNo: "4112CD",
            swacNo: "123G",
            signedIn: 12,
            signedOut: 12,
            totalWorkers: 12
        ),
        SiteWork(
            contractTitle: "元朗市明渠改善工程(市區中心段)",
            workOrderNo: "4161CD",
            swacNo: "321G",
            signedIn: 0,
            signedOut: 0,
            totalWorkers: 0
        ),
    ]
    
    // Card width + spacing
    private let cardWidth: CGFloat = 350
    private let cardSpacing: CGFloat = 8
    
    var body: some View {
        VStack(spacing: 0){
            CustomNavBarView(type: .searchBar)
            VStack(alignment: .leading, spacing: 8) {
                HStack(alignment: .center) {
                    Text("Select Your Site Work")
                        .appFont(.robotoBold, size: 18)
                        .foregroundColor(.Neutral800)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    Text("attendance_label_total_count".localized().replacingOccurrences(of: "{R1}", with: "\(siteWorks.count)"))
                        .appFont(.robotoRegular, size: 14)
                        .multilineTextAlignment(.trailing)
                        .foregroundColor(Color.Neutral500)
                    
                }
                .frame(maxWidth: .infinity, alignment: .center)
                
                ScrollView {
                    VStack(spacing: 8) {
                        ForEach(siteWorks, id: \.workOrderNo) { siteWork in
                            SiteWorkCard(siteWork: siteWork)
                                .onTapGesture {
                                    tabStore.appendToCurrentPath(Screen.attendanceDetail(siteWork))
                                }
                                .contentShape(Rectangle())
                        }
                    }
                    .padding(.bottom, 32)
                }
                
            }
            .padding(.horizontal, 16)
            .padding(.top, 24)
            .padding(.bottom, 0)
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading)
            .background(Color.white)
        }
        .background(Color.white)
    }
}

#if DEBUG
#Preview {
    AttendanceView().environmentObject(TabNavigationStore())
}
#endif
