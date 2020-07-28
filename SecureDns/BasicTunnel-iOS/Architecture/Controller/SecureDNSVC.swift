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
var KConnected:NEVPNStatus{
    set{
        guard newValue == .connected || newValue == .disconnected else {
            UserDefaults.removeObject(forKey: kVPNConectedKey)
            return
        }
        UserDefaults.set(integer: newValue.rawValue, forKey: kVPNConectedKey)//set(boolValue: newValue, forKey: kVPNConectedKey)
    }
    get{
        let vl = UserDefaults.getInteger(forKey: kVPNConectedKey)
        guard let st = NEVPNStatus(rawValue: vl) else { return .invalid }
        return st//getBool(forKey: kVPNConectedKey)
    }
}
class SecureDNSVC: UIViewController, URLSessionDataDelegate {
    @IBOutlet fileprivate var conntectionStatusSwitch: UISwitch!
    @IBOutlet fileprivate var connectionStatuslbl: UILabel!
    @IBOutlet fileprivate var connectionBtn: UIButton!
    @IBOutlet fileprivate var leftTrailDayslbl: UILabel!
    @IBOutlet fileprivate var upgradeBtn: UIButton!
    fileprivate var currentManager: NETunnelProviderManager?
    fileprivate var useDNSServers:[String]?
    fileprivate var status: NEVPNStatus = .invalid{
        didSet{
            var isOn:Bool = false
            
            var statusText:String = "Connect"
            switch status {
            case  .connecting:
                statusText = "Connecting..."
                isOn = false
                KConnected = status
            case .connected:
                statusText = "Connected"
                isOn = true
                KConnected = status
            case .disconnected:
                statusText = "Connect"//"Disconnected"
                isOn = false
            case .disconnecting:
                statusText = "Disconnecting..."
                isOn = false
                
            default:
                break
            }
            //self.currentManager?.isOnDemandEnabled = isOn
            // self.currentManager?.isEnabled = isOn
            self.connectionStatuslbl.text = statusText
            self.conntectionStatusSwitch.setOn(isOn, animated: true)
        }
    }
    fileprivate var viewModel:CBDSNViewModel{
        return CBDSNViewModel.shared
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    //MARK:- UIView LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        //resetPref()
        conntectionStatusSwitch.set(width: 130, height: 75)
        addObserver()
        getPremiumValidity()
        reloadCurrentManager()
        reachabilityObserver {isReachable in
            self.reconnection(isRechiblity: isReachable)
        }
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    //MARK:- Check Premium Validity
    
    private func getPremiumValidity(){
        viewModel.register {
            async {
                self.loadData()
                
                
            }
        }
    }
    //MARK:- load Device Register Data
    private func loadData(){
        self.leftTrailDayslbl.text = self.viewModel.alertString
        self.connectionBtn.isUserInteractionEnabled = self.viewModel.isActive
        self.checkVPNStatus()
        
    }
    
    //MARK:- reachabilityObserver
    private func reachabilityObserver(completion:@escaping(Bool)->Void) {
        NetworkStatus.shared.startNotifier { status in
            switch status{
            case .reachable:
                completion(true)
                print("Reachability: Network available 😃")
            case .notReachable:
                print("Reachability: Network unavailable 😟")
                completion(true)
            default:break
            }
        }
        
    }
    
    
    //MARK:- On Click VPN Connection
    @IBAction private func onConnection(_ sender: Any) {
        
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
    
    
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "PaymentSegue" {
            let controller = segue.destination as? PaymentVC
            controller?.didRefresh = {
                async {
                    self.getPremiumValidity()
                }
            }
        }
        
    }
    
    
    
}



private extension SecureDNSVC{
    
    static let appGroup = "group.xyz.dnsbkv.adgap"
    static let tunnelIdentifier = "xyz.dnsbkv.adgap.networkExtension"
    
