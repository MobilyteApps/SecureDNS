//
//  UIViewController+Ex.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import SafariServices
extension UIViewController{
    
    
    
    
    //MARK: - modalPresentation
    func modalPresentation(){
        self.modalTransitionStyle(.crossDissolve)
        self.modalPresentationStyle(.overCurrentContext)
    }
    //MARK: - modalPresentation
    func popoverPresentation(){
        self.modalTransitionStyle(.crossDissolve)
        self.modalPresentationStyle(.popover)
    }
    
    //MARK: - modalFromSheet
    func modalFromSheet(){
        self.modalTransitionStyle(.crossDissolve)
        self.modalPresentationStyle(.formSheet)
    }
    func modalTransitionStyle(_ style:UIModalTransitionStyle){
        self.modalTransitionStyle = style
    }
    func modalPresentationStyle(_ style:UIModalPresentationStyle){
        self.modalPresentationStyle = style
        
    }
    
    //MARK:- showAlert-
    func showAlert(title:String = kAppTitle,message:String?,completion:((_ didSelectIndex:Int)->Swift.Void)? = nil){
        
        self.alertControl(title: title, message: message, cancelTitle: "OK", otherTitle: nil, onCompletion: completion)
    }
    
    fileprivate func alertControl(title:String = kAppTitle,message:String?,cancelTitle:String = "OK",otherTitle:String?,onCompletion:((_ didSelectIndex:Int)->Swift.Void)? = nil){
        
        let msge  = (message != nil && !message!.isEmpty) ? "\n\(message!)" : nil
        let alertModel = AlertControllerModel(contentViewController: nil, title: title, message: msge)
        var actions:[AlertActionModel] = [AlertActionModel]()
        
        let alertActionTitle = AlertActionModel.Title(title: cancelTitle)
        let cancel = AlertActionModel( actionTitle: alertActionTitle, style: .cancel)
        actions.append(cancel)
        if let otherTitle = otherTitle {
            let alertActionTitle = AlertActionModel.Title(title: otherTitle)
            let other = AlertActionModel(actionTitle:alertActionTitle, style: .default)
            actions.append(other)
        }
        
        _ = UIAlertController.showAlert(from: self, controlModel: alertModel, actions: actions) { (alert:UIAlertController, action:UIAlertAction, index:Int) in
            if let handler = onCompletion {
                handler(index)
            }
            
        }
    }
    
    
    
}
extension UIViewController{
    
    
    //MARK: - showLogoutAlert -
    func showLogoutAlert(title:String = kAppTitle,message:String = "Are you sure you want to sign out?", completion: (() -> Swift.Void)? = nil){
        self.showAlertAction(title: title, message: message, cancelTitle: "NO", otherTitle: "YES") { (buttonIndex) in
            switch buttonIndex {
            case 2:
                completion?()
                break
                
            default:
                break
            }
        }
        
    }
    
    
    //MARK:- showAlert-
    func showAlertAction(title:String = kAppTitle,message:String?,cancelTitle:String = "Cancel",otherTitle:String = "OK",onCompletion:@escaping (_ didSelectIndex:Int)->Void){
        self.alertControl(title: title, message: message, cancelTitle: cancelTitle, otherTitle: otherTitle, onCompletion: onCompletion)
    }
    
    
}
