//
//  APIManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

import Foundation
import SwiftUI

@MainActor
final class APIManager: ObservableObject {
    static let shared = APIManager()
    
    // MARK: - Published Properties
    @Published var isLoading = false
    @Published var showRetryAlert = false
    @Published var showErrorAlert = false
    @Published var showSessionExpiredAlert = false
    @Published var errorTitle: String? = nil
    @Published var errorMessage: String? = nil
    @Published var networkAlertCancelled = false
    
    private static var isHandling401 = false
    
    // MARK: - Dependencies
    private let baseURL = AppEnvironment.baseURL
    private let network = NetworkManager.shared
    private let tokenStore = TokenManager.shared
    private let authManager = AuthenticationManager.shared
    
    
    // MARK: - Retry Mechanism
    private var pendingRetry: CheckedContinuation<RetryAction, Never>?
    
    enum RetryAction {
        case retry
        case cancel
    }
    
    enum APIResponseType {
        case codable(Decodable.Type)
        case data
        case string
    }

    private init() {}
    
    // MARK: - Public API Entry Points
    func sendAPIRequest<Body: Encodable, Response: Decodable>(
        _ method: HTTPMethod = .GET,
        path: String,
        body: Body? = nil,
        options: RequestOptions = [],
        extraHeaders: [String: String]? = nil,
        responseType: APIResponseType = .codable(Response.self)
    ) async throws -> Response {
        let finalBody: Body = body ?? EmptyBody() as! Body
        let headers = APIConfig.shared.getAuthTokenHeaders(headers: extraHeaders ?? [:])
        
        let requestModel = APIRequest<Body>(
            method,
            path: path,
            body: finalBody,
            headers: headers,
            options: options
        )
        
        while true {
            do {
                let rawResult = try await performAPIRequest(requestModel, responseType: responseType)
                
                switch responseType {
                case .codable:
                    guard let typedResult = rawResult as? Response else {
                        throw APIError.decodeFail(nil)
                    }
                    return typedResult
                    
                case .data:
                    guard let dataResult = rawResult as? Response else {
                        throw APIError.decodeFail(nil)
                    }
                    return dataResult
                    
                case .string:
                    if Response.self is String.Type, let stringResult = rawResult as? Response {
                        return stringResult
                    } else {
                        throw APIError.decodeFail(nil)
                    }
                }
                
            } catch APIError.noNetwork {
                if !options.contains(.noNetworkAlert) {
                    // ✨ 等待用戶選擇（重試或取消）
                    let action = await waitForRetry()
                    
                    switch action {
                    case .retry:
                        // 繼續循環重試
                        continue
                    case .cancel:
                        // 拋出錯誤，結束重試
                        throw APIError.noNetwork
                    }
                } else {
                    throw APIError.noNetwork
                }
                
            } catch {
                throw error
            }
        }
    }
    
    func sendAPIRequest<Response: Decodable>(
        _ method: HTTPMethod = .GET,
        path: String,
        options: RequestOptions = [],
        extraHeaders: [String: String]? = nil,
        responseType: APIResponseType = .codable(Response.self)
    ) async throws -> Response {
        try await sendAPIRequest(
            method,
            path: path,
            body: EmptyBody(),
            options: options,
            extraHeaders: extraHeaders,
            responseType: responseType
        )
    }
    
    // MARK: - Core Request Execution
    
    private func performAPIRequest<Req: Encodable>(
        _ apiReq: APIRequest<Req>,
        responseType: APIResponseType
    ) async throws -> Any {
        
        if !apiReq.options.contains(.noNetworkAlert) {
            guard network.isConnected else {
                throw APIError.noNetwork
            }
        }
        
        var comps = URLComponents(string: baseURL + apiReq.path)
        if let q = apiReq.query {
            comps?.queryItems = q.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        guard let url = comps?.url else {
            throw APIError.invalidURL
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = apiReq.method.rawValue
        
        apiReq.headers?.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        
        if !apiReq.options.contains(.noAuth), let token = tokenStore.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        if apiReq.method == .GET {
            req.httpBody = nil
        } else if let body = apiReq.body {
            req.httpBody = try JSONEncoder().encode(body)
        }
        
        if !apiReq.options.contains(.noLoading) {
            isLoading = true
        }
        defer {
            if !apiReq.options.contains(.noLoading) {
                isLoading = false
            }
        }

        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                throw APIError.notHTTPResponse
            }
           
            switch http.statusCode {
            case 200...299:
                NetworkLogger.logResponse(request: apiReq, response: http, responseData: data, token: tokenStore.token)
                return try handleSuccessResponse(data: data, responseType: responseType)
                
            case 401:
                NetworkLogger.logFailure(request: apiReq, response: http, responseData: data, token: tokenStore.token)
                try await handleUnauthorized(apiReq: apiReq)
                throw APIError.invalidSession
                
            default:
                NetworkLogger.logFailure(request: apiReq, response: http, responseData: data, token: tokenStore.token)
                try handleErrorResponse(statusCode: http.statusCode, data: data, options: apiReq.options)
                throw APIError.unknown
            }
            
        } catch let error as APIError {
            handleAPIError(error, options: apiReq.options)
            throw error
            
        } catch let err as URLError where err.code == .timedOut {
            let timeoutError = APIError.timeout(err as NSError)
            handleAPIError(timeoutError, options: apiReq.options)
            throw timeoutError
            
        } catch {
            let apiError = APIError(from: error)
            handleAPIError(apiError, options: apiReq.options)
            throw apiError
        }
    }
    
