import SwiftUI

struct SiteWorkCard: View {
    let siteWork: SiteWork
    
    var body: some View {
        ZStack(alignment: .topTrailing) {
            VStack(alignment: .leading, spacing: 12) {
                // Top section with contract details
                
                InfoRowView(title: "site_work_card_label_contract_title".localized(), value: siteWork.contractTitle)
                
                HStack(spacing: 8){
                    InfoRowView(title: "site_work_card_label_work_order_no".localized(), value: siteWork.workOrderNo)
                    InfoRowView(title: "site_work_card_label_swac_no".localized(), value: siteWork.swacNo)
                }
                
                // Bottom section with worker stats
                if siteWork.totalWorkers == 0 {
                    HStack {
                        Spacer()
                        VStack(spacing: 6) {
                            Text("site_work_card_status_no_worker".localized())
                                .appFont(.robotoBold, size: 24)
                                .foregroundColor(Color.Neutral500)
                            
                            Text("site_work_card_label_signed_in".localized())
                                .appFont(.robotoRegular, size: 14)                                .foregroundColor(Color.Neutral500)
                        }
                        Spacer()
                    }
                    .padding(.bottom,13)
                } else {
             
                    HStack {
                      
                        VStack(spacing: 6) {
                            Text("\(siteWork.signedIn)")
                                .appFont(.robotoBold, size: 24)
                                .foregroundColor(Color.Primary500)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .top)
                          
                            
                            Text("site_work_card_label_signed_in".localized())
                                .appFont(.robotoRegular, size: 14)
                                .foregroundColor(Color.Neutral500)
                                .multilineTextAlignment(.center)
                                .frame(maxWidth: .infinity, alignment: .top)
                        }
                     
                        
                        Divider().frame(height: 47)
                        
                      
                        
//                        if siteWork.isCompleted {
                            ZStack {
                                if siteWork.signedIn == siteWork.signedOut {
                                    HStack(alignment: .center, spacing: 10) {
                                 
                                        Image("sitecard-done-indicator")
                                            .resizable()
                                            .frame(width: 22, height:22)
                                        Spacer()
                                    }
                                    .padding(.horizontal)
                                }
                                
                                VStack(spacing: 6) {
                                    Text("\(siteWork.signedOut)/\(siteWork.totalWorkers)")
                                        .appFont(.robotoBold, size: 24)
                                        .foregroundColor(siteWork.signedIn == siteWork.signedOut ? .Primary500 : Color.notificationRed)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, alignment: .top)
                                    
                                    Text("site_work_card_label_signed_out".localized())
                                        .appFont(.robotoRegular, size: 14)
                                        .foregroundColor(Color.Neutral500)
                                        .multilineTextAlignment(.center)
                                        .frame(maxWidth: .infinity, alignment: .top)
                                }
                            }
                            
                            
//                        }
                   
                    }
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 24)
            .frame(maxWidth: .infinity, minHeight: 200, maxHeight: 200, alignment: .topLeading)
            .background(
                LinearGradient(
                    stops: [
                        Gradient.Stop(color: Color.Primary100, location: 0.00),
                        Gradient.Stop(color: Color.white, location: 1.00),
                    ],
                    startPoint: UnitPoint(x: 0.5, y: 0),
                    endPoint: UnitPoint(x: 0.5, y: 0.5)
                )
            )
            .cornerRadius(8)
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .inset(by: 0.5)
                    .stroke(Color.Neutral200, lineWidth: 1)
            )
            
            Image("sitecard-arrow-icon")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(12)
        }
    }
}

struct SiteWorkCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            SiteWorkCard(
                siteWork: SiteWork(
                    contractTitle: "西九龍雨水排放系統改善計劃",
                    workOrderNo: "4108CD",
                    swacNo: "001D",
                    signedIn: 12,
                    signedOut: 6,
                    totalWorkers: 12
                )
            )
            
            SiteWorkCard(
                siteWork: SiteWork(
                    contractTitle: "西九龍雨水排放系統改善計劃",
                    workOrderNo: "4108CD",
                    swacNo: "001D",
                    signedIn: 12,
                    signedOut: 12,
                    totalWorkers: 12
                )
            )
            
            SiteWorkCard(
                siteWork: SiteWork(
                    contractTitle: "西九龍雨水排放系統改善計劃",
                    workOrderNo: "4108CD",
                    swacNo: "001D",
                    signedIn: 0,
                    signedOut: 6,
                    totalWorkers: 0
                )
            )
        }
    }
}
