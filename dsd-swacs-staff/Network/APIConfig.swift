//
//  APIConfig.swift
//  dsd-swacs-staff
//
//  Created by Andy on 13/8/2025.
//

import Foundation

final class APIConfig {
    static let shared = APIConfig()
    
    var defaultHeaders: [String: String] = [
        "Content-Type": "application/json",
        "X-App-Platform": "iOS",
        //        "X-App-Version": Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "Unknown"
    ]
    
    private init() {}
    
    func getAuthTokenHeaders(headers: [String:String]) -> [String:String] {
        
        var mergedHeaders = defaultHeaders
        
        // TODO: Encription
        //        if let aesEncoding = encoding as? WebServicesEncoding.AESEncoding {
        //            headers["X-Content-IV"] = aesEncoding.aesEncryption.getEncryptedIV()
        //        }
        //        headers["Accept-Language"] = getAcceptLanguageHeaderMtel()
        //        headers["X-Device-ID"] = getUUID()
        
        // TODO: App Version
        //        headers["X-App-Platform-Ver"] = UIDevice.current.systemVersion
        //        headers["X-App-Build-Date"] = Date().string(format: "yyyy-MM-dd")
        
        // TODO: Session / token
        //        if let mbId = appUserDefaults.mbId {
        //            headers["X-Session-Identical"] = decryptOrCreate(mbId, keyName: "HLTKey")
        //        }
        //        if let xToken = appUserDefaults.xToken {
        //            headers["X-Session-Token"] = decryptOrCreate(xToken, keyName: "HLTKey")
        //        }
        
        headers.forEach { mergedHeaders[$0.key] = $0.value }
        
        return mergedHeaders
    }
}
