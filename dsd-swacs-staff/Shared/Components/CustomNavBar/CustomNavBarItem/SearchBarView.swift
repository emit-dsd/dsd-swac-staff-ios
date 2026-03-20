//
//  SearchBarView.swift
//  SiteWorkApp
//
//  Created by User on 21/7/2025.
//

import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var placeholder: String = ""
    
       var body: some View {
           HStack {
               TextField(placeholder, text: $searchText)
                   .blockEmoji($searchText)
                   .foregroundColor(Color.Neutral800)
                   .disableAutocorrection(true)
                   .overlay(
                    Image(systemName: "xmark.circle.fill")
                        .padding()
                        .offset(x: 10)
                        .foregroundColor(Color.Neutral500)
                        .opacity(searchText.isEmpty ? 0.0 : 1.0)
                        .onTapGesture {
                            //                               UIApplication.shared.endEditing()
                            searchText = ""
                        }
                    
                    ,alignment: .trailing
                   )
               
               Image("search-bar-Icon")
                   .frame(width: 16,height: 16)
           }
           .padding(.horizontal, 24)
           .padding(.vertical, 12)
           .frame(maxWidth: .infinity, alignment: .leading)
           .background(Color.Neutral100)
           .cornerRadius(100)
       }
}

struct SearchBarView_Previews: PreviewProvider {
    static var previews: some View {

            SearchBarView(searchText: .constant(""))
    }
}
