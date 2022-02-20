//
//  NetworkMonitor.swift
//  GoFitApp
//
//  Created by Peter Hlavatík on 16/02/2022.
//

import Foundation
import Network
import Combine
import Alamofire

final class NetworkMonitor {
    
    // MARK: Variables
    private let queue = DispatchQueue.global()
    private let monitor: NWPathMonitor
    private var subscription = Set<AnyCancellable>()
    public var connectionState = PassthroughSubject<(Bool, ConnectionType), Never>()
    
    public private(set) var connectionType: ConnectionType = .unknown
    private var status: NWPath.Status = .requiresConnection
    public var isReachable: Bool { status == .satisfied }
    public private(set) var isReachableOnCellular: Bool = true
    
    enum ConnectionType {
        case wifi
        case cellular
        case ethernet
        case unknown
    }
    
    init(_ dependencyContainer: DependencyContainer) {
        monitor = NWPathMonitor()
    }
    
    // MARK: Monitoring
    public func startMonitoring() {
        monitor.start(queue: queue)
        monitor.pathUpdateHandler = { [weak self] path in
            self?.status = path.status
            self?.isReachableOnCellular = path.isExpensive
            self?.getConnectionType(path)
            
            if path.status == .satisfied {
                print("We're connected!")
                self?.connectionState.send((true, self?.connectionType ?? .unknown))
            } else {
                print("No connection.")
                self?.connectionState.send((false, self?.connectionType ?? .unknown))
            }
        }
    }
    
    // MARK: Connection type
    private func getConnectionType(_ path: NWPath) {
        if path.usesInterfaceType(.wifi) {
            connectionType = .wifi
        } else if path.usesInterfaceType(.cellular) {
            connectionType = .cellular
        } else if path.usesInterfaceType(.wiredEthernet) {
            connectionType = .ethernet
        } else {
            connectionType = .unknown
        }
    }
}
