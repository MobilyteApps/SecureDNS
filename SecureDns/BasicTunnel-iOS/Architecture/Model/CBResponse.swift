//
//  CBResponse.swift
//  ChatterBox
//
//  Created by Jitendra Kumar on 22/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation

struct CBResponse<T:Mappable> : Mappable {
    var data: T?
    var message:String?
    var success: Bool?
    var code:Int?
    enum CodingKeys:String,CodingKey{
        case success
        case message
        case code = "status code"
        case data
    }
    
    var isSuccess:Bool{
        return success ?? false
    }
    var statusCode: HTTPStatusCode?{
        guard let code = self.code else { return nil }
        return HTTPStatusCode(rawValue: code)
    }
    
    
}
