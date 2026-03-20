//
//  SWACDetailEventLogView.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/8/2025.
//

import SwiftUI

struct SWACDetailEventLogView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                
//                NotificationListView(items: [])
                Spacer()
            }
            .frame(maxWidth: .infinity, alignment: .topLeading)
//            .background(Color.white)
        }
    }
}

#if DEBUG
#Preview {
    SWACDetailEventLogView()
}
#endif
