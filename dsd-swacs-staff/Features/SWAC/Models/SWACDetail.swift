//
//  SWACDetail.swift
//  dsd-swacs-staff
//
//  Created by Andy on 6/11/2025.
//

import Foundation


struct SWACDetail: Equatable {
    let number: String
    let contractNumber: String
    let contractTitle: String
    let worksOrderNumber: String
    let isConfinedSpaceWorks: Bool
    let startTime: Date
    let finishTime: Date
    let state: Int
    let createTime: Date
    let submitTime: Date
    let contractor: String
    let contractorID: String
    let contractorPhone: String
    let projectInCharge: String
    let siteInCharge: String
    let location: String
    let worksDetails: String
    let worksDetailsPlainText: String
    let regionalControlCentreEng: String
    let regionalControlCenterChi: String
    let latitude: Double
    let longitude: Double
    let regionalControlCentre: Int
    
    var status: SWACStatus {
        return SWACStatus(stateInt: state) ?? .draft
    }
    
    private static func convertHtmlToPlainText(_ html: String) -> String {
        guard let data = html.data(using: .utf8) else { return html }
        do {
            let attributedString = try NSAttributedString(
                data: data,
                options: [.documentType: NSAttributedString.DocumentType.html,
                          .characterEncoding: String.Encoding.utf8.rawValue],
                documentAttributes: nil)
            
            let plainText = attributedString.string.trimmingCharacters(in: .whitespacesAndNewlines)
            return plainText.isEmpty ? "-" : plainText
        } catch {
            return html
        }
    }
    
    // Convert from Response
    init(from response: SWACDetailResponse) {
        self.number = response.number
        self.contractNumber = response.contractNumber ?? "-"
        self.contractTitle = response.contractTitle ?? "-"
        self.worksOrderNumber = response.worksOrderNumber ?? "-"
        self.isConfinedSpaceWorks = response.isConfinedSpaceWorks ?? false
        self.state = response.state
        self.contractor = response.contractor ?? "-"
        self.contractorID = response.contractorID ?? "-"
        self.contractorPhone = response.contratcorPhone ?? "-"
        self.projectInCharge = response.projectInCharge ?? "-"
        self.siteInCharge = response.siteInCharge ?? "-"
        self.location = response.location ?? "-"
        self.worksDetails = response.worksDetails ?? "-"
        self.worksDetailsPlainText = Self.convertHtmlToPlainText(self.worksDetails)
        self.regionalControlCentreEng = response.regionalControlCentreEng ?? "-"
        self.regionalControlCenterChi = response.regionalControlCenterChi ?? "-"
        self.latitude = response.latitude ?? 0.0
        self.longitude = response.longitude ?? 0.0
        self.regionalControlCentre = response.regionalControlCentre ?? 0
        
        // Parse dates
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        
        self.startTime = formatter.date(from: response.startTime ?? "") ?? Date()
        self.finishTime = formatter.date(from: response.finishTime ?? "") ?? Date()
        
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        self.createTime = formatter.date(from: response.createTime ?? "") ?? Date()
        self.submitTime = formatter.date(from: response.submitTime ?? "") ?? Date()
    }
    
    static func == (lhs: SWACDetail, rhs: SWACDetail) -> Bool {
        return lhs.number == rhs.number && lhs.state == rhs.state
    }
}


#if DEBUG
extension SWACDetailResponse {
    static let preview = SWACDetailResponse(
        number: "001D",
        contractNumber: "4108CD",
        contractTitle: "西九龍雨水排放系統改善計劃",
        worksOrderNumber: "4108CD",
        isConfinedSpaceWorks: false,
        startTime: "2025-05-01 00:00",
        finishTime: "2025-05-30 23:59",
        state: 5,
        createTime: "2025-05-01 00:00:00",
        submitTime: "2025-05-01 00:00:00",
        contractor: "Bouygues Travaux Publics",
        contractorID: "4108CD",
        contratcorPhone: "12345678",
        projectInCharge: "Ronnie Fong 方鎧山 PM(IT)/ST2/2",
        siteInCharge: "Ronnie Fong 方鎧山 PM(IT)/ST2/2",
        location: "九龍城區堅全下坑門水塘",
        worksDetails: "<p>工程詳情</p>",
        regionalControlCentreEng: "Stonecutters Island STW",
        regionalControlCenterChi: "昂船洲污水處理廠",
        latitude: 22.326229,
        longitude: 114.138734,
        regionalControlCentre: 7
    )
    
    static let previewVetting = SWACDetailResponse(
        number: "002D",
        contractNumber: "5208CD",
        contractTitle: "港島東污水處理系統優化工程",
        worksOrderNumber: "5208CD",
        isConfinedSpaceWorks: true,
        startTime: "2025-06-01 00:00",
        finishTime: "2025-08-30 23:59",
        state: 3,  // Vetting
        createTime: "2025-05-15 00:00:00",
        submitTime: "2025-05-15 00:00:00",
        contractor: "China State Construction",
        contractorID: "5208CD",
        contratcorPhone: "87654321",
        projectInCharge: "Peter Chan 陳大文 PM(IT)/ST3/1",
        siteInCharge: "Mary Wong 黃小明 AEI/ST3/1/2",
        location: "香港島柴灣道",
        worksDetails: "<p>優化工程內容</p>",
        regionalControlCentreEng: "Chai Wan STW",
        regionalControlCenterChi: "柴灣污水處理廠",
        latitude: 22.267,
        longitude: 114.237,
        regionalControlCentre: 7
    )
}
#endif
