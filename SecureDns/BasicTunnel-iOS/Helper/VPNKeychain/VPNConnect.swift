//
//  VPNConnect.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 23/07/20.
//  Copyright © 2020 Mobilyte Inc.. All rights reserved.
//

import Foundation
import TunnelKit
import NetworkExtension
public class VPNConnect:NSObject {
    private static let vpnDescription = "DNS OnDemand to \(kAppTitle)DNS"
    static let appGroup = "group.xyz.dnsbkv.adgap"
    static let tunnelIdentifier = "xyz.dnsbkv.adgap.networkExtension"
    static let shared = VPNConnect()
    public var manager:NETunnelProviderManager = NETunnelProviderManager()
    public var useDNSServers:[String]?
    private let viewModel = CBDSNViewModel.shared
    
    public var connected:Bool {
        get {
            return self.manager.isOnDemandEnabled
        }
        set {
            if newValue != self.connected {
                update(
                    body: {
                        self.manager.isEnabled = newValue
                        self.manager.isOnDemandEnabled = newValue
                        
                },
                    complete: {
                        if newValue {
                            do {
                                try (self.manager.connection as? NETunnelProviderSession)?.startVPNTunnel()
                            } catch let err as NSError {
                                NSLog("\(err.localizedDescription)")
                            }
                        } else {
                            
                            (self.manager.connection as? NETunnelProviderSession)?.stopVPNTunnel()
                        }
                        
                }
                )
            }
        }
    }
    
    private override init() {
        super.init()
        refreshManager()
    }
    
    public func refreshManager() -> Void {
        NETunnelProviderManager.loadAllFromPreferences(completionHandler: { (managers, error) in
            if nil == error {
                if let managers = managers {
                    if let manager = managers.first(where: {$0.localizedDescription == VPNConnect.vpnDescription }){
                          self.manager = manager
                        return
                    }
                   
//                    for manager in managers {
//                        if manager.localizedDescription == VPNConnect.vpnDescription {
//                            self.manager = manager
//                            return
//                        }
//                    }
                }
            }
             self.setPreferences()
//            if self.viewModel.configFileURL != nil{
//                self.setPreferences()
//            }else{
//                self.viewModel.download {
//                    async {
//                        self.setPreferences()
//                    }
//                }
//            }
            
        })
    }
    
    private func update(body: @escaping ()->Void, complete: @escaping ()->Void) {
        manager.loadFromPreferences { error in
            if (error != nil) {
                NSLog("Load error: \(String(describing: error?.localizedDescription))")
                return
            }
            body()
            self.manager.saveToPreferences { (error) in
                if nil != error {
                    NSLog("vpn_connect: save error \(error!)")
                } else {
                    complete()
                }
            }
        }
    }
    func makeProtocol() -> NETunnelProviderProtocol {
        //Bundle.url(forResource: "iosv1", extension: "ovpn")
        guard  let configurationFileURL = Bundle.url(forResource: "iosv1", extension: "ovpn") else{
            print("File not found")
            fatalError()
        }
        do {
            let configurationFileContent = try OpenVPN.ConfigurationParser.parsed(fromURL: configurationFileURL)
            var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: configurationFileContent.configuration)
            builder.shouldDebug = true
            //builder.masksPrivateData = false
            let configuration = builder.build()
           useDNSServers =  builder.sessionConfiguration.dnsServers
           
            return try configuration.generatedTunnelProtocol(withBundleIdentifier: VPNConnect.tunnelIdentifier, appGroup: VPNConnect.appGroup)
            
        } catch {
            fatalError(error.localizedDescription)
            
            
        }
    
        
    }
    private func setPreferences() {
        self.manager.localizedDescription = VPNConnect.vpnDescription
        let proto = makeProtocol()
        proto.providerBundleIdentifier = VPNConnect.tunnelIdentifier
        self.manager.protocolConfiguration = proto
        // TLDList is a struct I created in its own swift file that has an array of all top level domains
        let evaluationRule = NEEvaluateConnectionRule(matchDomains: TLDList.tlds,
                                                      andAction: NEEvaluateConnectionRuleAction.connectIfNeeded)
        
         evaluationRule.useDNSServers =  useDNSServers
        let onDemandRule = NEOnDemandRuleEvaluateConnection()
        onDemandRule.connectionRules = [evaluationRule]
        onDemandRule.interfaceTypeMatch = .any
        self.manager.onDemandRules = [onDemandRule]
    }
  
    
    
}
