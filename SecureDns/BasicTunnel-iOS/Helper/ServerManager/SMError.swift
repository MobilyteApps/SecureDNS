//
//  SMError.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 03/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
struct SMError: Error {
    var localizedTitle: String
       var localizedDescription: String
       var code: Int
   
    
    init(localizedTitle: String?, localizedDescription: String, code: Int) {
        self.localizedTitle = localizedTitle ?? kAppTitle
        self.localizedDescription = localizedDescription
        self.code = code
       
    }
}
