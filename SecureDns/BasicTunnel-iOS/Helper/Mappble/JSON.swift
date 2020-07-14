//
//  JSON.swift
//  BasicTunnel-iOS
//
//  Created by Jitendra Kumar on 15/07/20.
//  Copyright © 2020 Davide De Rosa. All rights reserved.
//

import Foundation
enum JSONError:Error {
    case invalidJSONString
    case decodingError
}
class JSON: JSONSerialization {
    
    //MARK:- JSONObject-
    class func JSONObject(string:String)->Result<Any,Error>{
        guard let data = string.data(using: .utf8) else {
            return .failure(JSONError.invalidJSONString)
        }
        return JSONObject(data: data)
    }
    class func JSONObject(data:Data)->Result<Any,Error>{
        do{
            return try .success(self.jsonObject(with:data, options: []))
        } catch  {
            print("json object conversion error%@",error.localizedDescription)
            return .failure(error)
        }
        
    }
    //MARK:- JSONStringify-
    class func JSONStringify(Object: Any, prettyPrinted: Bool = false) -> String{
        let options = prettyPrinted ? self.WritingOptions.prettyPrinted : self.WritingOptions(rawValue: 0)
        let isvalid = JSONSerialization.isValidJSONObject(Object)
        guard isvalid ,let data = try? JSONSerialization.data(withJSONObject: Object, options: options), let jsonString = String(data: data, encoding:.utf8)else { return "" }
        return jsonString
    }
    //MARK:- getJsonData-
    class func JSONData(Object:Any)->Result<Data,Error>{
        do{
            return try .success(self.data(withJSONObject: Object, options: []))
        } catch  {
            print("json error: \(error)")
            return .failure(error)
        }
        
    }
}
