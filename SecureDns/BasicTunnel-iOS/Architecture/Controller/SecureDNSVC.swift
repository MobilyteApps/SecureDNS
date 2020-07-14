//
//  SecureDNSVC.swift
//  Demo
//
//  Created by Harsh Rajput on 08/07/20.
//  Copyright © 2020 Davide De Rosa. All rights reserved.
//

import UIKit
import NetworkExtension
import TunnelKit

class SecureDNSVC: UIViewController, URLSessionDataDelegate {
    @IBOutlet fileprivate var switchConntectionStatus: UISwitch!
    @IBOutlet fileprivate var lblConnection: UILabel!
    @IBOutlet fileprivate var buttonConnection: UIButton!
    @IBOutlet fileprivate var labelDayleft: UILabel!
    fileprivate var currentManager: NETunnelProviderManager?
    fileprivate var status: NEVPNStatus = .invalid{
        didSet{
            switch status {
            case  .connecting:
                self.lblConnection.text = "Connecting..."
                self.switchConntectionStatus.setOn(false, animated: true)
                KConnected = false
            case .connected:
                self.lblConnection.text = "Connected"
                self.switchConntectionStatus.setOn(true, animated: true)
                KConnected = true
            case .disconnected:
                self.lblConnection.text = "Connect"//"Disconnected"
                self.switchConntectionStatus.setOn(false, animated: true)
            case .disconnecting:
                self.lblConnection.text = "Disconnecting..."
                self.switchConntectionStatus.setOn(false, animated: true)
                
            default:
                break
            }
        }
    }
    //fileprivate var isConnected = false
    fileprivate var viewModel:CBDSNViewModel{
        return CBDSNViewModel.shared
    }
    
    //MARK:- UIView LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        switchConntectionStatus.set(width: 130, height: 75)
        getPremiumValidity()
        reachabilityObserver()
        reloadCurrentManager()
        NotificationCenter.default.addObserver(self,selector: #selector(VPNStatusDidChange(notification:)),name: .NEVPNStatusDidChange,object: nil)
        
    }
    
    //MARK:- Check Premium Validity
    private func getPremiumValidity(){
        viewModel.premiumValidate {
            async {
                self.labelDayleft.text = self.viewModel.tailValidTime
            }
        }
    }
    
    //MARK:- reachabilityObserver
    private func reachabilityObserver() {
        NetworkStatus.shared.startNotifier { status in
            switch status{
            case .reachable:
                print("Reachability: Network available 😃")
                async {
                    self.reconnection()
                }
            case .notReachable:
                print("Reachability: Network unavailable 😟")
                KConnected = false
                self.reconnection()
            default:break
            }
        }
        
    }
    
    //MARK:- VPNStatusDidChange Observer
    @objc private func VPNStatusDidChange(notification: NSNotification) {
        guard let status = currentManager?.connection.status else {
            print("VPNStatusDidChange")
            return
        }
        print("VPNStatusDidChange: \(status.rawValue)")
        self.status = status
        
    }
    //MARK:- connectionClicked
    @IBAction private func connectionClicked(_ sender: Any) {
        let block = {
            switch (self.status) {
            case .invalid, .disconnected:
                self.connect()
            case .connected, .connecting:
                self.disconnect()
                
            default:
                break
            }
        }
        
        if (status == .invalid) {
            reloadCurrentManager({ (error) in
                block()
            })
        }
        else {
            block()
        }
    }
    
}



fileprivate extension SecureDNSVC{
    
    private static let appGroup = "group.xyz.dnsbkv.adgap"
    private static let tunnelIdentifier = "xyz.dnsbkv.adgap.networkExtension"
    
    //MARK:- make NETunnelProviderProtocol
    private func makeProtocol() -> NETunnelProviderProtocol {
        guard  let configurationFileURL = Bundle.main.url(forResource: "iosv1", withExtension: "ovpn") else{
            print("File not found")
            fatalError()
        }
        do {
            let configurationFileContent = try OpenVPN.ConfigurationParser.parsed(fromURL: configurationFileURL)
            
            var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: configurationFileContent.configuration)
            builder.shouldDebug = true
            //builder.masksPrivateData = false
            let configuration = builder.build()
            return try configuration.generatedTunnelProtocol(withBundleIdentifier: SecureDNSVC.tunnelIdentifier, appGroup: SecureDNSVC.appGroup)
            
        } catch {
            fatalError(error.localizedDescription)
            
            
        }
        
        
    }
    //MARK:- reconnection
    func reconnection(){
        if KConnected{
            self.connect()
        }else{
            self.disconnect()
        }
        
    }
    //MARK:- connect
    func connect() {
        configureVPN({ (manager) in
            return self.makeProtocol()
        }, completionHandler: { (error) in
            if let error = error {
                print("configure error: \(error)")
                return
            }
            self.currentManager?.isEnabled = true
            let session = self.currentManager?.connection as! NETunnelProviderSession
            do {
                try session.startTunnel()
                print("start Tunnel called")
            } catch let e {
                print("error starting tunnel: \(e)")
            }
        })
    }
    
    //MARK:- disconnect
    func disconnect() {
        configureVPN({ (manager) in
            print(manager.description)
            return nil
        }, completionHandler: { (error) in
            if let err = error{
                print(err.localizedDescription)
            }
            self.currentManager?.connection.stopVPNTunnel()
            KConnected = false
            
        })
    }
    //MARK:- configureVPN
    func configureVPN(_ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?, completionHandler: @escaping (Error?) -> Void) {
        reloadCurrentManager { (error) in
            if let error = error {
                print("error reloading preferences: \(error)")
                completionHandler(error)
                return
            }
            
            let manager = self.currentManager!
            if let protocolConfiguration = configure(manager) {
                manager.protocolConfiguration = protocolConfiguration
            }
            manager.isEnabled = true
            
            manager.saveToPreferences { (error) in
                if let error = error {
                    print("error saving preferences: \(error)")
                    completionHandler(error)
                    return
                }
                print("saved preferences")
                self.reloadCurrentManager(completionHandler)
            }
        }
    }
    //MARK:- reloadCurrentManager
    func reloadCurrentManager(_ completionHandler: ((Error?) -> Void)? = nil) {
        NETunnelProviderManager.loadAllFromPreferences { (managers, error) in
            if let error = error {
                completionHandler?(error)
                return
            }
            
            var manager: NETunnelProviderManager?
            
            
            for m in managers! {
                if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                    if (p.providerBundleIdentifier == SecureDNSVC.tunnelIdentifier) {
                        manager = m
                        break
                    }
                }
            }
            
            if (manager == nil) {
                manager = NETunnelProviderManager()
            }
            
            self.currentManager = manager
            self.status = manager!.connection.status
            completionHandler?(nil)
        }
    }
    
}
extension UISwitch {
    func set(width: CGFloat, height: CGFloat) {
        
        let standardHeight: CGFloat = 31
        let standardWidth: CGFloat = 51
        
        let heightRatio = height / standardHeight
        let widthRatio = width / standardWidth
        
        transform = CGAffineTransform(scaleX: widthRatio, y: heightRatio)
    }
}
