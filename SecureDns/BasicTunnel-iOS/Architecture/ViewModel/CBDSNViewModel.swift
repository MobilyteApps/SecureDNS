//
//  APIManager.swift
//  Secure DNS
//
//  Created by Harsh Rajput on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit




class CBDSNViewModel:NSObject{
    
    fileprivate var register:CBRegister?
    fileprivate var iapProduct:IAPProduct?
    static let shared = CBDSNViewModel()
    var iApManager:IAPManager {return IAPManager.shared}
    
    private override init() {
        super.init()
    }
    
    //MARK:- premiumValidate
    func premiumValidate(completion:@escaping()->Void){
        
        if kTrailData  == nil{
            let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            kTrailData = .init(uuidString: udid, timestamp: Date().timeIntervalSince1970)
        }
        guard NetworkStatus.shared.isConnected , let params = kTrailData?.jsonObject else{return}
        NetworkStatus.shared.showHud()
        CBServer.shared.dataTask(.default, endpoint: .auth(.singUp), method: .post, parameters: params, encoding: .JSON, headers: nil) { (result) in
            async {
                NetworkStatus.shared.hideHud()
                switch result{
                case .success(let data):
                    print("\(String(describing: data.utf8String))")
                    let rs = data.JKDecoder(CBResponse<CBRegister>.self)
                    switch rs {
                    case .success(let vl):
                        self.register = vl.data
                        completion()
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        
                    }
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    func getIApProduct(completion:@escaping(Bool)->Void){
        guard NetworkStatus.shared.isConnected  else{return}
        iApManager.getProducts([.monthly]) {
            async {
                self.iapProduct = IAPManager.shared.count>0 ? IAPManager.shared[at: 0] : nil
                if !self.isTrail {
                    guard let product = self.iapProduct else{return}
                        self.verifyReceipt(true,product: product, purchaseDetails: nil,completion: completion)
                }else{
                    completion(true)
                }
              
                
            }
        }
    }
    //Buy subscription
    func buy(completion:@escaping()->Void){
        
        guard NetworkStatus.shared.isConnected,let product = self.iapProduct  else{return}
        self.iApManager.verifySubscriptionResult = nil
        self.iApManager.purchase(.product(product.product)) { detail in
            let recieptHandler  = { (success:Bool) in
                async {
                    NetworkStatus.shared.hideHud()
                    
                    if success, let p = self.iApManager.verifySubscriptionResult, p.isActive == true{
                        
                    }
                }
            }
            self.verifyReceipt(product: product, purchaseDetails: detail, completion: recieptHandler)
        }
    }
    func verifyReceipt(_ isLoader:Bool = true,product:IAPProduct,purchaseDetails:IAPPurchaseDetails?,completion:@escaping(Bool)->Void){
        self.iApManager.verifyPurchase(isLoader, product: product, purchaseDetails: purchaseDetails, completion: completion)
        
    }
    
}
extension  CBDSNViewModel{
    private var daysLeft:Int{
        guard let vl = register, let days = vl.daysLeft else { return 0 }
        return days
    }
    private var isTrail:Bool{
        return daysLeft>0
    }
    var isActive:Bool{
        if isTrail {
            return true
        }else if self.iApManager.verifySubscriptionResult?.isActive == true{
            return true
        }else{
            return false
        }
        
    }
    var tailValidTime:String{
        if isTrail {
            return "Get Premium features Free trail for:\n" + "\(daysLeft)" + " days remaining"
        }else{
            return "Get full Access to Premium features.\n Purchase the Monthly subscription membership only for:"
        }
        
    }
    var productTitle:String{
        return iapProduct?.localizedTitle ?? ""
        
    }
    var productDescription:String{
        return iapProduct?.localizedDescription ?? ""
    }
    var productPrice:String{
        return iapProduct?.localizedPrice.uppercased() ?? "$2.99 / Month"
    }
}
struct ErrorMessages {
    static let serverError = "We're having trouble with our server.\nPlease check back after some time."
    static let commonError = "Something went wrong.\nPlease check back after some time."
    static let no_data = "no_data"
    static let no_tags = "no_tags"
    static let no_internet = "You are not connected to the internet."
}
