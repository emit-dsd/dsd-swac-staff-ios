import SwiftUI

struct HomeSWACCard: View {
    let swac: SWACListItem
    var showActionButton: Bool = false
    var onActionButtonTapped: (SWACListItem) -> Void = { _ in }
    
    var body: some View{
        ZStack(alignment: .topTrailing) {
            Image("icon-swac-arrow")
                .resizable()
                .frame(width: 24, height: 24)
                .padding(16)
            
            VStack(alignment: .leading, spacing: 16) {
                VStack(alignment: .leading, spacing: 12) {
                    
                    InfoRowView(title: "swac_card_label_contractor_name".localized(), value: swac.contractor, titleLineLimit: 1)
                    
                    HStack(alignment: .top, spacing: 12) {
                        InfoRowView(title: "swac_card_label_swac_no".localized(), value: swac.number)
                        InfoRowView(title: "swac_card_label_contract_no".localized(), value: swac.contractNumber)
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        InfoRowView(title: "swac_card_label_work_order_no".localized(), value: swac.worksOrderNumber ?? "-")
                        HighRiskIndicator(showTypes: [swac.isConfinedSpaceWorks,false,false])
                    }
                    
//                    HStack(spacing: 24) {
//                        StatusTag(status: swac.status)
//                        
//                        Spacer(minLength: 4)
//                        
//                        HighRiskIndicator(showTypes: [swac.isConfinedSpaceWorks,false,false])
//                    }
//                    
                    HStack(alignment: .center,spacing: 4) {
                        DateChip(dateText:swac.startTime.toString(format: "yyyy-MM-dd"), fillWidth: true)
                        
                        Image("right-arrow-Icon")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        DateChip(dateText:swac.finishTime.toString(format: "yyyy-MM-dd"), fillWidth: true)
                    }
                }
                
                if swac.needSiteWorkStartApproval && showActionButton {
                    CommonButton(title: "today_swac_button_start_work".localized(),
                                 style: .contained,
                                 enabled: true,
                                 maxWidth: .infinity,
                                 textColor: Color.white,
                                 backgroundColor: Color.red,
                                 action: {
                        onActionButtonTapped(swac)
                    })
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 24)
        }
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(
            LinearGradient(
                stops: [
                    Gradient.Stop(color: swac.status.gradientdColor, location: 0.00),
                    Gradient.Stop(color: .white, location: 1.00),
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
    }
}

struct HomeSWACCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            ScrollView{
                SWACCard(
                    swac: SWACListItem(from: SWACListItemResponse(
                        number: "001D",
                        contractNumber: "4108CD",
                        contractor: "Comp Name",
                        contractTitle: "西九龍雨水排放系統改善計劃",
                        worksOrderNumber: "4108CD",
                        isConfinedSpaceWorks: false,
                        startTime: "2025-05-01T00:00:00Z",
                        finishTime: "2025-05-30T23:59:59Z",
                        state: 5,
                        needSiteWorkStartApproval: false,
                        canSubmitSafetyInspectionReport:false,
                        siteWorkID: 0,
                        siteWorkstate: 0,
                    ))
                )
                SWACCard(
                    swac: SWACListItem(from: SWACListItemResponse(
                        number: "001D",
                        contractNumber: "4108CD",
                        contractor: "Comp Name",
                        contractTitle: "西九龍雨水排放系統改善計劃",
                        worksOrderNumber: "4108CD",
                        isConfinedSpaceWorks: false,
                        startTime: "2025-05-01T00:00:00Z",
                        finishTime: "2025-05-30T23:59:59Z",
                        state: 2,
                        needSiteWorkStartApproval: false,
                        canSubmitSafetyInspectionReport:false,
                        siteWorkID: 0,
                        siteWorkstate: 0,
                    ))
                )
                SWACCard(
                    swac: SWACListItem(from: SWACListItemResponse(
                        number: "001D",
                        contractNumber: "4108CD",
                        contractor: "Comp Name",
                        contractTitle: "西九龍雨水排放系統改善計劃",
                        worksOrderNumber: "4108CD",
                        isConfinedSpaceWorks: false,
                        startTime: "2025-05-01T00:00:00Z",
                        finishTime: "2025-05-30T23:59:59Z",
                        state: 3,
                        needSiteWorkStartApproval: false,
                        canSubmitSafetyInspectionReport:false,
                        siteWorkID: 0,
                        siteWorkstate: 0,
                    ))
                )
                SWACCard(
                    swac: SWACListItem(from: SWACListItemResponse(
                        number: "001D",
                        contractNumber: "4108CD",
                        contractor: "Comp Name",
                        contractTitle: "西九龍雨水排放系統改善計劃",
                        worksOrderNumber: "4108CD",
                        isConfinedSpaceWorks: false,
                        startTime: "2025-05-01T00:00:00Z",
                        finishTime: "2025-05-30T23:59:59Z",
                        state: 4,
                        needSiteWorkStartApproval: false,
                        canSubmitSafetyInspectionReport:false,
                        siteWorkID: 0,
                        siteWorkstate: 0,
                    ))
                )
            }
        }
        .previewLayout(.sizeThatFits)
        .padding()
    }
}
