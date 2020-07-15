//
//  String+Ex.swift
//  ChatterBox
//
//  Created by Jitendra Kumar on 23/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
struct Validator{
    
    enum Validate {
     
        case predicate(SPredicate)
        
        func formatter(in string: String)->Bool{
            switch self {
           
            case .predicate(let field):
                return field.evaluate(with: string)
            }
        }
    }

    enum SPredicate {
       
        case validateUrl
        var regularExp:String{
            switch self {
            
            case .validateUrl: return "(http|https)://((\\w)*|([0-9]*)|([-|_])*)+([\\.|/]((\\w)*|([0-9]*)|([-|_])*))+"
                
            }
        }
        var predicate:NSPredicate{
            return NSPredicate(format: "SELF MATCHES %@", self.regularExp)
        }
        func evaluate(with object: Any?) -> Bool{
            return predicate.evaluate(with: object)
        }
        
        
    }
    
}


extension String{
    //MARK:- String Validation
    
    //MARK:- validFormatter
    func validFormatter(_ formate:Validator.Validate)->Bool{
        guard !self.isEmpty else {return false}
        return formate.formatter(in: self)
    }
   
    //MARK:- isValidateUrl
    var isValidateUrl : Bool {
        return validFormatter(.predicate(.validateUrl))
    }
    
   
    //MARK:- urlQueryEncoding
    /// Returns a new string made from the `String` by replacing all characters not in the unreserved
    /// character set (As defined by RFC3986) with percent encoded characters.
    
    var urlQueryEncoding: String? {
        let allowedCharacters = CharacterSet.urlQueryAllowed
        return self.addingPercentEncoding(withAllowedCharacters: allowedCharacters)
        
    }
    //MARK:- isEqualTo
    func isEqualTo(other:String)->Bool{
        return self.caseInsensitiveCompare(other) == .orderedSame ? true : false
    }
}
