//
//  APIManager.swift
//  Secure DNS
//
//  Created by Harsh Rajput on 04/06/20.
//  Copyright © 2020 Harsh Rajput. All rights reserved.
//

import Foundation
import Alamofire
import UIKit
class ApiManager:NSObject{
    
    static let shared = ApiManager()
    private override init() {
        
    }
    
    
    func parametrs()->Parameters{
        return ["userid”:”xnmtyrdx”,”bcode":"HDF"] as Parameters
    }
    func headers()->HTTPHeaders{
        return ["Authorization": "Basic bXl1c2VyOm15cGFzcw",
                "Content-Type": "application/json"] as HTTPHeaders
    }
    
    static var isConnectedToInternet:Bool {
        return NetworkReachabilityManager()?.isReachable ?? false
    }
    
    // post
    func post<T:Codable>(url:String,params:[String:Any], completion: @escaping (T?, _ error:String?) -> ()){
        
        if ApiManager.isConnectedToInternet == false {
            completion(nil,ErrorMessages.no_internet)
            return
        }
        
        AF.request(url, method: .post, parameters: params, encoding: JSONEncoding.default, headers: nil).responseData { (response) in
            print(response)
            switch response.result {
            case .success(let data):
                do {
                    let dModel = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any]
                    print(dModel)
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completion(model,nil)
                } catch let jsonErr {
                    completion(nil,jsonErr.localizedDescription)
                }
            case .failure(let err):
                completion(nil,err.localizedDescription)
            }
        }
    }
    
    // get
    func get<T:Codable>(url:String,params:[String:Any]?, completion: @escaping (T?, _ error:String?) -> ()) {
        
        if ApiManager.isConnectedToInternet == false {
            completion(nil,ErrorMessages.no_internet)
            return
        }
        
        AF.request(url, method: .get, parameters: params, encoding: URLEncoding.default, headers: nil).responseData { (response) in
            switch response.result {
            case .success(let data):
                do {
                    let model = try JSONDecoder().decode(T.self, from: data)
                    completion(model,nil)
                } catch let jsonErr {
                    completion(nil,jsonErr.localizedDescription)
                }
            case .failure(let err):
                completion(nil,err.localizedDescription)
            }
        }
    }
    
    // cancel pending requests
    func cancelPendingRequests(){
        Alamofire.Session.default.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
            sessionDataTask.forEach { $0.cancel() }
            uploadData.forEach { $0.cancel() }
            downloadData.forEach { $0.cancel() }
        }
    }
}

struct ErrorMessages {
    static let serverError = "We're having trouble with our server.\nPlease check back after some time."
    static let commonError = "Something went wrong.\nPlease check back after some time."
    static let no_data = "no_data"
    static let no_tags = "no_tags"
    static let no_internet = "You are not connected to the internet."
}