    // MARK: - Response Handlers
    
    private func handleSuccessResponse(data: Data, responseType: APIResponseType) throws -> Any {
        if data.isEmpty {
            switch responseType {
            case .codable(let type):
                if type == EmptyResponse.self {
                    return EmptyResponse()
                }
                return try JSONDecoder().decode(type, from: "{}".data(using: .utf8)!)
            case .data:
                return Data()
            case .string:
                return ""
            }
        }
        
        switch responseType {
        case .codable(let type):
            return try JSONDecoder().decode(type, from: data)
        case .data:
            return data
        case .string:
            guard let str = String(data: data, encoding: .utf8) else {
                throw APIError.decodeFail(nil)
            }
            return str
        }
    }
    
    private func handleUnauthorized<Req: Encodable>(apiReq: APIRequest<Req>) async throws {
        print("🚨 401 Unauthorized - Token expired")
        
        let isAuthRequest =
        apiReq.path.contains("/login") ||
        apiReq.path.contains("/logout") ||
        apiReq.path.contains("/auth") ||
        apiReq.path.contains("/DeregisterMobileToken")
        
        if !isAuthRequest {
            guard !APIManager.isHandling401 else {
                print("⏳ Already handling 401, skipping duplicate alert")
                return
            }
            
            APIManager.isHandling401 = true
            
            await MainActor.run {
                AlertManager.shared.clearQueue()
                
                AlertManager.shared.show(
                    title: "login_alertTitle_login_expired".localized(),
                    message: "login_alertMessage_login_expired".localized(),
                    buttons: [
                        CommonButtonModel(
                            title: "general_confirm".localized(),
                            style: .contained,
                            enabled: true,
                            maxWidth: .infinity,
                            backgroundColor: .red,
                            action: {
                                Task {
                                    self.authManager.forceLogout()
                                    APIManager.isHandling401 = false
                                }
                            }
                        )
                    ]
                )
            }
        }
    }
    
    private func handleErrorResponse(statusCode: Int, data: Data, options: RequestOptions) throws {
        if let detail = try? JSONDecoder().decode(APIErrorDetail.self, from: data) {
            throw APIError.server(statusCode, detail.title, detail.detail)
        } else {
            let msg = String(data: data, encoding: .utf8) ?? "未知錯誤"
            throw APIError.server(statusCode, "", msg)
        }
    }
    
    private func handleAPIError(_ error: APIError, options: RequestOptions) {
        guard !options.contains(.noDefaultErrorAlert) else { return }
        
        switch error {
        case .noNetwork:
            break
            
        case let .server(_, title, msg):
            DispatchQueue.main.async {
                self.errorTitle = title ?? ""
                self.errorMessage = msg ?? ""
                self.showErrorAlert = true
            }
            
        case let .decodeFail(decodeErr):
            DispatchQueue.main.async {
                self.errorMessage = error.userMessage
                self.showErrorAlert = true
                print("🚨" + error.debugDescription)
            }
            
        default:
            break
        }
    }
    
    // MARK: - Multipart Upload
    
    func uploadMultipartRequest<Res: Decodable>(
        _ apiReq: MultipartAPIRequest
    ) async throws -> Res {
        
        while true {
            do {
                return try await performMultipartUpload(apiReq)
                
            } catch APIError.noNetwork {
                if !apiReq.options.contains(.noNetworkAlert) {
                    let action = await waitForRetry()
                    
                    switch action {
                    case .retry:
                        continue
                    case .cancel:
                        throw APIError.noNetwork
                    }
                } else {
                    throw APIError.noNetwork
                }
                
            } catch {
                throw error
            }
        }
    }
    
