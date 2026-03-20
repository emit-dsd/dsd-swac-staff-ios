//
//  UserProfile.swift
//  dsd-swacs-staff
//
//  Created by Andy on 25/8/2025.
//

import Foundation

struct UserProfile: Codable, Identifiable {
    var id: String { loginId }
    let loginId: String
    let email: String
    let nameEn: String
    let nameZh: String
    let division: String
    let post: String
    let officePhone: String
    let mobilePhone: String
}

let mockAboutYou = UserProfile(
    loginId: "ksfong02",
    email: "ksfong02@dsd.gov.hk",
    nameEn: "FONG Kam Shan, Ronnie",
    nameZh: "方錦山",
    division: "ST2/2",
    post: "PM(IT)/ST2/2",
    officePhone: "27416687",
    mobilePhone: "93291925"
)
