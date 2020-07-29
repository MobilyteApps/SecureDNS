//
//  PaymentVC.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 16/07/20.
//  Copyright © 2020 Davide De Rosa. All rights reserved.
//

import UIKit

class PaymentVC: UIViewController {
    @IBOutlet weak private var termPolicylbl: UILabel!
    @IBOutlet fileprivate var purchaseBtn: UIButton!
    
    fileprivate var viewModel:CBDSNViewModel{
        return CBDSNViewModel.shared
    }
    var didRefresh:(()->Void)?
    override func viewDidLoad() {
        super.viewDidLoad()
        termAndPolicyConfig()
        purchaseBtn.backgroundColor = UIColor.greenColor
        
    }
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .lightContent
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        getIApProduct()
    }
    
    private func getIApProduct(){
        if !viewModel.isApProduct {
            viewModel.getIApProduct { success in
                async {
                    self.loadData()
                }
            }
        }else{
            self.loadData()
        }
        
    }
    private func loadData(){
        
        purchaseBtn[title:.normal] = self.viewModel.productPrice
        
    }
    //MARK:- Upgrade Plan
    @IBAction func onBuy(_ sender: Any) {
        viewModel.purchase { success in
            async {
                if success{
                    self.dismiss(animated: true) {
                        self.didRefresh?()
                    }
                }
            }
        }
        
    }
    @IBAction func onCancel(_ sender: Any) {
        self.dismiss(animated: true) {
            
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
fileprivate extension PaymentVC{
    //MARK:- termAndPolicyConfig
    private func termAndPolicyConfig(){
        guard let text = termPolicylbl.text,!text.isEmpty else{return}
        let fullRange  = NSMakeRange(0, text.count)
        let attributedString = NSMutableAttributedString(string: text)
        let textAttributed:[NSAttributedString.Key:Any] = [.font: termPolicylbl.font!,.foregroundColor: termPolicylbl.textColor!]
        attributedString.addAttributes(textAttributed, range: fullRange)
        termPolicylbl.attributedText = attributedString
        termPolicylbl.setLinkFor("Privacy Policy","Terms of Service") { (label, string) in
            async {
                print("user tapped on \(string) text")
                if string == "Privacy Policy" {
                    self.presentSafari(URL(string:"https://adgap.wordpress.com/adgap-privacy-policy")!)
                }else if string == "Terms of Service"{
                    self.presentSafari(URL(string:"https://adgap.wordpress.com/adgap-terms-and-conditions")!)
                }
                
            }
        }
        
    }
}