    private func performMultipartUpload<Res: Decodable>(
        _ apiReq: MultipartAPIRequest
    ) async throws -> Res {
        
        if !apiReq.options.contains(.noNetworkAlert) {
            guard network.isConnected else {
                throw APIError.noNetwork
            }
        }
        
        var comps = URLComponents(string: baseURL + apiReq.path)
        if let q = apiReq.query {
            comps?.queryItems = q.map { URLQueryItem(name: $0.key, value: "\($0.value)") }
        }
        guard let url = comps?.url else {
            throw APIError.invalidURL
        }
        
        var req = URLRequest(url: url)
        req.httpMethod = apiReq.method.rawValue
        let boundary = "Boundary-\(UUID().uuidString)"
        req.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        apiReq.headers?.forEach { req.setValue($0.value, forHTTPHeaderField: $0.key) }
        if !apiReq.options.contains(.noAuth), let token = tokenStore.token {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        var body = Data()
        
        for (key, value) in apiReq.parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }
        
        for file in apiReq.files {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(file.name)\"; filename=\"\(file.fileName)\"\r\n".data(using: .utf8)!)
            body.append("Content-Type: \(file.mimeType.rawValue)\r\n\r\n".data(using: .utf8)!)
            body.append(file.data)
            body.append("\r\n".data(using: .utf8)!)
        }
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)
        req.httpBody = body
        
        if !apiReq.options.contains(.noLoading) {
            isLoading = true
        }
        defer {
            if !apiReq.options.contains(.noLoading) {
                isLoading = false
            }
        }
        
        do {
            let (data, resp) = try await URLSession.shared.data(for: req)
            guard let http = resp as? HTTPURLResponse else {
                throw APIError.notHTTPResponse
            }

            switch http.statusCode {
            case 200...299:
                NetworkLogger.logResponse(request: apiReq, response: http, responseData: data)
                return try JSONDecoder().decode(Res.self, from: data)
                
            case 401:
                NetworkLogger.logFailure(request: apiReq, response: http, responseData: data)
                try await handleUnauthorizedMultipart(apiReq: apiReq)
                throw APIError.invalidSession
                
            default:
                NetworkLogger.logFailure(request: apiReq, response: http, responseData: data)
                if let detail = try? JSONDecoder().decode(APIErrorDetail.self, from: data) {
                    throw APIError.server(http.statusCode, detail.title, detail.detail)
                } else {
                    let msg = String(data: data, encoding: .utf8) ?? "未知錯誤"
                    throw APIError.server(http.statusCode, "", msg)
                }
            }
            
        } catch let error as APIError {
            handleAPIError(error, options: apiReq.options)
            throw error
            
        } catch let err as URLError where err.code == .timedOut {
            let timeoutError = APIError.timeout(err as NSError)
            handleAPIError(timeoutError, options: apiReq.options)
            throw timeoutError
            
        } catch {
            let apiError = APIError(from: error)
            handleAPIError(apiError, options: apiReq.options)
            throw apiError
        }
    }

    // 新增：處理 Multipart 的 401
    private func handleUnauthorizedMultipart(apiReq: MultipartAPIRequest) async throws {
        print("🚨 401 Unauthorized - Token expired (Multipart)")
        
        let isAuthRequest =
        apiReq.path.contains("/login") ||
        apiReq.path.contains("/logout") ||
        apiReq.path.contains("/auth") ||
        apiReq.path.contains("/DeregisterMobileToken")
        
        if !isAuthRequest {
            guard !APIManager.isHandling401 else {
                print("⏳ Already handling 401, skipping duplicate alert")
                return
            }
            
            APIManager.isHandling401 = true
            
            await MainActor.run {
                AlertManager.shared.clearQueue()
                
                AlertManager.shared.show(
                    title: "login_alertTitle_login_expired".localized(),
                    message: "login_alertMessage_login_expired".localized(),
                    buttons: [
                        CommonButtonModel(
                            title: "general_confirm".localized(),
                            style: .contained,
                            enabled: true,
                            maxWidth: .infinity,
                            backgroundColor: .red,
                            action: {
                                Task {
                                    await self.authManager.forceLogout()
                                    APIManager.isHandling401 = false
                                }
                            }
                        )
                    ]
                )
            }
        }
    }

    
    static func reset401State() {
        isHandling401 = false
    }
    
    // MARK: -  Retry Mechanism (Fixed)

    /// Wait for user to choose retry or cancel
    private func waitForRetry() async -> RetryAction {
        await withCheckedContinuation { continuation in
            self.pendingRetry = continuation
            self.showRetryAlert = true
        }
    }
    
    /// Resume with retry action
    func retryLastRequest() {
        guard let continuation = pendingRetry else { return }
        showRetryAlert = false
        pendingRetry = nil
        continuation.resume(returning: .retry)
    }
    
    /// Resume with cancel action
    func cancelRetry() {
        guard let continuation = pendingRetry else { return }
        showRetryAlert = false
        pendingRetry = nil
        continuation.resume(returning: .cancel)
        networkAlertCancelled = true
    }
    
    func resetNetworkAlertState() {
          networkAlertCancelled = false
      }
    
    deinit {
        if let continuation = pendingRetry {
            continuation.resume(returning: .cancel)
        }
    }
}
