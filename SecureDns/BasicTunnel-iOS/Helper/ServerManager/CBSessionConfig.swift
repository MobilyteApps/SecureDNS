//
//  CBSessionConfig.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 29/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import Foundation
import Alamofire

class CBSessionConfig:NSObject{
    enum State:Int{
        case `default` = 0
        case background
        var session:Alamofire.Session{
            switch self {
            case .background:return CBSessionConfig.shared.background
            case .default: return CBSessionConfig.shared.default
            }
        }
        func cancelRequest(_ url:String){
            session.request(url).cancel()
        }
        func cancelAllRequests(){
            session.cancelAllRequests()
        }
        // cancel pending requests
        func cancelPendingRequests(){
            session.session.getTasksWithCompletionHandler { (sessionDataTask, uploadData, downloadData) in
                sessionDataTask.forEach { $0.cancel() }
                uploadData.forEach { $0.cancel() }
                downloadData.forEach { $0.cancel() }
            }
        }
        
        
    }
    override private init() {
        super.init()
    }
    static let shared = CBSessionConfig()
    fileprivate lazy var background: Alamofire.Session = {
        let bundleIdentifier = Bundle.main.bundleIdentifier
        let configure  =  URLSessionConfiguration.af.init(.background(withIdentifier: bundleIdentifier! + ".background"))
        // configure.timeoutIntervalForRequest = 30
        var session = Alamofire.Session(configuration:configure.type)
        return session
    }()
    
    fileprivate lazy var `default`: Alamofire.Session = {
        let configure  = URLSessionConfiguration.af.default
        configure.timeoutIntervalForRequest = 30
        return Alamofire.Session(configuration: configure)
    }()
    
    //MARK:-documentsDirectoryURL-
    lazy var documentsDirectoryURL:URL = {
       // FileManager.default.urls(for: .downloadsDirectory, in: .userDomainMask).first
        
        let documents = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
        return documents
    }()
    
    
}
