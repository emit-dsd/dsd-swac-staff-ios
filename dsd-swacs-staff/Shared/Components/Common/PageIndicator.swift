import SwiftUI

struct PageIndicator: View {
    let currentPage: Int
    let pageCount: Int
    
    var body: some View {
        HStack(spacing: 4) {
            ForEach(0..<pageCount, id: \.self) { index in
                Capsule()
                    .fill(currentPage == index ? .Primary800 : Color.Neutral500)
                    .frame(width: currentPage == index ? 60 : 36, height: 6)
            }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .animation(.easeInOut, value: currentPage)
    }
}

struct PageIndicator_Previews: PreviewProvider {
    static var previews: some View {
        PageIndicator(currentPage: 0, pageCount: 5)
            .previewLayout(.sizeThatFits)
            .padding()
    }
}
