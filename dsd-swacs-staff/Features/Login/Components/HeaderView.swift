import SwiftUI

struct HeaderView: View {
    @EnvironmentObject var languageManager: AppLanguageManager
    
    var body: some View {
        
        HStack(alignment: .center, spacing: 8) {
            HStack(alignment: .center, spacing: 0) {
                Image("dsd-logo")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 46, height: 51)
                    .clipped()
            }
    
            .frame(width: 60, height: 60, alignment: .center)
            
            VStack(alignment: .leading, spacing: 4) {
                Text("login_label_department_title".localized())
                    .appFont(.robotoRegular, size: 20)
                    .foregroundColor(.Primary600)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                Text("login_label_system_title".localized())
                    .appFont(.robotoBold, size: 22)
                    .foregroundColor(.Primary600)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
            }
            .padding(0)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.horizontal, 0)
        .padding(.top, 0)
        .padding(.bottom, 24)
        .frame(maxWidth: .infinity, alignment: .center)
        .shadow(color: .black.opacity(0.1), radius: 20, x: 0, y: 0)
        
    }
}

struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        HeaderView()
            .previewLayout(.sizeThatFits)
    }
}
