//
//  RegisterModel.swift
//  Secure DNS
//
//  Created by gagandeepmishra on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation


struct CBRegister:Mappable{
 
    var daysLeft:Int?
    var userType:String?
    
    enum CodingKeys: String, CodingKey {
        case daysLeft  = "daysLeft"
        case userType    = "userType"
     
        
    }
    
    
    
    init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        daysLeft = try values.decodeIfPresent(Int.self, forKey: .daysLeft)
        userType =   try values.decodeIfPresent(String.self, forKey: .userType)
        
    }
    
}
struct CBTrail:Mappable,Hashable{
    var uuidString:String
    var timestamp:TimeInterval
    
    enum CodingKeys:String,CodingKey {
        case uuidString = "udid"
        case timestamp = "timestamp"
    }
    var date:Date{
        return Date(timeIntervalSince1970: timestamp)
    }
    var timestampStr:String{
        return timestamp.description
    }
}
