//
//  SwiftUIView.swift
//  SiteWorkApp
//
//  Created by User on 21/7/2025.
//

import SwiftUI

struct NotificationButton: View {
    let action: () -> Void
      let badgeCount: Int

    var body: some View {
          ZStack(alignment: .topTrailing) {
              Button(action: action) {
                  Image("notification-icon") // 你的 bell icon
                      .resizable()
                      .frame(width: 36, height: 36)
              }

//              if badgeCount > 0 {
//                  VStack(alignment: .center, spacing: 10) {
//                      Text("\(badgeCount)")
//                        .font(Font.custom("Roboto", size: 8))
//                        .multilineTextAlignment(.center)
//                        .foregroundColor(Color.white)
//                        .padding(.horizontal, 2)
//                  }
//                  .padding(2)
//                  .frame(width:.infinity,height:14,alignment: .center)
//                  .background(Color.red)
//                  .clipShape(Capsule())
//                  .offset(x:4,y:-4)
//              }
              if badgeCount > 0 {
                     Text("\(badgeCount)")
                         .font(Font.custom("Roboto", size: 8))
                         .foregroundColor(.white)
                         .padding(.horizontal, 4.5)
                         .frame(height: 14)
                         .background(Color.red)
                         .clipShape(Capsule())
                         .alignmentGuide(.top) { d in d[.top] + 2 }
                         .alignmentGuide(.trailing) { d in d[.trailing] - 2 }
              }
          }
          .frame(width: 36, height: 36)
      }
}

#if DEBUG
#Preview {
    NotificationButton(action: {
        
    }, badgeCount:5)
}
#endif
