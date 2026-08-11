import SwiftUI

struct CSWRCard: View {
    let swac: SWACListItem
    var actionTitle: String = "today_swac_button_approve_entry".localized()
    var actionButtonStyle: CommonButtonStyle = .contained
    var onActionButtonTapped: (SWACListItem) -> Void = { _ in }
    
    private var cswrStatusDisplayString: String {
        if let status = SiteWorkState(rawValue: swac.siteWorkstate) {
            return status.localizationKey.localized()
        }
        return "-"
    }

    private var actionTextColor: Color {
        switch actionButtonStyle {
        case .outlined:
            return .red
        case .contained, .text:
            return .white
        }
    }
    
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
                        InfoRowView(
                            title: "swac_card_label_cswr_ticket_no".localized(),
                            value: swac.ticket.map(String.init) ?? "-"
                        )
                    }
                    InfoRowView(title: "swac_card_label_cswr_status".localized(), value: cswrStatusDisplayString)
                    
                    HStack(alignment: .top, spacing: 24) {
                        InfoRowView(title: "swac_card_label_target_finish_time".localized(), value: swac.finishTime.toString(format: "yyyy-MM-dd HH:mm"))
                        Spacer(minLength: 4)
                        HighRiskIndicator(showTypes: [swac.isConfinedSpaceWorks,false,false])
                    }
                }
                
                    HStack(alignment: .top, spacing: 8) {
                        CommonButton(title: actionTitle,
                                     style: actionButtonStyle,
                                     enabled: true,
                                     maxWidth: .infinity,
                                     textColor: actionTextColor,
                                     backgroundColor: Color.red,
                                     action: {
                            onActionButtonTapped(swac)
                        })
                    }
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                
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
