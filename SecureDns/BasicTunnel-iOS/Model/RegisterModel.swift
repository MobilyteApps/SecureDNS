//
//  RegisterModel.swift
//  Secure DNS
//
//  Created by gagandeepmishra on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import Foundation

struct Register:Codable{

    let success:Bool?

    let data:RegisterResult?

}

struct RegisterResult:Codable {

    let daysLeft:Int?

    let message:String?

    let statuscode:Int?

    let userType:String?

     enum CodingKeys: String, CodingKey {

           case daysLeft  = "daysLeft"

           case statuscode = "status code"

           case userType    = "userType"

            case message = "message"

       }

    

    init(from decoder: Decoder) throws {

        let values = try decoder.container(keyedBy: CodingKeys.self)

        daysLeft = try values.decodeIfPresent(Int.self, forKey: .daysLeft)

        message =   try values.decodeIfPresent(String.self, forKey: .message)

        statuscode = try values.decodeIfPresent(Int.self, forKey: .statuscode)

        userType =   try values.decodeIfPresent(String.self, forKey: .userType)

    }

}
