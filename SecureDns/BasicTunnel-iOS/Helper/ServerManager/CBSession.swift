//
//  CBSession.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import Alamofire


final class CBSession {
    static let shared = CBSession()
   
    private init() {
       
    }
    //MARK- DataRequest
    func request(_ state:CBSessionConfig.State = .default, url: URLConvertible,
                 method: HTTPMethod = .get,
                 parameters: Parameters? = nil,
                 encoding: ParameterEncoding = URLEncoding.default,
                 headers: HTTPHeaders? = nil) -> DataRequest{
       
        return state.session.request(url, method: method, parameters: parameters, encoding: encoding, headers: headers)
    }
    func request<Parameters: Mappable>(_ state:CBSessionConfig.State = .default,url:URLConvertible,
                                       method: HTTPMethod = .get,
                                       parameters: Parameters? = nil,
                                       encoder: ParameterEncoder = URLEncodedFormParameterEncoder.default,
                                       headers: HTTPHeaders? = nil) -> DataRequest{
        return state.session.request(url, method: method, parameters: parameters, encoder: encoder, headers: headers)
    }
    
    


}


