import SwiftUI

struct SWACCard: View {
    let swac: SWACListItem
    var showActionButton: Bool = false
    var showCSWRStatus: Bool = false
    var onConfirmActionButtonTapped: (SWACListItem) -> Void = { _ in }
    var onRejectActionButtonTapped: (SWACListItem) -> Void = { _ in }
    
    enum CSWRStatus: Int, CaseIterable {
        case pendingForAcknowledgement = 1
        case pendingForMPS2Acknowledgement = 2
        case pendingForApproval = 3
        case confirmedEntry = 4
        case pendingForMPS1Checkout = 5
        case completed = 6
        case rejected = 7
        case recessInProgress = 8
        
        var localizationKey: String {
            switch self {
            case .pendingForAcknowledgement:
                return "cswr_status_label_pending_for_acknowledgement"
            case .pendingForMPS2Acknowledgement:
                return "cswr_status_label_pending_for_mps2_acknowledgement"
            case .pendingForApproval:
                return "cswr_status_label_pending_for_approval"
            case .confirmedEntry:
                return "cswr_status_label_confirmed_entry"
            case .pendingForMPS1Checkout:
                return "cswr_status_label_pending_for_mps1_checkout"
            case .completed:
                return "cswr_status_label_completed"
            case .rejected:
                return "cswr_status_label_rejected"
            case .recessInProgress:
                return "cswr_status_label_recess_in_progress"
            }
        }
    }
    
    private var cswrStatusDisplayString: String {
        if let status = CSWRStatus(rawValue: swac.siteWorkstate) {
            return status.localizationKey.localized()
        }
        return "-"
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
                        InfoRowView(title: "swac_card_label_contract_no".localized(), value: swac.contractNumber)
                    }
                    
                    HStack(alignment: .top, spacing: 12) {
                        InfoRowView(title: "swac_card_label_work_order_no".localized(), value: swac.worksOrderNumber ?? "-")
                    }
                    
                    HStack(spacing: 24) {
                        if showCSWRStatus {
                            InfoRowView(
                                title: "swac_card_label_cswr_status".localized(),
                                value: cswrStatusDisplayString,
                            )
                        } else {
                            StatusTag(status: swac.status)
                        }
                       
                        
                        Spacer(minLength: 4)
                        
                        HighRiskIndicator(showTypes: [swac.isConfinedSpaceWorks,false,false])
                    }
                    HStack(alignment: .center,spacing: 4) {
                        DateChip(dateText:swac.startTime.toString(format: "yyyy-MM-dd"), fillWidth: true)
                        
                        Image("right-arrow-Icon")
                            .resizable()
                            .frame(width: 16, height: 16)
                        
                        DateChip(dateText:swac.finishTime.toString(format: "yyyy-MM-dd"), fillWidth: true)
                    }
                }
                
                if swac.needSiteWorkStartApproval && showActionButton{
//                if showActionButton{
                    HStack(alignment: .top, spacing: 8) {
                        CommonButton(title: "today_swac_button_start_work".localized(),
                                     style: .contained,
                                     enabled: true,
                                     maxWidth: .infinity,
                                     textColor: Color.white,
                                     backgroundColor: Color.red,
                                     action: {
                            onConfirmActionButtonTapped(swac)
                        })
                        CommonButton(title: "today_swac_button_reject".localized(),
                                     style: .outlined,
                                     enabled: true,
                                     maxWidth: .infinity,
                                     textColor: Color.red,
                                     backgroundColor: Color.red,
                                     action: {
                            onRejectActionButtonTapped(swac)
                        })
                    }
                    .padding(0)
                    .frame(maxWidth: .infinity, alignment: .topLeading)
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
