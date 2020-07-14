//
//  Bundle.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//
import Foundation
import UIKit
extension Bundle{
    
    private static let bundle = Bundle.main
    static var kAppStoreReceiptURL:URL?{
       return bundle.appStoreReceiptURL
    }
    static var kBundleURLTypes:[ [String: AnyObject] ] {
        guard let urlTypes = bundle.object(forInfoDictionaryKey:"CFBundleURLTypes") as? [ [String: AnyObject] ] else{ return []}
        return urlTypes
    }
    static var kBundleURLSchemes:[String]{
        var urlSchemes = [String]()
        for urlType in kBundleURLTypes{
            if let schemes = urlType["CFBundleURLSchemes"] as? [String] {
                for scheme in schemes {
                    urlSchemes.append(scheme)
                }
            }
        }
        return urlSchemes

       
    }

    static var kBundleDisplayName:String? { guard let name = bundle.object(forInfoDictionaryKey: "CFBundleDisplayName") as? String else{return nil}
        return name
    }
    static var kBundleName:String? {
        guard let name = bundle.object(forInfoDictionaryKey: String(kCFBundleNameKey)) as? String else{return nil}
        return name
    }
    static var kAppTitle:String {
        if let bndlName = kBundleDisplayName,!bndlName.isEmpty {
            return bndlName
        }else if let bndlName = kBundleName,!bndlName.isEmpty{
            return bndlName
        }else{
            return ""
        }
    }
    static var kAppVersionString: String{
        guard let version = bundle.object(forInfoDictionaryKey: String(kCFBundleVersionKey)) as? String else{return ""}
        return version
    }
    static var kBuildNumber: String{
        guard let buildnumber = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String else{return ""}
        return buildnumber
    }
    static var kBundleID:String{return bundle.bundleIdentifier ?? ""}
    static var kAppGroupId:String{
        guard let buildnumber = bundle.object(forInfoDictionaryKey: "AppGroupId") as? String else{return ""}
        return buildnumber
       
    }
    static var kAppIcon:UIImage? {
        get{
            guard let icons = bundle.infoDictionary?["CFBundleIcons"]  as? [String: Any], let primaryIcon = icons["CFBundlePrimaryIcon"] as? [String: Any],let iconFiles = primaryIcon["CFBundleIconFiles"] as? [String] else{return nil}
            if let fistIcon = iconFiles.first {
                return UIImage.init(named: fistIcon)
            }else if let lastIcon = iconFiles.last {
                return UIImage.init(named: lastIcon)
            }else{
                return nil
            }
            
            
            
        }
        
    }
    static func path(forResource name:String?,ofType type:String?)->String?{
        return self.bundle.path(forResource: name, ofType: type)
    }
    static func url(forResource name:String?,extension ex:String?)->URL?{
        return self.bundle.url(forResource: name, withExtension: ex)
    }
}
extension FileManager{
   class func fileExists(atPath path: String)->Bool{
        return FileManager.default.fileExists(atPath: path)
    }
}
