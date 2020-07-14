//
//  Default.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit

extension UserDefaults{
    private static var standard = UserDefaults.standard
    
    static func set(integer: Int , forKey key : String){
        standard.set(integer, forKey: key)
        standard.synchronize()
    }
    static func set(floatValue:Float, forKey key:String){
        standard.set(floatValue, forKey: key)
        standard.synchronize()
    }
    static func set(doubleValue:Double, forKey key:String){
        standard.set(doubleValue, forKey: key)
        standard.synchronize()
    }
    static func set(object: Any , forKey key : String){
        standard.set(object, forKey: key)
        standard.synchronize()
    }
    static func set(value: Any , forKey key : String){
        standard.setValue(value, forKey: key)
        standard.synchronize()
    }
    static func set(boolValue:Bool,forKey key : String){
        standard.set(boolValue, forKey : key)
        standard.synchronize()
    }
    static func set(stringValue:String,forKey key:String){
        standard.set(stringValue, forKey: key)
        standard.synchronize()
    }
    static func set(urlValue:URL,forKey key:String){
        standard.set(urlValue, forKey: key)
        standard.synchronize()
    }
    static func getInteger(forKey  key: String) -> Int{
        let integerValue  = standard.integer(forKey: key)
        standard.synchronize()
        return integerValue
    }
    static func getFloat(forKey  key: String) -> Float{
        let floatValue  = standard.float(forKey: key)
        standard.synchronize()
        return floatValue
    }
    static func getDouble(forKey  key: String) -> Double{
        let doubleValue  = standard.double(forKey: key)
        standard.synchronize()
        return doubleValue
    }
    static func getString(forKey key:String)->String{
        let string = standard.string(forKey: key) ?? ""
        standard.synchronize()
        return string 
    }
    static func getUrl(forKey key:String)->URL?{
        let url = standard.url(forKey: key)
        standard.synchronize()
        return url
    }
    static func getObject(forKey  key: String) -> Any?{
        let object  = standard.object(forKey: key)
        standard.synchronize()
        return object
    }
    static func getValue(forKey  key: String) -> Any? {
        let value  = standard.value(forKey: key)
        standard.synchronize()
        return value
        
    }
    static func getBool(forKey  key : String) -> Bool {
        let booleanValue = standard.bool(forKey: key)
        standard.synchronize()
        return booleanValue
    }
    
    //Save no-premitive data
    static func set<T>(archivedObject object: T , forKey key : String) {
        do {
            let data = try NSKeyedArchiver.archivedData(withRootObject: object, requiringSecureCoding: true)
            standard.set(data, forKey: key)
            standard.synchronize()
        }catch let err{
            print(err.localizedDescription)
        }
    }
    static func get<T>(unarchiverObject object:T.Type,forKey key: String) -> T? {
        //var objectValue : Any?
        guard  let storedData  = standard.object(forKey: key) as? Data else{ return nil}
        do{
            let object  = try NSKeyedUnarchiver.unarchiveTopLevelObjectWithData(storedData) as? T
            return object
        }catch let err{
            print(err.localizedDescription)
        }
        return nil
    }
    
    static func set<T>(encoder object: T , forKey key : String)  where T : Codable {
        
        guard  let data  = object.data else {return}
        standard.set(data, forKey: key)
        standard.synchronize()
        
    }
    static func get<T>(decoder objectType: T.Type , forKey key : String)->T?  where T : Codable {
        guard  let storedData  = standard.object(forKey: key) as? Data else{ return nil}
        let result = storedData.JKDecoder(objectType)
        switch result {
        case .success(let val):return val
        default: return nil
            
        }
        
        
    }
    static func removeObject(forKey key: String) {
        standard.removeObject(forKey: key)
        standard.synchronize()
    
    }
    
}



