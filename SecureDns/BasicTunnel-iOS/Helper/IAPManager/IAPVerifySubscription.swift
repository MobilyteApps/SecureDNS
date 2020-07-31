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
    var expiredDate:Date
    var recieptsItems:[IAPReceiptItem] = []
    var purchaseDetail:IAPPurchaseDetails
    var receiptString:String?
    var product:IAPProduct
    var status:CBSubscription.Status = .notPurchased
    var productType:IAPProductType?{
        return product.productType
    }
    
    var expiredTimestamp:Int64?{
        return expiredDate.millisecondsSince1970
    }
    var receiptItem:IAPReceiptItem?{
        guard let type = productType else { return nil }
        return self[type]
    }
    var cancellationDate:Date?{
        guard let item = receiptItem else {return nil}
        return item.cancellationDate
    }
    
    subscript(productId:IAPProductType)->IAPReceiptItem?{
        return recieptsItems.first(where:{$0.productId == productType?.identifier})
    }
    var isPurchased:Bool{
        return self.status == .purchased
    }
    var isExpired:Bool{
        return self.status == .expired
    }
    var isNotPurchased:Bool{
        return self.status == .notPurchased
        
    }
    var isCancelled:Bool{
        return cancellationDate != nil
    }
    var isActive:Bool{
        if isCancelled == false {
            return true
        }else if  Date() < expiredDate{
            return true
        }else{
            return false
        }
      
        
    }
    var orginalTransactionId:String?{
        if let originalTransaction =  purchaseDetail.originalTransaction{
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
