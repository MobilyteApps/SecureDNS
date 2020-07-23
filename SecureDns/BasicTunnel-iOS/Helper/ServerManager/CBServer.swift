//
//  CBServer.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 22/05/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import Alamofire

typealias CBServerResponse<Success> = (Swift.Result<Success, Error>)->Void
typealias CBServerProgress = (Progress) -> Void
typealias CBHTTPHeaders = HTTPHeaders
typealias CBHTTPHeader = HTTPHeader
typealias CBParameters = Parameters

final class CBServer: NSObject {
    
    static let shared = CBServer()
    struct CBEncoder {
        enum DataEncoding {
            case URL
            case JSON
            
            var `default`:ParameterEncoding{
                switch self {
                case .JSON:return JSONEncoding.default
                default: return URLEncoding.default
                    
                }
            }
        }
        enum JSONEncoder {
            case URL
            case JSON
            
            var `default`:ParameterEncoder{
                switch self {
                case .JSON:return JSONParameterEncoder.default
                default: return URLEncodedFormParameterEncoder.default
                    
                }
            }
        }
    }
    
  
 
    //MARK:- dataTask
    func dataTask(_ state:CBSessionConfig.State = .default, endpoint: CBEndpoint,
                  method: HTTPMethod = .post,
                  parameters: CBParameters? = nil,
                  encoding: CBEncoder.DataEncoding = .URL,
                  headers: CBHTTPHeaders? = nil,completion:@escaping CBServerResponse<Data>){
        print(String(describing: parameters))
        CBSession.shared.request(state,url: endpoint.url, method: method, parameters: parameters, encoding: encoding.default, headers: headers).responseData { dataResponse in
            let result  = dataResponse.result
            switch result{
            case .success(let data):
                completion(.success(data))
            case .failure(let error):
                completion(.failure(error))
            }
            
            
        }.resume()
    }
    
    //MARK:- JSON DataTask
    func dataTask<T:Mappable>(_ state:CBSessionConfig.State = .default, endpoint: CBEndpoint,
                              method: HTTPMethod = .post,
                              parameters: CBParameters? = nil,
                              encoding: CBEncoder.DataEncoding = .URL,
                              headers: CBHTTPHeaders? = nil,completion:@escaping CBServerResponse<T>){
        CBSession.shared.request(state,url: endpoint.url, method: method, parameters: parameters, encoding: encoding.default, headers: headers).responseData { response in
            self.decodableResponse(dataResponse: response, completion: completion)
            
        }.resume()
    }
    func dataTask<T: Mappable>(_ state:CBSessionConfig.State = .default, endpoint: CBEndpoint,
                               method: HTTPMethod = .post,
                               parameters: T? = nil,
                               encoder: CBEncoder.JSONEncoder = .JSON,
                               headers: CBHTTPHeaders? = nil,completion:@escaping CBServerResponse<T>){
        
        CBSession.shared.request(state, url: endpoint.url, method: method, parameters: parameters, encoder: encoder.default, headers: headers).responseData { response in
            
            self.decodableResponse(dataResponse: response, completion: completion)
            
            
        }.resume()
        
    }

    
    //MARK:- DownloadTask
    func downloadTask(_ state:CBSessionConfig.State = .default, endpoint: CBEndpoint,
                      method: HTTPMethod = .get,
                      headers: CBHTTPHeaders? = nil,completion:@escaping CBServerResponse<URL?>, downloadProgress:@escaping CBServerProgress){
        let destination: DownloadRequest.Destination = { filePath,response in
            let directory  = CBSessionConfig.shared.documentsDirectoryURL
            let fileURL =   directory.appendingPathComponent(response.suggestedFilename!)
            return (fileURL, [.removePreviousFile, .createIntermediateDirectories])
        }
        CBSession.shared.download(state, url: endpoint.url, method: method, headers: headers, to: destination).response { (downloadResponse) in
            switch downloadResponse.result{
            case .success(let url):
                completion(.success(url))
            case .failure(let error):
                completion(.failure(error))
            }
        }.downloadProgress(closure: downloadProgress).resume()
    }
    
    
}
fileprivate extension CBServer{
    //MARK:- decodableResponse
     func decodableResponse<T:Mappable>(dataResponse:AFDataResponse<Data>,completion:@escaping CBServerResponse<T>){
         //let statusCode  = dataResponse.response!.statusCode
         let result  = dataResponse.result
         
         switch result{
         case .success(let data):
             
             let jsR = data.JKDecoder(T.self)
             switch jsR {
             case .success(let v):
                 completion(.success(v))
             case .failure(let error):
                 print(String(describing: data.utf8String))
                 completion(.failure(error))
             }
             
         case .failure(let error):
             completion(.failure(error))
         }
         
     }
}
