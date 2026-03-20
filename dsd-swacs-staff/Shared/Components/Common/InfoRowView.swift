import SwiftUI

struct InfoRowView: View {
    let title: String
    let value: String
    var titleColor: Color = Color.Neutral500
    var titleSize: CGFloat?
    var valueColor: Color = Color.Primary800
    var valueSize: CGFloat?
    var isInvertStyle: Bool = false
    var titleLineLimit: Int? = nil
    
    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            if isInvertStyle {
                Text(title)
                    .appFont(.robotoBold, size: titleSize ?? 16)
                    .foregroundColor(valueColor)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text(value)
                    .appFont(.robotoRegular, size: valueSize ?? 14)
                    .lineLimit(titleLineLimit)
                    .foregroundColor(titleColor)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            } else {
                Text(title)
                    .appFont(.robotoRegular, size: titleSize ?? 14)
                    .foregroundColor(titleColor)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
                Text(value)
                    .appFont(.robotoBold, size: valueSize ?? 16)
                    .lineLimit(titleLineLimit)
                    .foregroundColor(valueColor)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
    }
}

struct InfoRowView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 16) {
            InfoRowView(title: "SWAC No. (No Limit)", value: "001D")
            
            InfoRowView(
                title: "This is a very long title that should be truncated",
                value: "001D",
                titleLineLimit: 1
            )
            
            InfoRowView(title: "SWAC No.", value: "001D", valueColor: .red)
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
