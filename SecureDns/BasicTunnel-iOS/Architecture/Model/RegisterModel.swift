//
//  RegisterModel.swift
//  Secure DNS
//
//  Created by gagandeepmishra on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation

struct CBSubscription:Mappable,Hashable {
    var timestamp: TimeInterval?
    var receiptData:String
    var productId:String?
    enum CodingKeys: String, CodingKey {
        case productId = "productId"
        case timestamp = "expireDate"
        case receiptData = "receiptData"
        
        
    }
    
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        productId = try container.decodeIfPresent(String.self, forKey: .productId)
        timestamp = try container.decodeIfPresent(TimeInterval.self, forKey: .timestamp)
        receiptData = try container.decodeIfPresent(String.self, forKey: .receiptData) ?? ""
   
    }
    var productType:IAPProductType?{
        guard let vl = productId, !vl.isEmpty else { return nil }
        return IAPProductType(rawValue: vl)
    }
    var expireDate:Date?{
        guard let timestamp = timestamp else { return nil}
        return Date(milliseconds: Int64(timestamp))
    }
    var isActive:Bool{
        guard let end = expireDate else { return false }
        return Date()<end
    }
    static func == (lhs:CBSubscription, rhs:CBSubscription)->Bool{
        return lhs.timestamp == rhs.timestamp && lhs.productId == rhs.productId && lhs.receiptData == rhs.receiptData
    }
}
struct CBRegister:Mappable{
    
    var daysLeft:Int
    var isPremium:Bool
    var subscription:CBSubscription?
    enum CodingKeys: String, CodingKey {
        case daysLeft  = "daysLeft"
        case isPremium,subscription
        
    }
    
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        daysLeft  = try values.decodeIfPresent(Int.self, forKey: .daysLeft) ?? 0
        isPremium =   try values.decodeIfPresent(Bool.self, forKey: .isPremium) ?? false
        subscription = try values.decodeIfPresent(CBSubscription.self, forKey: .subscription)
        
        
    }
    var isTrail:Bool{
        return daysLeft>0
    }
    var isValidService:Bool{
        if isTrail {
            return true
        }else if isPremium{
            return true
        }else{
            return false
        }
    }
   
    
}
struct CBTrail:Mappable,Hashable{
    var uuidString:String
    var timestamp:Int64
    
    enum CodingKeys:String,CodingKey {
        case uuidString = "udid"
        case timestamp = "timestamp"
    }
    var date:Date{
        return Date(milliseconds: timestamp)
    }
    var timestampStr:String{
        return timestamp.description
    }
}
