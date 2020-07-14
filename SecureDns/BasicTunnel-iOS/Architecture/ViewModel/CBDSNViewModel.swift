//
//  APIManager.swift
//  Secure DNS
//
//  Created by Harsh Rajput on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit




class CBDSNViewModel:NSObject{
    
    fileprivate var register:Register?
    fileprivate var iapProduct:IAPProduct?
    static let shared = CBDSNViewModel()
    
    private override init() {
        super.init()
    }
    
    
    func parametrs()->CBParameters{
        return ["userid”:”xnmtyrdx”,”bcode":"HDF"]
    }
    func headers()->CBHTTPHeaders{
        return CBHTTPHeaders(.init(arrayLiteral: .authorization("Basic bXl1c2VyOm15cGFzcw"),.contentType("application/json")))
        
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
                    let rs = data.JKDecoder(Register.self)
                    switch rs {
                    case .success(let vl):
                        self.register = vl
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
    func getIApProduct(completion:@escaping()->Void){
        guard NetworkStatus.shared.isConnected  else{return}
        
        IAPManager.shared.getProducts([.monthly]) {
            async {
                self.iapProduct = IAPManager.shared.count>0 ? IAPManager.shared[at: 0] : nil
                guard let product = self.iapProduct else{return}
                
                //IAPManager.shared.verifyPurchase(product: product, purchaseDetails: <#T##IAPPurchaseDetails?#>, completion: <#T##(Bool) -> Void#>)
            }
        }
    }
    
    
}
extension  CBDSNViewModel{
    var tailValidTime:String{
        guard let vl = register else { return "" }
        return "Premium features enabled:\n" + "\(vl.data?.daysLeft ?? 0)" + " days remaining"
    }
}
struct ErrorMessages {
    static let serverError = "We're having trouble with our server.\nPlease check back after some time."
    static let commonError = "Something went wrong.\nPlease check back after some time."
    static let no_data = "no_data"
    static let no_tags = "no_tags"
    static let no_internet = "You are not connected to the internet."
}
