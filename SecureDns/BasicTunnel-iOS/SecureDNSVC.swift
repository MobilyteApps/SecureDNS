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
import Reachability
import NotificationCenter




class SecureDNSVC: UIViewController, URLSessionDataDelegate {
    @IBOutlet fileprivate var switchConntectionStatus: UISwitch!
    @IBOutlet fileprivate var lblConnection: UILabel!
    @IBOutlet fileprivate var buttonConnection: UIButton!
    @IBOutlet fileprivate weak var labelDayleft: UILabel!
    
    fileprivate var currentManager: NETunnelProviderManager?
    fileprivate var status = NEVPNStatus.invalid
    fileprivate var isConnected = false
    
    //MARK:- UIView LifeCycle
    override func viewDidLoad() {
        super.viewDidLoad()
        switchConntectionStatus.set(width: 130, height: 75)
        getPremiumValidity()
        
        NetworkReachability.shared.startNotifier()
        reachabilityObserver()
        NotificationCenter.default.addObserver(self,selector: #selector(VPNStatusDidChange(notification:)),name: .NEVPNStatusDidChange,object: nil)
        reloadCurrentManager()
        
        
    }
    
    //MARK:- Check Premium Validity
    func getPremiumValidity(){
        let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let timeStemp = NSDate().timeIntervalSince1970.description
        let params:[String:Any] = ["udid" : udid, "timestamp":timeStemp]
        let UrlEndpoints = "http://poc.mobilytedev.com:8067/app/userdata/getRegistered"
        ApiManager.shared.post(url: UrlEndpoints, params: params) { (res:Register?, err) in
            if let error = err {
                print("error in forgot password api :\(error)")
            } else {
                guard let resp = res else {return}
                print("resp in create user api : \(resp)")
                let v = "Premium features enabled:\n" + "\(resp.data?.daysLeft ?? 0)" + " days remaining"
                self.labelDayleft.text = v
                
                
            }
        }
    }
    //MARK:- reconnection
    func reconnection(){
        if let connection = UserDefaults.standard.value(forKey: "isConnected")as? Bool, connection == true{
            self.connect()
        }else{
            self.disconnect()
        }
    }
    //MARK:- reachabilityObserver
    func reachabilityObserver() {
        
        NetworkReachability.shared.reachabilityObserver = { [weak self] status in
            switch status {
            case .connected:
                print("Reachability: Network available 😃")
                DispatchQueue.main.async {
                    self?.reconnection()
                }
                
            case .disconnected:
                print("Reachability: Network unavailable 😟")
                UserDefaults.standard.set(true, forKey: "isConnected")
                
                
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
        updateButton()
    }
    //MARK:- connectionClicked
    @IBAction func connectionClicked(_ sender: Any) {
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
    
    
    
    
    //MARK:- updateButton Status
    fileprivate func updateButton() {
        switch status {
        case  .connecting:
            self.lblConnection.text = "Connecting..."
            self.switchConntectionStatus.setOn(false, animated: true)
            //self.switchConntectionStatus.isOn = false
            //buttonConnection.setImage(#imageLiteral(resourceName: "grey-off"), for: .normal)
            
            self.isConnected = false
            UserDefaults.standard.set(false, forKey: "isConnected")
        case .connected:
            self.lblConnection.text = "Connected"
            //self.switchConntectionStatus.isOn = true
            self.switchConntectionStatus.setOn(true, animated: true)
            //buttonConnection.setImage(#imageLiteral(resourceName: "green"), for: .normal)
            self.isConnected = true
            UserDefaults.standard.set(true, forKey: "isConnected")
            
        case .disconnected:
            
            self.lblConnection.text = "Disconnected..."
            //self.switchConntectionStatus.isOn = false
            self.switchConntectionStatus.setOn(false, animated: true)
            
            //buttonConnection.setImage(#imageLiteral(resourceName: "grey-off"), for: .normal)
            
            self.isConnected = false
            
        case .disconnecting:
            self.lblConnection.text = "Disconnecting..."
            // self.switchConntectionStatus.isOn = false
            self.switchConntectionStatus.setOn(false, animated: true)
            
            //buttonConnection.setImage(#imageLiteral(resourceName: "grey-off"), for: .normal)
            
            self.isConnected = false
            
        default:
            break
        }
    }
    
    
    
    
    
}

extension SecureDNSVC {
    private static let appGroup = "group.com.infostride.VPNDemo"
    private static let tunnelIdentifier = "com.infostride.VPNDemo.Extension"
    
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
}

extension SecureDNSVC{
    fileprivate func connect() {
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
    
    
    fileprivate func disconnect() {
        configureVPN({ (manager) in
            print(manager.description)
            return nil
        }, completionHandler: { (error) in
            if let err = error{
                print(err.localizedDescription)
            }
            self.currentManager?.connection.stopVPNTunnel()
            self.isConnected = false
            UserDefaults.standard.set(false, forKey: "isConnected")
        })
    }
    fileprivate  func configureVPN(_ configure: @escaping (NETunnelProviderManager) -> NETunnelProviderProtocol?, completionHandler: @escaping (Error?) -> Void) {
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
    
    fileprivate  func reloadCurrentManager(_ completionHandler: ((Error?) -> Void)? = nil) {
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
            self.updateButton()
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
