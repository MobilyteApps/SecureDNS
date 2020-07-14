//
//  Mappable.swift
//  Mappable
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

// MARK: - JSON: Codable
typealias Mappable = Codable

extension Encodable{
    func JKEncoder() -> Result<Data,Error> {
        return JSNParser.encoder(self)
    }
    var jsonObject:[String:Any]?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data.object
        default: return nil
        }
        
        
    }
    var jsonObjects:[[String:Any]]?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data.objects as? [[String : Any]]
        default: return nil
            
        }
        
    }
    var jsonString:String?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data.utf8String
            
        default: return nil
            
        }
        
        
    }
    var data:Data?{
        let result  = JKEncoder()
        switch result {
        case .success(let data):return data
        default: return nil
            
        }
    }
    
}

extension Data{
    
    func JKDecoder<T>(_ type:T.Type)->Result<T,Error> where T:Decodable{
        return JSNParser.decoder(T.self, from: self)
    }
    var utf8String:String?{
        return String(bytes: self, encoding: .utf8)
    }
    var object:[String: Any]? {
        return try? JSON.JSONObject(data: self).get() as? [String : Any]
        // return JSONSerialization.JSONObject(data: self) as? [String : Any]
        
    }
    var objects:[Any]? {
        return try? JSON.JSONObject(data: self).get() as? [Any]
        //        guard let listObject = JSONSerialization.JSONObject(data: self) as? [Any] else{return nil}
        //        return listObject
        
    }
    
    func getValue<T>(_ model:T.Type)->T? where T:Decodable{
        let result  = self.JKDecoder(model)
        switch result {
        case .success(let val): return val
        default: return nil
            
        }
    }
}

private struct JSNParser:Equatable{
    
    static func decoder<T>(_ type:T.Type,from data:Data)->Result<T,Error> where T:Decodable{
        do{
            let decoder  = JSONDecoder()
            if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
                decoder.dateDecodingStrategy = .iso8601
            }else{
                decoder.keyDecodingStrategy = .convertFromSnakeCase
            }
            
            let obj  = try decoder.decode(T.self, from: data)
            
            return (.success(obj))
        }catch {
            return (.failure(error))
        }
    }
    static func encoder<T>(_ value: T)->Result<Data,Error> where T : Encodable{
        do{
            let encoder =  JSONEncoder()
            if #available(iOS 10.0, OSX 10.12, tvOS 10.0, watchOS 3.0, *) {
                encoder.dateEncodingStrategy = .iso8601
            }
            encoder.outputFormatting = .prettyPrinted
            let encodeData  = try encoder.encode(value)
            return(.success(encodeData))
            
        }catch{
            return (.failure(error))
        }
    }
}

extension KeyedDecodingContainer where Key: CodingKey {
    
    func decodeDateIfPresent(from key: Key,dateFormat:String) throws -> Date? {
        guard  let dateAsString = try decodeIfPresent(String.self, forKey: key) else{return nil}
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.date(from: dateAsString)
    }
    func decodeURLIfPresent(from key: Key) throws -> URL? {
        guard  let string = try decodeIfPresent(String.self, forKey: key) else{return nil}
        return URL(string: string)
    }
    
}


