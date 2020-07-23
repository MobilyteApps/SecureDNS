//
//  NetworkStatus.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 29/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import Alamofire

class NetworkStatus:NSObject{
    static let shared = NetworkStatus()
    fileprivate var jkHud:JKProgressHUD!
    var isConnected:Bool{
        guard let isReachable = NetworkReachabilityManager.default?.isReachable else {
            AppPermission.network.show()
            return false }
        return isReachable
    }
    var progress:Double = 0.0{
        didSet{
            self.jkHud.progress = Float(progress)
        }
    }
    func startNotifier(completion:@escaping(NetworkReachabilityManager.NetworkReachabilityStatus)->Void){
        NetworkReachabilityManager.default!.startListening(onUpdatePerforming: completion)
    }
    
    //MARK:- showProgressHud-
    func showHud(inView view:UIView = AppDelegate.shared.window!, progressMode:JKProgressHUD.HudStyle = .Indeterminate,message title:String = ""){
        
        self.hideHud()
        self.jkHud = JKProgressHUD.showProgressHud(inView: view, progressMode: progressMode, titleLabel: title)
        self.jkHud.islineColors = true
        self.jkHud.setNeedsLayout()
        
    }
    
    //MARK:- hideHud-
    func hideHud(){
        if let jkHud = jkHud {
            self.progress = 0.0
            jkHud.hideHud()
            
        }
        
    }
}
enum AppPermission {
    case network
    
    func show(){
        var title:String = kAppTitle
        var message:String?
        switch self {
        case .network:
            title = "\"\(kAppTitle)\" \(kConnectionError)"
            message = "The Internet connection appears to be offline."
        }
        AppSettingAlert(title: title, message: message)
    }
    
}
