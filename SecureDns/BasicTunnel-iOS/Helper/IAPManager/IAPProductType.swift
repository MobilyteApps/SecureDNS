//
//  IAPProductType.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 24/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import UIKit
import SwiftyStoreKit
enum IAPProductType:String,Hashable,Mappable {
    
    case monthly = "ADGAP001"
    
    var identifier:String{
        return self.rawValue
    }
   
    var subscriptionType:SubscriptionType{
        switch self {
        case .monthly: return .autoRenewable
       
        }
    }
    
    
    
    
}
