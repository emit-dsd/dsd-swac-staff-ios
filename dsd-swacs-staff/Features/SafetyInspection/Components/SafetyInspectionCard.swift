//
//  SafetyInspectionCard.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/11/2025.
//

import SwiftUI

struct SafetyInspectionCard: View {
    let inspection: SafetyInspectionItem
    let canEdit: Bool
    let onViewCliecked: (SafetyInspectionItem) -> Void
    let onEditClicked: (SafetyInspectionItem) -> Void
    let onDraftEditClicked: (SafetyInspectionItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(inspection.worksDetail)
                .appFont(.robotoBold, size: 16 )
                .foregroundColor(.Primary800)
                .frame(maxWidth: .infinity, alignment: .topLeading)
            
            HStack(alignment: .top, spacing: 12) {
                InfoRowView(
                    title: "safety_inspection_list_label_report_no".localized(),
                    value: inspection.displayReportNumber
                )
                InfoRowView(
                    title: "safety_inspection_list_label_create Date".localized(),
                    value: inspection.formattedCreatedDate
                )
            }
            
            HStack(alignment: .top, spacing: 12) {
                InfoRowView(
                    title: "safety_inspection_list_label_last_inspection_date".localized(),
                    value: inspection.formattedInspectionDate
                )
                InfoRowView(
                    title: "safety_inspection_list_label_submitted_by".localized(),
                    value: inspection.submittedBy
                )
                
            }
            HStack(spacing: 24) {
                StatusTag(status: inspection.status)
                Spacer()
                
                if inspection.status == .draft {
                    CommonButton(title: "safety_inspection_list_button_edit".localized(),
                                 style: .text,
                                 enabled: true ,
                                 icon: Image("icon-edit"),
                                 iconSize: 16,
                                 isUnderline: true) {
                        onDraftEditClicked(inspection)
                    }
                }else if inspection.status == .pendingClose{
                    HStack(spacing: 24) {
                        CommonButton(title: "safety_inspection_list_button_view".localized(),
                                     style: .text,
                                     enabled: true ,
                                     icon: Image("icon-view"),
                                     iconSize: 16,
                                     isUnderline: true) {
                            onViewCliecked(inspection)
                        }
                        if canEdit {
                            CommonButton(title: "safety_inspection_list_button_edit".localized(),
                                         style: .text,
                                         enabled: true ,
                                         icon: Image("icon-edit"),
                                         iconSize: 16,
                                         isUnderline: true) {
                                onEditClicked(inspection)
                            }
                        }
                    }
                }else {
                    CommonButton(title: "safety_inspection_list_button_view".localized(),
                                 style: .text,
                                 enabled: true ,
                                 icon: Image("icon-view"),
                                 iconSize: 16,
                                 isUnderline: true) {
                        onViewCliecked(inspection)
                    }
                }
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 12)
        .frame(maxWidth: .infinity, alignment: .topLeading)
        .background(Color.Neutral100)
        .overlay(
            Rectangle()
                .frame(width: 4)
                .foregroundColor(inspection.status.color),
            alignment: .leading
        )
    }
}

#if DEBUG
#Preview("Card - Draft") {
    SafetyInspectionCard(
        inspection: .example,
        canEdit: true,
        onViewCliecked: { item in
            
        },onEditClicked: { item in
            
        },onDraftEditClicked: { inspection in
            
        }
    )
    .padding()
    .background(Color.clear)
}

#Preview("Card - Approved") {
    SafetyInspectionCard(
        inspection: .submittedExample,
        canEdit: true,
        onViewCliecked: { item in
            
        },onEditClicked: { item in
            
        },onDraftEditClicked: { inspection in
            
        }
    )
    .padding()
    .background(Color.clear)
}
#endif
