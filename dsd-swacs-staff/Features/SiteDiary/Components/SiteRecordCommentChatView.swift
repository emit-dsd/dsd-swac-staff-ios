//
//  SiteRecordCommentChatView.swift
//  dsd-swacs-staff
//
//  Created by Andy Lee on 30/10/2025.
//

import SwiftUI

struct SiteRecordCommentChatView: View {
    @ObservedObject var userSession = UserSession.shared
    let comment: SiteRecordComment
   
    
    var body: some View {
        HStack {
    
            if comment.createdBy == userSession.profile?.nameEng {
                Spacer()
                Bubble(content: comment.content, time: comment.createdDate, right: true)
            } else {
                Bubble(content: comment.content, time: comment.createdDate, right: false)
                Spacer()
            }
        }
        .background(Color.Neutral100 )
    }
}

// Message Bubble樣式
struct Bubble: View {
    let content: String
    let time: String
    let right: Bool

    var body: some View {
        VStack(alignment: right ? .trailing : .leading, spacing: 8) {
            
            VStack(alignment: right ? .trailing : .leading, spacing: 2){
                Text(right ? "site_diary_detail_label_instructions_representative".localized() : "site_diary_detail_label_response_representative".localized())
                    .appFont(.robotoRegular, size: 15)
                    .foregroundColor(Color.Neutral500)
                    .multilineTextAlignment(right ? .trailing : .leading)
                Text(content)
                    .appFont(.robotoBold, size: 16)
                    .foregroundColor(Color.Primary800)
                    .multilineTextAlignment(right ? .trailing : .leading)
            }
           
            Text(time)
                .appFont(.robotoRegular, size: 15)
                .foregroundColor(Color.Neutral500)
                .multilineTextAlignment(right ? .trailing : .leading)
        }
        .padding(.leading, right ? 0 : 16)
        .padding(.trailing,right ? 16 : 0)
        .padding(.vertical, 8)
        .frame(maxWidth: .infinity, alignment: right ? .trailing : .leading)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(right ? Color.Neutral500 : Color.Primary500),
            alignment: right ? .trailing : .leading
        )
    }
}
