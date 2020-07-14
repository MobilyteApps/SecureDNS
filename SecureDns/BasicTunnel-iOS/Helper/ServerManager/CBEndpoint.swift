//
//  CBEndpoint.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 01/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import Alamofire

private let kServerType = ServerType.dev


enum CBEndpoint {
    case auth(Auth)
    case subscription(Subscription)
    case custom(String)
    
    var url:String{
        switch self {
        case .auth(let auth): return auth.url
        case .custom(let val):return "\(val)"
       
        case .subscription(let subscription):
            return subscription.url
        
            
        }
    }
    
    enum Auth:String {
        
     
        case singUp = "getRegistered"
        
        
        var url:String {
            switch self {
            case .singUp:
                return "\(kServerType.path)/userdata/\(self.rawValue)"
           
            }
        }
        
    }
    enum Subscription{
        case receiptVerify
        var url:String {
            switch self {
            case .receiptVerify:
                return "\(kServerType.path)/subscription/validate"
                
                
            }
        }
        
    }
   
    
}

enum ServerType:String{
    case dev = "http://poc.mobilytedev.com:8067"
    case live = "http://161.35.195.27"//"http://3.128.4.122:3000"
    var path:String{
        
        return "\(self.rawValue)/app"
    }
    
}
extension Dictionary {
    var queryString: String {
        var output: String = ""
        for (key,value) in self {
            output +=  "\(key)=\(value)&"
        }
        output = String(output.dropLast())
        return output
    }
    mutating func merge(with dictionary: Dictionary) {
        dictionary.forEach { updateValue($1, forKey: $0) }
    }
    func merged(with dictionary: Dictionary) -> Dictionary {
        var dict = self
        dict.merge(with: dictionary)
        return dict
    }
}
