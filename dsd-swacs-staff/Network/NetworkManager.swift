//
//  NetworkManager.swift
//  dsd-swacs-staff
//
//  Created by Andy on 12/8/2025.
//

import Network
import Combine


final class NetworkManager: ObservableObject {
    static let shared = NetworkManager()
    @Published var isConnected = true
    private let m = NWPathMonitor()
    init() {
        m.pathUpdateHandler = { [weak self] p in
            DispatchQueue.main.async { self?.isConnected = (p.status == .satisfied) }
        }
        m.start(queue: .global())
    }
}


final class LogoutNotice {
    static let shared = LogoutNotice()
    let publisher = PassthroughSubject<Void, Never>()
    private init() {}
}
