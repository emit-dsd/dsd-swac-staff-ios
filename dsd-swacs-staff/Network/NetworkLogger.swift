//
//  NetworkLogger.swift
//  dsd-swacs-staff
//
//  Created by Andy on 21/10/2025.
//

import Foundation

struct NetworkLogger {
    
    static func logResponse<Body: Encodable>(
        request: APIRequest<Body>,
        response: HTTPURLResponse,
        responseData: Data,
        token: String? = ""
    ) {
        var requestJsonString: String? = nil
        if let body = request.body,
           let data = try? JSONEncoder().encode(body),
           let jsonString = String(data: data, encoding: .utf8) {
            requestJsonString = jsonString
        }
        
        // 請求Header
        let headers = request.headers
        
        // 響應Body轉字串
        let responseJsonString = String(data: responseData, encoding: .utf8)
        
        let logMessage =
            """
            
            ================================================================================
            🟢 API Response : http://\(response.url?.host ?? "")\(response.url?.path ?? "")
            ================================================================================
            -- Request --
            Header:
            \(headers ?? [:])
            
            Param:
            \(requestJsonString ?? "(-- no param --)")
            
            Token:
            \(token)
            
            -- Response --
            Data:
            \(responseJsonString?.prefix(10000) ?? "(-- no response --)")
            
            Header:
            \(response.allHeaderFields as? [String : String] ?? [:])
            
            
            """
        
        Logger.debug(tag: "Network", logMessage)
    }
    
    
    static func logFailure<Body: Encodable>(
        request: APIRequest<Body>,
        response: HTTPURLResponse,
        responseData: Data,
        token: String? = ""
    ) {
        var requestJsonString: String? = nil
        if let body = request.body,
           let data = try? JSONEncoder().encode(body),
           let jsonString = String(data: data, encoding: .utf8) {
            requestJsonString = jsonString
        }
        
        let headers = request.headers
        
        let responseJsonString = String(data: responseData, encoding: .utf8)
        
        let logMessage =
            """
            
            ================================================================================
            🔴 API FAILURE:  http://\(response.url?.host ?? "")\(response.url?.path ?? "")
            ================================================================================
            -- Request --
            Request Header:
            \(headers ?? [:])
            
            Token:
            \(token)
            
            Request Param:
            \(requestJsonString ?? "(-- no param --)")
            
            -- Response --
            Data:
            \(responseJsonString?.prefix(10000) ?? "(-- no response --)")
            
            Header:
            \(response.allHeaderFields as? [String : String] ?? [:])
            
            """
        
        Logger.error(tag: "Network", logMessage)
    }
    
    
    static func logResponse(
        request: MultipartAPIRequest,
        response: HTTPURLResponse,
        responseData: Data
    ) {
        // 請求Header
        let headers = request.headers
        
        // 參數轉字串
        let parametersString = request.parameters.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        
        // 檔案資訊
        let filesInfo = request.files.enumerated().map { index, file in
            "[\(index)] name=\(file.name), fileName=\(file.fileName), size=\(file.data.count) bytes, type=\(file.mimeType.rawValue)"
        }.joined(separator: "\n")
        
        // 響應Body轉字串
        let responseJsonString = String(data: responseData, encoding: .utf8)
        
        let logMessage =
            """
            
            ================================================================================
            🟢 API Response (Multipart) : \(response.url?.path ?? "")
            ================================================================================
            -- Request --
            Header:
            \(headers ?? [:])
            
            Parameters:
            \(parametersString.isEmpty ? "(-- no parameters --)" : parametersString)
            
            Files:
            \(filesInfo.isEmpty ? "(-- no files --)" : filesInfo)
            
            -- Response --
            Data:
            \(responseJsonString?.prefix(10000) ?? "(-- no response --)")
            
            Header:
            \(response.allHeaderFields as? [String : String] ?? [:])
            
            
            """
        
        Logger.debug(tag: "Network", logMessage)
    }
    
    static func logFailure(
        request: MultipartAPIRequest,
        response: HTTPURLResponse,
        responseData: Data
    ) {
        let headers = request.headers
        let parametersString = request.parameters.map { "\($0.key): \($0.value)" }.joined(separator: "\n")
        let filesInfo = request.files.enumerated().map { index, file in
            "[\(index)] name=\(file.name), fileName=\(file.fileName), size=\(file.data.count) bytes"
        }.joined(separator: "\n")
        
        let responseString = String(data: responseData, encoding: .utf8)
        
        let logMessage =
            """
            
            ================================================================================
            🔴 API Failure (Multipart) : \(response.url?.path ?? "")
            ================================================================================
            -- Request --
            Header:
            \(headers ?? [:])
            
            Parameters:
            \(parametersString.isEmpty ? "(-- no parameters --)" : parametersString)
            
            Files:
            \(filesInfo.isEmpty ? "(-- no files --)" : filesInfo)
            
            -- Response --
            Status Code: \(response.statusCode)
            
            Data:
            \(responseString?.prefix(10000) ?? "(-- no response --)")
            
            Header:
            \(response.allHeaderFields as? [String : String] ?? [:])
            
            
            """
        
        Logger.debug(tag: "Network", logMessage)
    }
}
