//
//  CBConstant.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import UIKit


func async(onCompletion:@escaping()->Void){
    DispatchQueue.main.async {
        onCompletion()
    }
    
}
func asyncExecute(onCompletion:@escaping()->Void){
    DispatchQueue.main.async(execute: {
        onCompletion()
    })
}

var rootController:UIViewController?{
    return AppDelegate.shared.window?.rootViewController
}
var currentController:UIViewController?{
    
    if let navController  =  rootController as? UINavigationController {
        if  let visibleViewController = navController.visibleViewController{
            return visibleViewController
        }else{
            return navController
        }
    }else if let tabBarController  =  rootController as? UITabBarController, let navController = tabBarController.selectedViewController as? UINavigationController{
        if  let visibleViewController = navController.visibleViewController{
            return visibleViewController
        }else{
            return tabBarController
        }
    }
    return nil
}

var currentAlert:UIViewController?{
    
    if let controller = currentController as? UINavigationController{
        if  let visibleViewController = controller.visibleViewController{
            if let currentAlert = visibleViewController.presentedViewController as? UIAlertController{
                return currentAlert
            }else if let currentAlert = visibleViewController as? UIAlertController {
                return currentAlert
            }else{
                return visibleViewController
            }
            
        }else{
            if let currentAlert = controller.presentedViewController as? UIAlertController{
                return currentAlert
                
            }else{
                return controller
            }
        }
    }else if let controller = currentController  {
        if let currentAlert = controller.presentedViewController as? UIAlertController{
            return currentAlert
            
        }else{
            return controller
        }
    }else{
        return nil
    }
}
var alertMessage: String? {
    didSet{
        async {
            guard let controller  =  currentAlert else {return}
            
            if let alertController = controller as? UIAlertController{
                let messageFont  =  UIFont.systemFont(ofSize: 15, weight: .regular)
                alertController.set(message: alertMessage, font: messageFont, color: .white)
            }else{
                controller.showAlert(message: alertMessage)
            }
            
        }
    }
}
func AppSettingAlert(title:String,message:String?){
    async {
        guard let controller  =  currentAlert else {return}
        if let alertController = controller as? UIAlertController{
            let messageFont  =  UIFont.systemFont(ofSize: 17)
            alertController.set(message: alertMessage, font: messageFont, color: .white)
        }else{
            controller.showAlertAction(title: title, message: message, cancelTitle: "OK", otherTitle: "Settings") { (index) in
                if index == 2{
                    if #available(iOS 10, *) {
                        UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                    }
                    else{
                        UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                    }
                }
            }
        }
        
    }
}

var kTrailData:CBTrail?{
    set{
        guard let vl = newValue else {
            CBKeychain.removeValue(forKey: kTrailDataKey)
            return
        }
        _ = CBKeychain.set(encoder: vl, forKey: kTrailDataKey)
    }
    get{
        return CBKeychain.get(decoder: CBTrail.self, forKey: kTrailDataKey)
    }
}
var kUserData:CBRegister?{
    set{
        guard let  model = newValue else {
            UserDefaults.removeObject(forKey: kUserDataKey)
            return
        }
        UserDefaults.set(encoder:model, forKey: kUserDataKey)
    }
    get{
        return UserDefaults.get(decoder: CBRegister.self, forKey: kUserDataKey)
    }
}

func resetPref(){
    // UserDefaults.removeObject(forKey: kVPNConectedKey)
    kUserData = nil
    kTrailData = nil
   
}


struct Platform {
    static let isSimulator: Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
        isSim = true
        #endif
        return isSim
    }()
    static var isPhone:Bool {
        return UIDevice.current.userInterfaceIdiom == .phone ? true :false
    }
}

var kAppImage:UIImage?          {get{ return Bundle.kAppIcon }}
var kAppTitle :String           {get{return Bundle.kAppTitle}}
let kConnectionError        = "No Internet Connection!☹"
let kTrailDataKey           = "TrailData"
let kVPNConectedKey         = "VPNConected"
let kUserDataKey         = "UserDataKey"

