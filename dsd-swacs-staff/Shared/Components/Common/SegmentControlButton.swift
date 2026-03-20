//
//  SegmentControlButton.swift
//  DSD_SWACS
//
//  Created by Andy on 25/7/2025.
//
import SwiftUI


struct SegmentControlButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("Roboto", size: 16))
                .foregroundColor(isSelected ? .Primary800 : .Neutral300)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 8)
                .padding(.horizontal, 24)
        }
        .background(
            VStack {
                Spacer()
                Rectangle()
                    .frame(height: 2)
                    .foregroundColor(isSelected ? .Primary800 : .Neutral300)
            }
        )
    }
}

struct SegmentControlButton_Previews: PreviewProvider {
    static var previews: some View {
        SegmentControlButton(
            title: "test",
            isSelected: true,
            action: {}
        )
    }
}
