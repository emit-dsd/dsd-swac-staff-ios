//
//  APIRequest.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

import Foundation

enum HTTPMethod: String {
    case GET
    case POST
    case PUT
    case DELETE
    case PATCH
}

struct RequestOptions: OptionSet {
    let rawValue: Int
    static let noLoading           = RequestOptions(rawValue: 1 << 0)
    static let noDefaultErrorAlert = RequestOptions(rawValue: 1 << 1)
    static let noNetworkAlert      = RequestOptions(rawValue: 1 << 2)
    static let noAuth              = RequestOptions(rawValue: 1 << 3)
    static let noRetry             = RequestOptions(rawValue: 1 << 4)
}

struct EmptyBody: Encodable {}

// MARK: - APIRequest
struct APIRequest<Body: Encodable> {
    let method: HTTPMethod
    let path: String
    let query: [String: Any]?
    let body: Body?
    let headers: [String: String]?
    let options: RequestOptions
    
    init(
        _ method: HTTPMethod,
        path: String,
        query: [String: Any]? = nil,
        body: Body? = nil,
        headers: [String: String]? = nil,
        options: RequestOptions = []
    ) {
        self.method = method
        self.path = path
        self.query = query
        self.body = body
        self.headers = headers
        self.options = options
    }
}

// MARK: - Multipart APIRequest
enum MimeType: String {
    case jpeg = "image/jpeg"
    case png = "image/png"
    case pdf = "application/pdf"
    case octetStream = "application/octet-stream"
    
    var fileExtension: String {
        switch self {
        case .jpeg: return "jpg"
        case .png: return "png"
        case .pdf: return "pdf"
        case .octetStream: return "bin"
        }
    }
}


struct MultipartFile {
    let name: String
    let fileName: String
    let data: Data
    let mimeType: MimeType
}


struct MultipartAPIRequest {
    let method: HTTPMethod
    let path: String
    let parameters: [String: String]
    let files: [MultipartFile]
    let query: [String: Any]?
    let headers: [String: String]?
    let options: RequestOptions
    
    init(
        _ method: HTTPMethod = .POST,
        path: String,
        parameters: [String: String] = [:],
        files: [MultipartFile] = [],
        query: [String: Any]? = nil,
        headers: [String: String]? = nil,
        options: RequestOptions = []
    ) {
        self.method = method
        self.path = path
        self.parameters = parameters
        self.files = files
        self.query = query
        self.headers = headers
        self.options = options
    }
}
