//
//  SupportVC.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 28/07/20.
//  Copyright © 2020 Davide De Rosa. All rights reserved.
//

import UIKit

class SupportVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        
    }
    
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    @IBAction private func onCancel(_ sender: UIButton) {
        self.dismiss(animated: true, completion: nil)
    }
    
    @IBAction private func onReport(_ sender: UIButton) {
        
         let subject:String = (!Bundle.kAppTitle.isEmpty && !Bundle.kAppVersionString.isEmpty && !Bundle.kBuildNumber.isEmpty) ?
            """
            Report bugs for \(Bundle.kAppTitle)
            version:\(Bundle.kAppVersionString)
            Build:\(Bundle.kBuildNumber)
            """ :"Report bugs "
                   if CBMailComposer.shared.canSendMail{
                    
                       CBMailComposer.shared.setToRecipients(["adgapsoft@gmail.com"])
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
                    

                   }else{
                       
                   }
    }
    @IBAction private func OnDemand(_ sender:UIButton){
        self.dismiss(animated: true) {
            if #available(iOS 10, *) {
                // "App-prefs:root=VPN"
                if let configURL = URL(string: "App-prefs:root=General&path=Network/VPN"),UIApplication.shared.canOpenURL(configURL){
                    UIApplication.shared.open(configURL, options: [:], completionHandler: nil)
                }else{
                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: nil)
                }
                
            }else{
                if let configURL = URL(string: "App-prefs:root=General&path=Network/VPN"),UIApplication.shared.canOpenURL(configURL){
                    UIApplication.shared.open(configURL)
                }else{
                    UIApplication.shared.openURL(URL(string: UIApplication.openSettingsURLString)!)
                }
            }
        }
        
        
        
        
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destination.
     // Pass the selected object to the new view controller.
     }
     */
    
}
