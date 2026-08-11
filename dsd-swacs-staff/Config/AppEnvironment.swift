//
//  AppEnvironment.swift
//  dsd-swacs-staff
//
//  Created by Andy on 13/8/2025.
//

import Foundation

public struct AppEnvironment {
    
    #if PROD
    static let baseURL = "https://swac.dsd.gov.hk/mobile"
    #else
     static let baseURL = "https://swac.dsd.gov.hk/mobile-t"
    #endif
    
}
