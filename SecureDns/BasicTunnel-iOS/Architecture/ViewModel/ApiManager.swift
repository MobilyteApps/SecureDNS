//
//  APIManager.swift
//  Secure DNS
//
//  Created by Harsh Rajput on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import UIKit

class CBDSNViewModel:NSObject{
    fileprivate var register:Register?
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
    
    
    
    func premiumValidate(completion:@escaping()->Void){
        guard NetworkStatus.shared.isConnected else{
            
            return
        }
        let udid = UIDevice.current.identifierForVendor?.uuidString ?? ""
        let timeStemp = NSDate().timeIntervalSince1970.description
        let params:[String:Any] = ["udid" : udid, "timestamp":timeStemp]
        CBServer.shared.dataTask(.default, endpoint: .auth(.singUp), method: .post, parameters: params, encoding: .JSON, headers: nil) { (result) in
            async {
                switch result{
                case .success(let data):
                    print("\(String(describing: data.utf8String))")
                    let rs = data.JKDecoder(Register.self)
                    switch rs {
                    case .success(let vl):
                        self.register = vl
                        
                    case .failure(let error):
                        alertMessage = error.localizedDescription
                        
                    }
                    
                    
                case .failure(let error):
                    print(error.localizedDescription)
                }
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
