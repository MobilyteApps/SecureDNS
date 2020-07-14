//
//  IAPProduct.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 24/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import StoreKit
struct IAPProduct {
    
    var product:SKProduct
    var isSelected:Bool = false
    init(product:SKProduct, isSelected:Bool = false) {
        self.product = product
        self.isSelected = isSelected
    }
    var productType:IAPProductType?{
        return IAPProductType(rawValue: productIdentifier)
    }
    var productIdentifier:String{
        return product.productIdentifier
    }
    var localizedPrice:String{
        return "Subscription \(product.localizedPrice ?? "")/ \(self.localizedPeriodUnit)"
    }
    var localizedTitle:String{
        return product.localizedTitle
    }
    var localizedDescription:String{
        return product.localizedDescription
    }
    var price:NSDecimalNumber{
        return product.price
    }
    
    var subscriptionPeriod:SKProductSubscriptionPeriod?{
        return product.subscriptionPeriod
    }
    var numberOfUnits:Int{
        return product.subscriptionPeriod?.numberOfUnits ?? 1
    }
    var periodUnit:SKProduct.PeriodUnit?{
        return product.subscriptionPeriod?.unit
    }
    
    var introductoryPrice:SKProductDiscount?{
        return product.introductoryPrice
    }
    
    var paymentMode: SKProductDiscount.PaymentMode? { return introductoryPrice?.paymentMode }
    @available(iOS 12.2, *)
    var type: SKProductDiscount.`Type`? { return introductoryPrice?.type }
    
    var localizedPeriodUnit:String{
        guard let periodUnit = periodUnit else { return "45 days" }
        switch periodUnit {
        case .day : return "day"
        case .week: return "week"
        case .month: return "month"
        default: return "year"
            
        }
    }
    
    
    
}