    //MARK:- make NETunnelProviderProtocol
    func makeProtocol() -> NETunnelProviderProtocol {
        //Bundle.url(forResource: "iosv1", extension: "ovpn")
        guard  let configurationFileURL = viewModel.configFileURL else{
            print("File not found")
            fatalError()
        }
        do {
            let configurationFileContent = try OpenVPN.ConfigurationParser.parsed(fromURL: configurationFileURL)
            
            var builder = OpenVPNTunnelProvider.ConfigurationBuilder(sessionConfiguration: configurationFileContent.configuration)
            builder.shouldDebug = true
            useDNSServers = builder.sessionConfiguration.dnsServers
            //builder.masksPrivateData = false
            let configuration = builder.build()
            return try configuration.generatedTunnelProtocol(withBundleIdentifier: SecureDNSVC.tunnelIdentifier, appGroup: SecureDNSVC.appGroup)
            
        } catch {
            fatalError(error.localizedDescription)
            
            
        }
        
        
    }
    //MARK:- reconnection
    func reconnection(isRechiblity:Bool){
        if isRechiblity {
            if KConnected == .disconnected || status == .disconnected{
                self.connect()
            }else{
                disconnect()
            }
        }else{
            if KConnected == .connected || status == .connected {
                disconnect()
            }
        }
        
        
    }
    //MARK:- connect
    
    func connect() {
        if viewModel.configFileURL != nil {
            
            configureVPN({ (manager) in
                return self.makeProtocol()
            }, completionHandler: { (error) in
                if let error = error {
                    print("configure error: \(error)")
                    return
                }else if let manager  = self.currentManager {
                    ///`isEanble`:Boolean for enable to create VPN
                    manager.isEnabled = true
                   // self.onConnection(true)
                    if let session = manager.connection as? NETunnelProviderSession{
                        do {
                            try session.startTunnel()
                            print("start Tunnel called")
                        } catch let e {
                            print("error starting tunnel: \(e)")
                        }
                    }
                }
                
                
            })
        }else{
            
            viewModel.download {
                async {
                    self.connect()
                }
            }
        }
        
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
            
            
        })
    }
    
    //MARK:- setsOnDemandVPN
    func setsOnDemandVPN(_ isOnDemandEnabled:Bool = false){
        guard let manager = currentManager else { return  }
        ///`enabledOnDemandConnect`: Boleean
        //manager.isOnDemandEnabled = isOnDemandEnabled
        if isOnDemandEnabled {
            if manager.onDemandRules == nil {
                let evaluationRule = NEEvaluateConnectionRule(matchDomains: TLDList.tlds,andAction: NEEvaluateConnectionRuleAction.connectIfNeeded)
                evaluationRule.useDNSServers =  useDNSServers
                let onDemandRule = NEOnDemandRuleEvaluateConnection()
                onDemandRule.connectionRules = [evaluationRule]
                onDemandRule.interfaceTypeMatch = .any
                manager.onDemandRules = [onDemandRule]
               // manager.isOnDemandEnabled = false
            }
            if manager.connection.status != .connected {
                manager.isOnDemandEnabled = false
            }
          
            
        }else{
            manager.onDemandRules = nil
        }
       
        
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
            ///`isEanble`:Boolean for enable to create VPN
            manager.isEnabled = true
            self.setsOnDemandVPN(manager.isOnDemandEnabled)
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
                
            }else if let managers = managers{
                var manager: NETunnelProviderManager?
                if let m = managers.first(where: {$0.protocolConfiguration?.isKind(of: NETunnelProviderProtocol.self) == true}), let p = m.protocolConfiguration as? NETunnelProviderProtocol, p.providerBundleIdentifier == SecureDNSVC.tunnelIdentifier{
                    manager = m
                }
                //                for m in managers {
                //                    if let p = m.protocolConfiguration as? NETunnelProviderProtocol {
                //                        if (p.providerBundleIdentifier == SecureDNSVC.tunnelIdentifier) {
                //                            manager = m
                //                            break
                //                        }
                //                    }
                //                }
                
                if (manager == nil) {
                    manager = NETunnelProviderManager()
                }
                
                self.currentManager = manager
                self.status = manager!.connection.status
                completionHandler?(nil)
            }
            
            
        }
    }
    
    //MARK:- Add Observers
    func addObserver(){
        
        NotificationCenter.default.addObserver(forName: .NEVPNStatusDidChange, object: nil, queue: .main) { noti in
            self.checkVPNStatus()
            
        }
    }
    //MARK:- Remove Observers
    func removeObserver(){
        NotificationCenter.default.removeObserver(self, name: .NEVPNStatusDidChange, object: nil)
        NotificationCenter.default.removeObserver(self, name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    //MARK:- checkVPNStatus
    func checkVPNStatus(){
        guard let status = currentManager?.connection.status else {
            print("VPNStatusDidChange")
            return
        }
        print("VPNStatusDidChange: \(status.rawValue)")
        self.status = status
        
        
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


