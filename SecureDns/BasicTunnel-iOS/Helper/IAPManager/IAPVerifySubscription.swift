//
//  IAPVerifySubscription.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 24/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import SwiftyStoreKit
struct IAPVerifySubscription {
    var subscriptionResult:IAPVerifySubscriptionResult
    var pruchaseDetail:IAPPurchaseDetails?
    var receiptString:String?
    var product:IAPProduct
    
    var productType:IAPProductType?{
        return product.productType
    }
    var expiredRecieptData:(expiryDate:Date, recieptsItem:[IAPReceiptItem])?{
        let vl = self.subscriptionResult
        switch vl {
        case .expired(expiryDate: let expiryDate, items: let items):return(expiryDate,items)
        default:return nil
            
        }
    }
    var purchasedRecieptData:(expiryDate:Date, recieptsItem:[IAPReceiptItem])?{
        let vl = self.subscriptionResult
        switch vl {
        case .purchased(expiryDate: let expiryDate, items: let items):return(expiryDate,items)
        default:return nil
            
        }
    }
    
    var expiredDate:Date?{
        if let expireDate = purchasedRecieptData?.expiryDate {
            return expireDate
        }else if let expireDate = expiredRecieptData?.expiryDate{
            return expireDate
        }else{
            return nil
        }
    }
    var expiredTimestamp:Int64?{
        guard let interval = expiredDate?.millisecondsSince1970 else { return nil }
        return interval
    }
    var receiptItem:IAPReceiptItem?{
        guard let type = productType else { return nil }
        return self[type]
    }
    var cancellationDate:Date?{
        guard let item = receiptItem else {return nil}
        return item.cancellationDate
    }
    
    subscript(productType:IAPProductType)->IAPReceiptItem?{
        if let  purchased = purchasedRecieptData {
            return purchased.recieptsItem.first(where:{$0.productId == productType.identifier})
        }else if let expired = expiredRecieptData{
            return expired.recieptsItem.first(where: {$0.productId == productType.identifier})
        }else{
            return nil
        }
    }
    var isPurchased:Bool{
        let vl = self.subscriptionResult
        switch vl {
        case .purchased: return true
        default:return false
            
        }
    }
    var isExpired:Bool{
        let vl = self.subscriptionResult
        switch vl {
        case .expired: return true
        default:return false
            
        }
    }
    var isNotPurchased:Bool{
        let vl = self.subscriptionResult
        switch vl {
        case .notPurchased: return true
        default:return false
            
        }
    }
    var isCancelled:Bool{
        return cancellationDate != nil
    }
    var isActive:Bool{
        if let expireDate = expiredDate {
            return Date() < expireDate
        }else if isCancelled == false{
            return true
        }else{
            return false
        }
    }
    var orginalTransactionId:String?{
        if let detail = pruchaseDetail,let originalTransaction =  detail.originalTransaction{
            return originalTransaction.transactionIdentifier
        }else if let productType = self.productType, let v = self[productType]{
            return v.originalTransactionId
        }else{
            return nil
        }
    }
    var parameters:[String:Any]?{
        print("orginalTransactionId \(String(describing: orginalTransactionId))")
        guard let receiptString =  self.receiptString, let expiredDate  = self.expiredTimestamp , let trail = kTrailData else { return nil}
        return["udid":trail.uuidString,"productId":product.productIdentifier,"expireDate":expiredDate,"receiptData":receiptString]
        
    }
    
}
