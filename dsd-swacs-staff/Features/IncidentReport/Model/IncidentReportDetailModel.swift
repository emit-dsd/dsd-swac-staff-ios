//
//  IncidentReportDetailModel.swift
//  dsd-swacs-staff
//
//  Created by Andy on 17/11/2025.
//

import Foundation

struct IncidentReportDetailModel {
    let referenceNo: String
    let date: String
    let time: String
    let swacNo: String
    let location: String
    let brief: String
    let hasCasualty: Bool
    let hasMedia: Bool
    let hasParamedic: Bool
    let hasFirefighter: Bool
    let hasPoliceOfficer: Bool
    let contactPerson: String
    let contractor: String
}
