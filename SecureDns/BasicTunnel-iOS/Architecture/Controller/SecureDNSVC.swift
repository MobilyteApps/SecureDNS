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
        
    }
    
    //MARK:- Check Premium Validity
    private func getPremiumValidity(){
        viewModel.premiumValidate {
            async {
                self.loadData()
                
            }
        }
    }
    
    private func loadData(){
        self.leftTrailDayslbl.text = self.viewModel.tailValidTime
        self.connectionBtn.isUserInteractionEnabled = self.viewModel.isActive
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
    
    @IBAction func onShare(_ sender: UIButton) {
        
        guard let url = URL(string: "https://apps.apple.com/us/app/ADGAP/id1523477415?ls=1&mt=8")  else {return}
        let objectsToShare:[Any] = ["Adgap Protects your phone from ads and malware websites. Protect what matters!",url]
        let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: [])
        self.present(activityVC, animated: true, completion: nil)
        
    }
    @IBAction func onReport(_ sender: UIButton) {
        
        self.showAlertAction(title: "Report bugs", message: "do you want to Report bugs of current verion \(kAppTitle) application.", cancelTitle: "NO", otherTitle: "YES") { index in
            if index == 2{
                let subject:String = (!Bundle.kAppTitle.isEmpty && !Bundle.kAppVersionString.isEmpty && !Bundle.kBuildNumber.isEmpty) ? "Report bugs for \(Bundle.kAppTitle), version:\(Bundle.kAppVersionString),Build:\(Bundle.kBuildNumber)" :"Report bugs "
                CBMailComposer.shared.setBccRecipients(["Adgap@gmail.com"])
                    .setSubject(subject)
                    .setMessageBody("<p>This is message text.</p>", isHTML: true)
                    .showMail(self) { result in
                        async {
                            switch result{
                            case .success(let vl):
                                switch vl {
                                case .sent:
                                    alertMessage = "Mail successfully sent"
                                default:break
                                }
                            case .failure(let err):
                                alertMessage = "Mail sent failure: \(err.localizedDescription)"
                            }
                        }
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
