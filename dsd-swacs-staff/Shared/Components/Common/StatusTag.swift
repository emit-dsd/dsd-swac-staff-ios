import SwiftUI


protocol StatusDisplayable {
    var displayText: String { get }
    var color: Color { get }
    var backgroundColor: Color { get }
}

extension SWACStatus: StatusDisplayable {}
extension AttendanceStatus: StatusDisplayable {}
extension SiteDiaryStatus: StatusDisplayable {}
extension SafetyInspectionStatus: StatusDisplayable {}

struct StatusTag<T: StatusDisplayable>: View {
    let status: T
    
    var body: some View {
         HStack(spacing: 10) {
             ZStack{
                 Circle()
                     .fill(status.color)
                     .frame(width: 8, height: 8)
                 
                 Circle()
                     .fill(status.color)
                     .frame(width: 12, height: 12)
                     .opacity(0.1)
             }
             
             Text(status.displayText)
                 .appFont(.robotoRegular, size: 14)
                 .foregroundColor(status.color)
         }
         .padding(.horizontal, 16)
         .padding(.vertical, 8)
         .background(status.backgroundColor)
         .cornerRadius(100)
     }
}

struct StatusTag_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView{
            VStack(spacing: 44) {
                VStack(spacing: 12) {
                    Text("SWAC Status")
                    ForEach(SWACStatus.allCases, id: \.self) { status in
                        StatusTag(status: status)
                    }
                }
                VStack(spacing: 12) {
                    Text("Attendance Status")
                    ForEach(AttendanceStatus.allCases, id: \.self) { status in
                        StatusTag(status: status)
                    }
                }
                VStack(spacing: 12) {
                    Text("Site Diary Status")
                    ForEach(SiteDiaryStatus.allCases, id: \.self) { status in
                        StatusTag(status: status)
                    }
                }
                
                VStack(spacing: 12) {
                    Text("Site Diary Status")
                    ForEach(SafetyInspectionStatus.allCases, id: \.self) { status in
                        StatusTag(status: status)
                    }
                }
            }
        }
        .padding()
        .background(Color.white)
    }
}
