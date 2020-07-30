//
//  APIManager.swift
//  Secure DNS
//
//  Created by Harsh Rajput on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import UIKit

class CBDSNViewModel:NSObject{
    
    fileprivate var iapProduct:IAPProduct?
    var configFileURL:URL?
    static let shared = CBDSNViewModel()
    var iApManager:IAPManager {return IAPManager.shared}
    
    private override init() {
        super.init()
    }
    
    //MARK:- premiumValidate
    func register(completion:@escaping()->Void){
        kUserData = nil
        if kTrailData  == nil{
            let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
            let trailExpireDate = Date().futureDate(.day, value: 15)
            kTrailData = .init(uuidString: udid, timestamp: trailExpireDate.millisecondsSince1970)
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
                        kUserData = vl.data
                        if kUserData?.downloadableConfig == true {
                            self.download(completion: completion)
                        }else{
                           completion()
                        }
                        
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        
                    }
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
            }
        }
    }
    //MARK:- Get InApp Product
    func getIApProduct(completion:@escaping(Bool)->Void){
        guard NetworkStatus.shared.isConnected  else{return}
        iApManager.getProducts([.monthly]) {
            async {
                self.iapProduct = IAPManager.shared.count>0 ? IAPManager.shared[at: 0] : nil
                completion(true)
            }
        }
    }
    //MARK:- purchase
    func purchase(completion:@escaping(Bool)->Void){
        
        guard NetworkStatus.shared.isConnected,let product = self.iapProduct  else{return}
        self.iApManager.verifySubscriptionResult = nil
        self.iApManager.purchase(.product(product.product)) { detail in
            let recieptHandler  = { (success:Bool) in
                async {
                    //NetworkStatus.shared.hideHud()
                    if success, let p = self.iApManager.verifySubscriptionResult, p.isActive == true{
                        self.subscribe(product: p, completion: completion)
                    }
                }
            }
            self.verifyReceipt(product: product, purchaseDetails: detail, completion: recieptHandler)
        }
    }
    //MARK:- verifyReceipt
    func verifyReceipt(_ isLoader:Bool = true,product:IAPProduct,purchaseDetails:IAPPurchaseDetails?,completion:@escaping(Bool)->Void){
        self.iApManager.verifyPurchase(isLoader, product: product, purchaseDetails: purchaseDetails, completion: completion)
        
    }
    //MARK:- Buy Subscriber
    func subscribe(product:IAPVerifySubscription,completion:@escaping(Bool)->Void){
        guard NetworkStatus.shared.isConnected,let parameters  = product.parameters else {
            NetworkStatus.shared.hideHud()
            return
        }
        
        let handler  = {(_ result:Result<Data,Error>) in
            async {
                NetworkStatus.shared.hideHud()
                switch result {
                case .success(let data):
                    let parser = data.JKDecoder(CBResponse<CBRegister>.self)
                    switch parser {
                    case .success(let res):
                        if res.isSuccess {
                            if let subscription  = res.data {
                                kTrailData?.timestamp = Date().millisecondsSince1970
                                kUserData = subscription
                                completion(true)
                            }
                            
                        }else{
                            completion(false)
                        }
                        
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        completion(false)
                    }
                case .failure(let error):
                    alertMessage = error.localizedDescription
                    completion(false)
                }
            }
        }
        
        CBServer.shared.dataTask(.default, endpoint: CBEndpoint.subscription(.buySubscription), method: .post, parameters: parameters, encoding: .JSON, headers: nil, completion: handler)
        
    }
    //MARK:- Download OVPN Config File
    func download(completion:@escaping()->Void){
        
        guard NetworkStatus.shared.isConnected, let uuid = kTrailData?.uuidString else {
            NetworkStatus.shared.hideHud()
            return
        }
    
        let result = FileManager.getfile(filename: "\(uuid).ovpn")
        switch result {
        case .success(let url):
            configFileURL = url
            completion()
        default:
            guard kUserData?.downloadableConfig == true else {
                return
            }
            NetworkStatus.shared.showHud(progressMode: .HorizontalBar,hudPosition: .bottom, message: "Downloading config file...")
            CBServer.shared.downloadTask(endpoint: .ovpnConfigFile(udid: uuid), completion: {result  in
                async {
                    NetworkStatus.shared.hideHud()
                    switch result{
                    case .success(let url):
                        if let url  = url {
                            self.configFileURL = url
                            completion()
                        }else{
                            self.download(completion: completion)
                        }
                        
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                    }
                }
            }, downloadProgress: {progress in
                NetworkStatus.shared.progress = progress.fractionCompleted
            })
        }
        
    }
    
    
}
extension CBDSNViewModel{
    
    var isApProduct:Bool{
        return self.iapProduct != nil
    }
    private var isValidService:Bool{
        guard let vl = kUserData else { return false}
        return vl.isValidService
    }
    var isActive:Bool{
        if isValidService {
            return true
        }else if self.iApManager.verifySubscriptionResult?.isActive == true{
            return true
        }else{
            return false
        }
        
    }
    var alertString:String{
        guard let vl = kUserData else { return "Your free trial has ended.\n Please click on subscribe here to subscribe monthly subscription."}
        if vl.isTrail {
            return "Click on subscribe here to subscribe free trial ends in \(vl.daysLeft) days."
        }else{
            return "Your free trial has ended.\n Please click on subscribe here to subscribe monthly subscription."
            
        }
    }
    var productTitle:String{
        return iapProduct?.localizedTitle ?? ""
        
    }
    var productDescription:String{
        return iapProduct?.localizedDescription ?? ""
    }
    var productPrice:String{
        return iapProduct?.localizedPrice ?? "$2.99/ month"
    }
}

