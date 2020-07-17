//
//  CBMailComposer.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 17/07/20.
//  Copyright © 2020 Davide De Rosa. All rights reserved.
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
        mailController.delegate = self
    }
    class var shared:CBMailComposer {
        struct Singlton{
            static let instance  = CBMailComposer()
        }
        return Singlton.instance
    }
    
    func setSubject(_ subject: String)->CBMailComposer{
        mailController.setSubject(subject)
        return self
    }
    func setToRecipients(_ toRecipients:[String]?)->CBMailComposer{
        mailController.setToRecipients(toRecipients)
        return self
    }
    func setCcRecipients(_ ccRecipients: [String]?)->CBMailComposer{
        mailController.setCcRecipients(ccRecipients)
        return self
    }
    func setBccRecipients(_ bccRecipients: [String]?)->CBMailComposer{
        mailController.setBccRecipients(bccRecipients)
        return self
    }
    func setMessageBody(_ body: String, isHTML: Bool)->CBMailComposer{
        mailController.setMessageBody(body, isHTML: isHTML)
        return self
    }
    func addAttachmentData(_ attachment: Data, mimeType: String, fileName filename: String)->CBMailComposer{
        mailController.addAttachmentData(attachment, mimeType: mimeType, fileName: filename)
        return self
    }
    func setPreferredSendingEmailAddress(_ emailAddress: String)->CBMailComposer{
        mailController.setPreferredSendingEmailAddress(emailAddress)
        return self
    }
    
    
    func showMail(_ controller:UIViewController,completion:@escaping CBMailComposerHandler){
        completionHandler = completion
        if MFMailComposeViewController.canSendMail() {
            controller.present(mailController, animated:true, completion: nil)
        }else{
           // alertMessage =  "Please configure email account first."
        }
    }
    
    
    
}

extension CBMailComposer:MFMailComposeViewControllerDelegate, UINavigationControllerDelegate{
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
