//
//  SecureDNSVC.swift
//  Demo
//
//  Created by Jitendra Kumar on 08/07/20.
//  Copyright © 2020 Mobilyte Inc. All rights reserved.
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
        UserDefaults.set(integer: newValue.rawValue, forKey: kVPNConectedKey)
    }
    get{
        let vl = UserDefaults.getInteger(forKey: kVPNConectedKey)
        guard let st = NEVPNStatus(rawValue: vl) else { return .invalid }
        return st
    }
}
class SecureDNSVC: UIViewController{
    @IBOutlet fileprivate var switchBtn: UISwitch!
    @IBOutlet fileprivate var statuslbl: UILabel!
    @IBOutlet fileprivate var statusDetaillbl: UILabel!
    @IBOutlet fileprivate var connectionBtn: UIButton!
    @IBOutlet fileprivate var leftTrailDayslbl: UILabel!
    @IBOutlet fileprivate var upgradeBtn: UIButton!
    @IBOutlet fileprivate var indicator: JKIndicatorView!
    //fileprivate var useDNSServers:[String]?
    fileprivate lazy var currentManager: NETunnelProviderManager = {
        return NETunnelProviderManager()
    }()
    
    
    fileprivate var isAnimating:Bool = false{
        didSet{
            if isAnimating {
                indicator.isHidden = false
                indicator.startAnimation()
            }else{
                indicator.stopAnimation()
                indicator.isHidden = true
            }
            
        }
    }
    fileprivate var status: NEVPNStatus = .invalid{
        didSet{
            KConnected = status
            let isOn:Bool = (status == .connected || status == .connecting || status == .reasserting) ? true : false
            self.statuslbl.text = status.title.uppercased()
            self.statuslbl.textColor = status.titleColor
            statusDetaillbl.text = status.description
            isAnimating = (status == .connecting || status == .reasserting) ? true : false
            self.switchBtn.setOn(isOn, animated: true)
            
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
        resetPref()
        self.switchBtn.onTintColor =  .greenColor
        self.switchBtn.tintColor = .offColor
        self.upgradeBtn.backgroundColor = .greenColor
        self.status = .invalid
        switchBtn.set(width: 130, height: 75)
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
        self.upgradeBtn.isEnabled = !self.viewModel.isSubcribed
        self.upgradeBtn[title:.normal] = self.viewModel.subscibeBtnText
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
           // useDNSServers = builder.sessionConfiguration.dnsServers
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
                }else{
                    let manager  = self.currentManager
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
            self.currentManager.connection.stopVPNTunnel()
            
            
        })
    }
    
    //MARK:- setsOnDemandVPN
   /* func setsOnDemandVPN(_ isOnDemandEnabled:Bool = false){
        // guard let manager = currentManager else { return  }
        ///`enabledOnDemandConnect`: Boleean
        if isOnDemandEnabled {
            if currentManager.onDemandRules == nil {
                let evaluationRule = NEEvaluateConnectionRule(matchDomains: TLDList.tlds,andAction: NEEvaluateConnectionRuleAction.connectIfNeeded)
                evaluationRule.useDNSServers =  useDNSServers
                let onDemandRule = NEOnDemandRuleEvaluateConnection()
                onDemandRule.connectionRules = [evaluationRule]
                onDemandRule.interfaceTypeMatch = .any
                currentManager.onDemandRules = [onDemandRule]
                //manager.isOnDemandEnabled = false
            }
            //            if manager.connection.status != .connected {
            //                manager.isOnDemandEnabled = false
            //            }
            
            
        }else{
            currentManager.onDemandRules = nil
        }
        
        
    }*/
    //MARK:- configureVPN
    func configureVPN(_ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?, completionHandler: @escaping (Error?) -> Void) {
        reloadCurrentManager { (error) in
            if let error = error {
                print("error reloading preferences: \(error)")
                completionHandler(error)
                return
            }
            
            let manager = self.currentManager
            if let protocolConfiguration = configure(manager) {
                manager.protocolConfiguration = protocolConfiguration
            }
            ///`isEanble`:Boolean for enable to create VPN
            manager.isEnabled = true
            // self.setsOnDemandVPN(true)
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
                //var manager: NETunnelProviderManager?
                if let m = managers.first(where: {$0.protocolConfiguration?.isKind(of: NETunnelProviderProtocol.self) == true}), let p = m.protocolConfiguration as? NETunnelProviderProtocol, p.providerBundleIdentifier == SecureDNSVC.tunnelIdentifier{
                    self.currentManager = m
                }
                self.status =  self.currentManager.connection.status
                completionHandler?(nil)
            }
            
            
        }
    }
    
    //MARK:- Add Observers
    func addObserver(){
        NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { noti in
            self.getPremiumValidity()
        }
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
        self.status = currentManager.connection.status
        print("VPNStatusDidChange: \(self.status.title)")
        
        
        
    }
    
}


extension NEVPNStatus:CustomStringConvertible{
    var title:String{
        switch self {
        case .disconnected,.invalid: return "disconnected"
        case .connecting: return "connecting"
        case .connected: return "connected"
        case .reasserting: return "reconnecting"
        case .disconnecting: return "disconnecting"
        default:
            return ""
        }
    }
    public var description: String {
        switch self {
        case .disconnected: return ""
        case .connecting,.reasserting: return "Securing your connection..."
        case .connected: return "Your Internet is Protected."
        case .disconnecting: return "Your Internet is not Protected."
        default:
            //invalid
            return "\(kAppTitle) is not configured on your device."
        }
    }
    var titleColor:UIColor{
        switch self {
        case .connected: return .greenColor
        default:
            return .white
        }
    }
    
    
    
}
