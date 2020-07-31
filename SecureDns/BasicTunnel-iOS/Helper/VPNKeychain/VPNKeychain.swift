//
//  VPNKeychain.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 04/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
enum VPNKeychain {
  
    /// Returns a persistent reference for a generic password keychain item, adding it to
    /// (or updating it in) the keychain if necessary.
    ///
    /// This delegates the work to two helper routines depending on whether the item already
    /// exists in the keychain or not.
    ///
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    ///   - password: The desired password.
    /// - Returns: A persistent reference to the item.
    /// - Throws: Any error returned by the Security framework.
  
    static func persistentReferenceFor(service: String, account: String, password: Data) throws -> Data {
        var copyResult: CFTypeRef? = nil
        let err = SecItemCopyMatching([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecReturnPersistentRef: true,
            kSecReturnData: true
        ] as NSDictionary, &copyResult)
        switch err {
            case errSecSuccess:
                return try self.persistentReferenceByUpdating(copyResult: copyResult!, service: service, account: account, password: password)
            case errSecItemNotFound:
                return try self.persistentReferenceByAdding(service: service, account:account, password: password)
            default:
                try throwOSStatus(err)
                // `throwOSStatus(_:)` only returns in the `errSecSuccess` case.  We know we're
                // not in that case but the compiler can't figure that out, alas.
                fatalError()
        }
    }
  
    /// Returns a persistent reference for a generic password keychain item by updating it
    /// in the keychain if necessary.
    ///
    /// - Parameters:
    ///   - copyResult: The result from the `SecItemCopyMatching` done by `persistentReferenceFor(service:account:password:)`.
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    ///   - password: The desired password.
    /// - Returns: A persistent reference to the item.
    /// - Throws: Any error returned by the Security framework.
  
    private static func persistentReferenceByUpdating(copyResult: CFTypeRef, service: String, account: String, password: Data) throws -> Data {
        let copyResult = copyResult as! [String:Any]
        let persistentRef = copyResult[kSecValuePersistentRef as String] as! NSData as Data
        let currentPassword = copyResult[kSecValueData as String] as! NSData as Data
        if password != currentPassword {
            let err = SecItemUpdate([
                kSecClass: kSecClassGenericPassword,
                kSecAttrService: service,
                kSecAttrAccount: account,
            ] as NSDictionary, [
                kSecValueData: password
            ] as NSDictionary)
            try throwOSStatus(err)
        }
        return persistentRef
    }
  
    /// Returns a persistent reference for a generic password keychain item by adding it to
    /// the keychain.
    ///
    /// - Parameters:
    ///   - service: The service name for the item.
    ///   - account: The account for the item.
    ///   - password: The desired password.
    /// - Returns: A persistent reference to the item.
    /// - Throws: Any error returned by the Security framework.
  
    private static func persistentReferenceByAdding(service: String, account: String, password: Data) throws -> Data {
        var addResult: CFTypeRef? = nil
        let err = SecItemAdd([
            kSecClass: kSecClassGenericPassword,
            kSecAttrService: service,
            kSecAttrAccount: account,
            kSecValueData: password,
            kSecReturnPersistentRef: true,
        ] as NSDictionary, &addResult)
        try throwOSStatus(err)
        return addResult! as! NSData as Data
    }
  
    /// Throws an error if a Security framework call has failed.
    ///
    /// - Parameter err: The error to check.
  
    private static func throwOSStatus(_ err: OSStatus) throws {
        guard err == errSecSuccess else {
            throw NSError(domain: NSOSStatusErrorDomain, code: Int(err), userInfo: nil)
        }
    }
}
