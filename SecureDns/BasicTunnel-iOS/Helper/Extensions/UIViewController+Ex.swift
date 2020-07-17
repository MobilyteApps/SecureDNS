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
        
        let alertModel = AlertControllerModel(contentViewController: nil, title: title,message: message, titleFont: UIFont.systemFont(ofSize: 17, weight: .semibold),messageFont: UIFont.systemFont(ofSize: 15, weight: .regular))
        var actions:[AlertActionModel] = [AlertActionModel]()
        
        let alertActionTitle = AlertActionModel.Title(title: cancelTitle,titleColor: .systemBlue)
        let cancel = AlertActionModel( actionTitle: alertActionTitle, style: .cancel)
        actions.append(cancel)
        if let otherTitle = otherTitle {
            let alertActionTitle = AlertActionModel.Title(title: otherTitle,titleColor: .systemBlue)
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
    /// `SFSafariViewController`Open Link on Safari App
      func presentSafari(_ link:URL) {
          //if link.absoluteString.isValidateUrl {
              let constroller = SFSafariViewController(url: link)
              constroller.preferredControlTintColor = .blueColor3
              self.present(constroller, animated: true, completion: nil)
          
          
      }
    
}
public extension UIColor{
    class var blueColor3:UIColor {return #colorLiteral(red: 0.1019607843, green: 0.1176470588, blue: 0.2392156863, alpha: 1)}
}
