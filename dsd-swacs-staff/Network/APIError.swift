//
//  APIError.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

import Foundation

struct APIErrorDetail: Decodable {
    let type: String?
    let title: String?
    let status: Int?
    let detail: String?
    let errors: [String: [String]]?
    let traceId: String?
    
    var userFriendlyMessage: String {
        if let detail = detail, !detail.isEmpty {
            return detail
        }
        if let errors = errors, !errors.isEmpty {
            return errors.flatMap { $0.value }.joined(separator: "\n")
        }
        if let title = title, !title.isEmpty {
            return title
        }
        return "發生未知錯誤"
    }
}

enum APIError: Error {
    case unknown
    case noNetwork
    case invalidURL
    case timeout(NSError)
    case notHTTPResponse
    case decodeFail(DecodingError?)
    case server(Int, String?, String?)
    case tokenRefreshFail
    case invalidSession
    case unexpected(String?, Error?)
    
    // Debug Message
    var debugDescription: String {
        switch self {
        case .unknown:
            return "Unknown error"
        case .noNetwork:
            return "No network connection"
        case .invalidURL:
            return "Invalid request URL"
        case .timeout(let e):
            return "Request timed out: \(e.localizedDescription)"
        case .notHTTPResponse:
            return "No valid HTTP response"
        case .decodeFail(let err):
            if let err = err {
                switch err {
                case let .keyNotFound(key, ctx):
                    return "Key not found in path: \(ctx.codingPath.map{$0.stringValue}.joined(separator: " -> ")) => \(key.stringValue)"
                case let .valueNotFound(type, ctx):
                    return "Value not found in path: \(ctx.codingPath.map{$0.stringValue}.joined(separator: " -> ")) => \(type)"
                default:
                    return "Decoding error: \(err)"
                }
            }
            return "Decoding failed without detail"
        case .server(let code, let title, let msg):
            return "HTTP \(code) - \(title ?? "No title") - \(msg ?? "No message")"
        case .tokenRefreshFail:
            return "Token refresh failed"
        case .invalidSession:
            return "Session expired"
        case .unexpected(let msg, let err):
            return "Unexpected Error: \(msg ?? "") \(err?.localizedDescription ?? "")"
        }
    }
    
    // UI Message
    var userTitle: String {
        switch self {
        case .noNetwork:
            return "錯誤"
        case .invalidURL:
            return "錯誤"
        case .timeout:
            return "錯誤"
        case .notHTTPResponse:
            return "錯誤"
        case .decodeFail:
            return "錯誤"
        case .server(_, let title, let msg):
            return title ?? "錯誤"
        case .tokenRefreshFail, .invalidSession:
            return "錯誤"
        default:
            return "錯誤"
        }
    }
    
    
    var userMessage: String {
        switch self {
        case .noNetwork:
            return "網絡不可用"
        case .invalidURL:
            return "URL 無效"
        case .timeout:
            return "連線逾時，請稍後再試"
        case .notHTTPResponse:
            return "回應資料格式錯誤"
        case .decodeFail:
            return "資料解析失敗"
        case .server(_, let title, let msg):
            return msg ?? "伺服器錯誤"
        case .tokenRefreshFail, .invalidSession:
            return "登入已過期，請重新登入"
        default:
            return "發生未知錯誤，請稍後再試"
        }
    }
    
    init(from error: Error) {
        if let apiErr = error as? APIError {
            self = apiErr
        } else if let decodeErr = error as? DecodingError {
            self = .decodeFail(decodeErr)
        } else {
            self = .unexpected(nil, error)
        }
    }
}
