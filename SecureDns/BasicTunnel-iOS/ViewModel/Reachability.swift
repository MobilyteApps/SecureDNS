//
//  Reachability.swift
//  Secure DNS
//
//  Created by Harsh Rajput on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import SystemConfiguration
import Reachability

//public class Reachability1 {
//
//    class func isConnectedToNetwork() -> Bool {
//
//        var zeroAddress = sockaddr_in(sin_len: 0, sin_family: 0, sin_port: 0, sin_addr: in_addr(s_addr: 0), sin_zero: (0, 0, 0, 0, 0, 0, 0, 0))
//        zeroAddress.sin_len = UInt8(MemoryLayout.size(ofValue: zeroAddress))
//        zeroAddress.sin_family = sa_family_t(AF_INET)
//
//        let defaultRouteReachability = withUnsafePointer(to: &zeroAddress) {
//            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {zeroSockAddress in
//                SCNetworkReachabilityCreateWithAddress(nil, zeroSockAddress)
//            }
//        }
//
//        var flags: SCNetworkReachabilityFlags = SCNetworkReachabilityFlags(rawValue: 0)
//        if SCNetworkReachabilityGetFlags(defaultRouteReachability!, &flags) == false {
//            return false
//        }
//
//        /* Only Working for WIFI
//        let isReachable = flags == .reachable
//        let needsConnection = flags == .connectionRequired
//
//        return isReachable && !needsConnection
//        */
//
//        // Working for Cellular and WIFI
//        let isReachable = (flags.rawValue & UInt32(kSCNetworkFlagsReachable)) != 0
//        let needsConnection = (flags.rawValue & UInt32(kSCNetworkFlagsConnectionRequired)) != 0
//        let ret = (isReachable && !needsConnection)
//
//        return ret
//
//    }
//}


extension Notification.Name {
    static let ReachabilityStatusChanged = Notification.Name("ReachabilityStatusChangedNotification")
}

//MARK: NetworkReachability

final class NetworkReachability {

enum ReachabilityStatus: Equatable {
    case connected
    case disconnected
}

static let shared = NetworkReachability()

private let reachability = try! Reachability()

var reachabilityObserver: ((ReachabilityStatus) -> Void)?

private(set) var reachabilityStatus: ReachabilityStatus = .connected

private init() {
    setupReachability()
}

/// setup observer to detect reachability changes
private func setupReachability() {
    let reachabilityStatusObserver: ((Reachability) -> ()) = { [unowned self] (reachability: Reachability) in
        self.updateReachabilityStatus(reachability.connection)
    }
    reachability.whenReachable = reachabilityStatusObserver
    reachability.whenUnreachable = reachabilityStatusObserver
}

/// Start observing reachability changes
func startNotifier() {
    do {
        try reachability.startNotifier()
    } catch {
        print(error.localizedDescription)
    }
}


/// Stop observing reachability changes
func stopNotifier() {
    reachability.stopNotifier()
}


/// Updated ReachabilityStatus status based on connectivity status
///
/// - Parameter status: Reachability.Connection enum containing reachability status
private func updateReachabilityStatus(_ status: Reachability.Connection) {
    switch status {
        case .unavailable, .none:
            notifyReachabilityStatus(.disconnected)
        case .cellular, .wifi:
            notifyReachabilityStatus(.connected)
    }
}


/// Notifies observers about reachability status change
///
/// - Parameter status: ReachabilityStatus enum indicating status eg. .connected/.disconnected
private func notifyReachabilityStatus(_ status: ReachabilityStatus) {
    reachabilityStatus = status
    reachabilityObserver?(status)
    NotificationCenter.default.post(
        name: Notification.Name.ReachabilityStatusChanged,
        object: nil,
        userInfo: ["ReachabilityStatus": status]
    )
}

/// returns current reachability status
var isReachable: Bool {
    return reachability.connection != .unavailable
}


/// returns if connected via cellular or wifi
var isConnectedViaCellularOrWifi: Bool {
    return isConnectedViaCellular || isConnectedViaWiFi
}

/// returns if connected via cellular
var isConnectedViaCellular: Bool {
    return reachability.connection == .cellular
}

/// returns if connected via cellular
var isConnectedViaWiFi: Bool {
    return reachability.connection == .wifi
}

deinit {
    stopNotifier()
} 

}
