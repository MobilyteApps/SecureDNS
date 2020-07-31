//
//  CBMailComposer.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 17/07/20.
//  Copyright © 2020 Mobilyte Inc.. All rights reserved.
//

import Foundation
import MessageUI

typealias CBMailComposerResult = MFMailComposeResult
typealias CBMailComposerHandler = (_ result:Result<CBMailComposerResult, Error>) -> Void

class CBMailComposer: NSObject {
    fileprivate var completionHandler:CBMailComposerHandler?
    lazy fileprivate var mailController :MFMailComposeViewController = {
        let controller  = MFMailComposeViewController()
        return controller
    }()
    private override init() {
        super.init()
        mailController.mailComposeDelegate = self
    }
    class var shared:CBMailComposer {
        struct Singlton{
            static let instance  = CBMailComposer()
        }
        return Singlton.instance
    }
    
    func setSubject(_ subject: String)->CBMailComposer{
        if canSendMail {
             mailController.setSubject(subject)
        }
       
        return self
    }
    func setToRecipients(_ toRecipients:[String]?)->CBMailComposer{
        if canSendMail {
             mailController.setToRecipients(toRecipients)
        }
       
        return self
    }
    func setCcRecipients(_ ccRecipients: [String]?)->CBMailComposer{
        if canSendMail {
            mailController.setCcRecipients(ccRecipients)
        }
        
        return self
    }
    func setBccRecipients(_ bccRecipients: [String]?)->CBMailComposer{
        if canSendMail {
            mailController.setBccRecipients(bccRecipients)
        }
        
        return self
    }
    func setMessageBody(_ body: String, isHTML: Bool)->CBMailComposer{
        if canSendMail {
             mailController.setMessageBody(body, isHTML: isHTML)
        }
       
        return self
    }
    func addAttachmentData(_ attachment: Data, mimeType: String, fileName filename: String)->CBMailComposer{
        if canSendMail {
             mailController.addAttachmentData(attachment, mimeType: mimeType, fileName: filename)
        }
       
        return self
    }
    func setPreferredSendingEmailAddress(_ emailAddress: String)->CBMailComposer{
        if canSendMail {
             mailController.setPreferredSendingEmailAddress(emailAddress)
        }
       
        return self
    }
    var canSendMail:Bool{
        return MFMailComposeViewController.canSendMail()
    }
    
    func showMail(_ controller:UIViewController,completion:@escaping CBMailComposerHandler){
        completionHandler = completion
        if canSendMail {
            controller.present(mailController, animated:true, completion: nil)
        }else{
           // alertMessage =  "Please configure email account first."
            
        }
    }
    
    
    
}

extension CBMailComposer:MFMailComposeViewControllerDelegate{
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
      
        controller.dismiss(animated: true) {
            if error != nil || (result == .failed){
                if let err = error {
                    self.completionHandler?(.failure(err))
                }
                
            }else{
                self.completionHandler?(.success(result))
            }
        }
    }
    
    
}
