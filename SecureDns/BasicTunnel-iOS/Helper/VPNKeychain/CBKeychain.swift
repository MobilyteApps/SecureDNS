//
//  CBKeychain.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 14/07/20.
//  Copyright © 2020 Mobilyte Inc.. All rights reserved.
//

import Foundation

// MARK: - *** Public methods ***
public final class CBKeychain {
    public static var allowBackgroundAccess = false
    
    
    @discardableResult public class func set<T: TypeSafeKeychainValue>(_ value: T?, forKey key: String) -> Bool {
        guard let value = value else {
            removeValue(forKey: key)
            return true
        }
        if valueExists(forKey: key) {
            return update(value, forKey: key)
        } else {
            return create(value, forKey: key)
        }
    }
    
    public class func value<T: TypeSafeKeychainValue>(forKey key: String) -> T? {
        guard let valueData = valueData(forKey: key) else { return nil }
        
        return T.value(data: valueData)
    }
    
    @discardableResult public class func removeValue(forKey key:String) -> Bool {
        return deleteValue(forKey: key)
    }
    
    @discardableResult public class func reset() -> Bool {
        
        let searchDictionary = basicDictionary()
        let status = SecItemDelete(searchDictionary as CFDictionary)
        return status == errSecSuccess
    }
    
    public class func allValues() -> [[String: String]]?  {
        
        var searchDictionary = basicDictionary()
        
        searchDictionary[kSecMatchLimit as String] = kSecMatchLimitAll
        searchDictionary[kSecReturnAttributes as String] = kCFBooleanTrue
        searchDictionary[kSecReturnData as String] = kCFBooleanTrue
        
        var retrievedAttributes: AnyObject?
        var retrievedData: AnyObject?
        
        var status = SecItemCopyMatching(searchDictionary as CFDictionary, &retrievedAttributes)
        if status != errSecSuccess {
            return nil
        }
        
        status = SecItemCopyMatching(searchDictionary as CFDictionary, &retrievedData)
        guard status == errSecSuccess,
            let attributeDicts = retrievedAttributes as? [[String: AnyObject]] else { return nil }
        
        var allValues = [[String : String]]()
        for attributeDict in attributeDicts {
            guard let keyData = attributeDict[kSecAttrAccount as String] as? Data,
                let valueData = attributeDict[kSecValueData as String] as? Data,
                let key = String(data: keyData, encoding: .utf8),
                let value = String(data: valueData, encoding: .utf8) else { continue }
            allValues.append([key: value])
        }
        
        return allValues
    }
    
    public class func set<T>(encoder object: T , forKey key : String)->Bool  where T : Codable {
        guard  let data  = object.data else {
            removeValue(forKey: key)
            return true
        }
        if valueExists(forKey: key) {
            return update(data, forKey: key)
        } else {
            return create(data, forKey: key)
        }
        
    }
    @discardableResult public class func get<T>(decoder objectType: T.Type , forKey key : String)->T?  where T : Codable {
        guard let valueData = valueData(forKey: key) else { return nil }
        let result = valueData.JKDecoder(objectType)
        switch result {
        case .success(let val):return val
        default: return nil
            
        }
        
        
    }
}

// MARK: - *** Private methods ***
fileprivate extension CBKeychain {
    
    class func valueExists(forKey key: String) -> Bool {
        return valueData(forKey: key) != nil
    }
    
    class func create<T: TypeSafeKeychainValue>(_ value: T, forKey key: String) -> Bool {
    
        return self.create( value.data(), forKey: key)
    }
    
    class func update<T: TypeSafeKeychainValue>(_ value: T, forKey key: String) -> Bool {
        return self.update(value.data(), forKey: key)
    }
    class func create(_ data: Data?, forKey key: String) -> Bool {
        var dictionary = newSearchDictionary(forKey: key)
        dictionary[kSecValueData as String] = data
        let status = SecItemAdd(dictionary as CFDictionary, nil)
        return status == errSecSuccess
    }
    class func update(_ data: Data?, forKey key: String) -> Bool {
        
        let searchDictionary = newSearchDictionary(forKey: key)
        var updateDictionary = [String: Any]()
        
        updateDictionary[kSecValueData as String] = data
        
        let status = SecItemUpdate(searchDictionary as CFDictionary, updateDictionary as CFDictionary)
        
        return status == errSecSuccess
    }
    
    
    @discardableResult class func deleteValue(forKey key: String) -> Bool {
        let searchDictionary = newSearchDictionary(forKey: key)
        let status = SecItemDelete(searchDictionary as CFDictionary)
        
        return status == errSecSuccess
    }
    
    class func valueData(forKey key: String) -> Data?  {
        
        var searchDictionary = newSearchDictionary(forKey: key)
        
        searchDictionary[kSecMatchLimit as String] = kSecMatchLimitOne
        searchDictionary[kSecReturnData as String] = kCFBooleanTrue
        
        var retrievedData: AnyObject?
        let status = SecItemCopyMatching(searchDictionary as CFDictionary, &retrievedData)
        
        var data: Data?
        if status == errSecSuccess {
            data = retrievedData as? Data
        }
        
        return data
    }
    
    class func newSearchDictionary(forKey key: String) -> [String: Any] {
        let encodedIdentifier = key.data(using: .utf8, allowLossyConversion: false)
        
        var searchDictionary = basicDictionary()
        searchDictionary[kSecAttrGeneric as String] = encodedIdentifier
        searchDictionary[kSecAttrAccount as String] = encodedIdentifier
        
        return searchDictionary
    }
    
    class func basicDictionary() -> [String: Any] {
        
        let serviceName = Bundle(for: self).infoDictionary![kCFBundleIdentifierKey as String] as! String
        
        var dict: [String: Any] = [kSecClass as String : kSecClassGenericPassword, kSecAttrService as String : serviceName]
        if allowBackgroundAccess {
            dict[kSecAttrAccessible as String] = kSecAttrAccessibleAfterFirstUnlock
        }
        return dict
    }
    
    
    
    
}
//MARK: - TypeSafeKeychainValue
public protocol TypeSafeKeychainValue {
    func data() -> Data?
    static func value(data: Data) -> Self?
}

extension String: TypeSafeKeychainValue {
    public func data() -> Data? {
        return data(using: .utf8, allowLossyConversion: false)
    }
    public static func value(data: Data) -> String? {
        return String(data: data, encoding: .utf8)
    }
}

extension Int: TypeSafeKeychainValue {
    public func data() -> Data? {
        var value = self
        return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
    }
    public static func value(data: Data) -> Int? {
        return data.withUnsafeBytes { $0.load(as: Int.self) }
    }
}
extension Double: TypeSafeKeychainValue {
    public func data() -> Data? {
        var value = self
        return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
    }
    public static func value(data: Data) -> Double? {
        return data.withUnsafeBytes { $0.load(as: Double.self) }
    }
}

extension Bool: TypeSafeKeychainValue {
    public func data() -> Data? {
        var value = self
        return Data(bytes: &value, count: MemoryLayout.size(ofValue: value))
    }
    public static func value(data: Data) -> Bool? {
        return data.withUnsafeBytes { $0.load(as: Bool.self) }
    }
}

extension Date: TypeSafeKeychainValue {
    public func data() -> Data? {
        return NSKeyedArchiver.archivedData(withRootObject: (self as NSDate))
    }
    public static func value(data: Data) -> Date? {
        return NSKeyedUnarchiver.unarchiveObject(with: data) as? Date
    }
}


