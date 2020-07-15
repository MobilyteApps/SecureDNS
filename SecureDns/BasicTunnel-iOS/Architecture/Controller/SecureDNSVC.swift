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
    @IBOutlet fileprivate var conntectionStatusSwitch: UISwitch!
    @IBOutlet fileprivate var connectionStatuslbl: UILabel!
    @IBOutlet fileprivate var connectionBtn: UIButton!
    @IBOutlet fileprivate var leftTrailDayslbl: UILabel!
    @IBOutlet fileprivate var upgradeBtn: UIButton!
    @IBOutlet weak private var termPolicylbl: UILabel!
    fileprivate var currentManager: NETunnelProviderManager?
    fileprivate var status: NEVPNStatus = .invalid{
        
        didSet{
            var isOn:Bool = false
            var statusText:String = "Connect"
            switch status {
            case  .connecting:
                statusText = "Connecting..."
                isOn = false
                //self.conntectionStatusSwitch.setOn(false, animated: true)
                KConnected = false
            case .connected:
                statusText = "Connected"
                //self.conntectionStatusSwitch.setOn(true, animated: true)
                isOn = true
                KConnected = true
            case .disconnected:
                statusText = "Connect"//"Disconnected"
                // self.conntectionStatusSwitch.setOn(false, animated: true)
                isOn = false
            case .disconnecting:
                statusText = "Disconnecting..."
                // self.conntectionStatusSwitch.setOn(false, animated: true)
                isOn = false
                
            default:
                break
            }
            self.connectionStatuslbl.text = statusText
            self.conntectionStatusSwitch.setOn(isOn, animated: true)
        }
    }
    //fileprivate var isConnected = false
    fileprivate var viewModel:CBDSNViewModel{
        return CBDSNViewModel.shared
    }
    
    //MARK:- UIView LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
    
        conntectionStatusSwitch.set(width: 130, height: 75)
        getPremiumValidity()
        reachabilityObserver()
        reloadCurrentManager()
        NotificationCenter.default.addObserver(self,selector: #selector(onDidChangeVPNStatus(notification:)),name: .NEVPNStatusDidChange,object: nil)
        self.termAndPolicyConfig()
    }
    
    //MARK:- Check Premium Validity
    private func getPremiumValidity(){
        viewModel.premiumValidate {
            async {
                self.loadData()
                self.viewModel.getIApProduct { success in
                    async {
                        self.loadData()
                    }
                }
            }
        }
    }
    
    private func loadData(){
        self.leftTrailDayslbl.text = self.viewModel.tailValidTime
        self.upgradeBtn[title:.normal] = self.viewModel.productPrice
        self.connectionBtn.isUserInteractionEnabled = self.viewModel.isActive
        self.conntectionStatusSwitch.isUserInteractionEnabled = self.viewModel.isActive
        reachabilityObserver()
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
    @objc private func onDidChangeVPNStatus(notification: NSNotification) {
        guard viewModel.isActive,let status = currentManager?.connection.status else {
            print("VPNStatusDidChange")
            self.status = .disconnected
            return
        }
        print("VPNStatusDidChange: \(status.rawValue)")
        self.status = status
        
    }
    //MARK:- On Click VPN Connection
    @IBAction private func onConnection(_ sender: Any) {
        guard viewModel.isActive else {
            return
        }
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
     //MARK:- Upgrade Plan
    @IBAction func onBuy(_ sender: Any) {
        viewModel.buy {
            
        }
    }
    
}


fileprivate extension SecureDNSVC{
    //MARK:- termAndPolicyConfig
    private func termAndPolicyConfig(){
        guard let text = termPolicylbl.text,!text.isEmpty else{return}
             termPolicylbl.setLinkFor("Privacy Policy","Terms of Service") { (label, string) in
            async {
                print("user tapped on \(string) text")
                if string == "Privacy Policy" {
                    self.presentSafari(URL(string:"https://www.websitepolicies.com/policies/view/hGbW4U3q")!)
                }else if string == "Terms of Service"{
                    self.presentSafari(URL(string:"https://www.websitepolicies.com/policies/view/djqN4SDa")!)
                }
                
            }
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
        if viewModel.isActive,KConnected{
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
