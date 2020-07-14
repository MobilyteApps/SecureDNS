//
//  IAPManager.swift
//  ADGAP
//
//  Created by Jitendra Kumar on 17/06/20.
//  Copyright © 2020 Jitendra Kumar. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit
typealias IAPVerifySubscriptionResult = VerifySubscriptionResult
typealias IAPVerifyReceiptURLType = AppleReceiptValidator.VerifyReceiptURLType
typealias IAPPurchaseResult = PurchaseResult
typealias IAPVerifyReceiptResult = VerifyReceiptResult
typealias IAPPurchaseDetails = PurchaseDetails
typealias IAPReceiptItem = ReceiptItem
typealias IAPFetchReceiptResult = FetchReceiptResult
typealias IAPReceiptError = ReceiptError
typealias IAPAppleReceiptValidator = AppleReceiptValidator
enum PurchaseQuery {
    case product(SKProduct)
    case productType(IAPProductType)
    
}


class IAPManager : NSObject{
    
    private var sharedSecret = "e2f331942df54882a4e925a2e2204c27"
    @objc static let shared = IAPManager()
    private(set) var products :[IAPProduct] = []
    var verifySubscriptionResult :IAPVerifySubscription?
    var verifyErrorCount:Int = 0
    private override init(){
        super.init()
    }
    
    
    //MARK:- getSKProducts
    func getProducts(_ productTypes: [IAPProductType],completion:@escaping()->Void){
        guard NetworkStatus.shared.isConnected else {return}
        NetworkStatus.shared.showHud()
        verifySubscriptionResult = nil
        
        self.retrieveProducts(productTypes) { result in
            async {
                NetworkStatus.shared.hideHud()
                switch result{
                case .success(let list):
                    self.products =  list.compactMap({IAPProduct(product: $0)})
                    completion()
                    
                case .failure(let error):
                    alertMessage = error.localizedDescription
                }
            }
        }
        
        
    }
    
    //MARK:- purchase
    func purchase(_ quey: PurchaseQuery, quantity: Int = 1, atomically: Bool = true,completion:@escaping(IAPPurchaseDetails)->Void) {
        guard NetworkStatus.shared.isConnected else {
            return
        }
        NetworkStatus.shared.showHud()
        
        self.purchaseQuery(quey,quantity: quantity, atomically: atomically) { result in
            async {
                NetworkStatus.shared.hideHud()
                
                switch result{
                case .success(let purchase):
                    
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    }
                    // Deliver content from server, then:
                    if purchase.needsFinishTransaction {
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }else{
                        completion(purchase)
                    }
                    
                case .error(let error):
                    alertMessage = error.errorMessage
                    
                }
                
            }
        }
    }
    
    
    //MARK:- verifyPurchase
    
    func verifyPurchase(_ isLoader:Bool = true, service:IAPVerifyReceiptURLType = .production, product: IAPProduct, purchaseDetails:IAPPurchaseDetails?,completion:@escaping(Bool)->Void) {
        guard NetworkStatus.shared.isConnected, let productType = product.productType else {return}
        if isLoader {
            NetworkStatus.shared.showHud()
        }
        
        verifyReceipt(service: service) { (result, receiptString) in
            async {
                NetworkStatus.shared.hideHud()
                switch result {
                case .success(let receipt):
                    self.verifyErrorCount = 0
                    let productId = productType.identifier
                    var recieptData:String = receiptString
                    let subscriptionType =  productType.subscriptionType
                    if recieptData.isEmpty {
                        if let str = SwiftyStoreKit.localReceiptData?.base64EncodedString(options: []), !str.isEmpty {
                            recieptData = str
                        }else{
                            if let str  = receipt["latest_receipt"] as? String, !str.isEmpty{
                                recieptData = str
                            }
                        }
                        
                    }
                    
                    let subscriptionResult = SwiftyStoreKit.verifySubscription(ofType:subscriptionType,productId: productId,inReceipt: receipt)
                    
                    self.verifySubscriptionResult = IAPVerifySubscription(subscriptionResult: subscriptionResult,pruchaseDetail: purchaseDetails,receiptString:recieptData, product: product)
                    
                    switch subscriptionResult {
                    case .purchased( let expiredDate,let receiptItem):
                        print("\(productId) is purchased: \(receiptItem) expiredDate \(expiredDate)")
                        completion(true)
                    case .notPurchased:
                        print("The user has never purchased \(productId)")
                        completion(false)
                    case .expired(let expiredDate,let receiptItem):
                        print("\(productId) is expired: \(receiptItem) expiredDate \(expiredDate)")
                        completion(false)
                        
                    }
                    
                    
                    
                    
                case .error(let error):
                    switch error {
                    case .noReceiptData,.noRemoteData,.jsonDecodeError,.networkError:
                        if self.verifyErrorCount<1 {
                            self.verifyErrorCount += 1
                            self.verifyPurchase(isLoader, service: service, product: product, purchaseDetails: purchaseDetails, completion: completion)
                        }else{
                            alertMessage = error.errorMessage
                        }
                    default:
                        alertMessage = error.errorMessage
                    }
                    
                }
            }
        }
    }
    
    //MARK:- setupIAP
    func setupIAP(atomically: Bool = true) {
        SwiftyStoreKit.completeTransactions(atomically: atomically) { purchases in
            
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                    
                case .purchased, .restored:
                    let downloads = purchase.transaction.downloads
                    if !downloads.isEmpty {
                        SwiftyStoreKit.start(downloads)
                    } else if purchase.needsFinishTransaction {
                        // Deliver content from server, then:
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                    print("\(purchase.transaction.transactionState.debugDescription): \(purchase.productId)")
                default:
                    // do nothing
                    //.failed, .purchasing, .deferred
                    break
                    
                }
            }
        }
        //shouldAddStorePaymentHandler()
        
    }
    //MARK:- updatedDownloadsHandler
    func updatedDownloadsHandler(){
        SwiftyStoreKit.updatedDownloadsHandler = { downloads in
            
            // contentURL is not nil if downloadState == .finished
            let contentURLs = downloads.compactMap { $0.contentURL }
            if contentURLs.count == downloads.count {
                print("Saving: \(contentURLs)")
                SwiftyStoreKit.finishTransaction(downloads[0].transaction)
            }
        }
    }
    //MARK:- shouldAddStorePaymentHandler
    func shouldAddStorePaymentHandler(){
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            return true
        }
    }
    
}


extension IAPManager{
    //MARK:- retrieveProducts
    fileprivate func retrieveProducts(_ productTypes: [IAPProductType],completion:@escaping(Result<[SKProduct],Error>)->Void){
        let productIds = Set(productTypes.compactMap({$0.identifier}))
        
        SwiftyStoreKit.retrieveProductsInfo(productIds) { result -> Void in
            async {
                NetworkStatus.shared.hideHud()
                if let error = result.error{
                    completion(.failure(error))
                }else{
                    var products = Array(result.retrievedProducts)
                    let invalidProductIDs = Array(result.invalidProductIDs)
                    if invalidProductIDs.count>0 {
                        invalidProductIDs.forEach({id in
                            if let indx = products.firstIndex(where: {$0.productIdentifier == id}){
                                products.remove(at: indx)
                            }
                        })
                        
                    }
                    
                    completion(.success(products))
                }
                
            }
            
        }
    }
    //MARK:- purchaseQuery
    fileprivate func purchaseQuery(_ query: PurchaseQuery,quantity: Int = 1, atomically: Bool = true, completion: @escaping (IAPPurchaseResult) -> Void){
        switch query {
        case .product( let skProdcut):
            SwiftyStoreKit.purchaseProduct(skProdcut, quantity: quantity, atomically: atomically, completion: completion)
        case .productType( let type):
            SwiftyStoreKit.purchaseProduct(type.identifier, quantity: quantity, atomically: atomically, completion: completion)
        }
        
    }
    
    //MARK:- verifyReceipt
    fileprivate func verifyReceipt(service:IAPVerifyReceiptURLType,completion: @escaping (IAPVerifyReceiptResult,_ receiptString:String) -> Void) {
        if let appStoreReceiptURL = Bundle.main.appStoreReceiptURL,
            FileManager.fileExists(atPath: appStoreReceiptURL.path) {
            do {
                let receiptData = try Data(contentsOf: appStoreReceiptURL, options: .alwaysMapped)
                let receiptString = receiptData.base64EncodedString(options: [])
                // Read receiptData
                print("receiptData =\(receiptData) \n receiptString = \(receiptString)")
                if receiptString.isEmpty {
                    
                    self.fetchReceipt(forceRefresh: true) { result in
                        switch result{
                        case .success(let receiptData):
                            let receiptString = receiptData.base64EncodedString(options: [])
                            print("receiptData =\(receiptData) \n receiptString = \(receiptString)")
                            
                            self.validate(receiptData: receiptData, completion: { result in
                                completion(result, receiptString)
                            })
                        case .error(let error):
                            async {
                                alertMessage = error.errorMessage
                            }
                        }
                    }
                }else{
                    
                    self.validate(receiptData: receiptData, completion: { result in
                        completion(result, receiptString)
                    })
                }
                
                
                
            }
            catch {
                print("Couldn't read receipt data with error: " + error.localizedDescription)
                completion(.error(error: ReceiptError.noReceiptData),"")
                
            }
        }else{
            
            self.fetchReceipt(forceRefresh: true) { result in
                switch result{
                case .success(let receiptData):
                    let receiptString = receiptData.base64EncodedString(options: [])
                    self.validate(receiptData: receiptData, completion: { result in
                        completion(result, receiptString)
                    })
                case .error(let error):
                    completion(.error(error: error), "")
                    
                }
            }
        }
    }
    //MARK:- fetchReceipt
    private func fetchReceipt(forceRefresh isforce:Bool,completion: @escaping (FetchReceiptResult) -> Void){
        SwiftyStoreKit.fetchReceipt(forceRefresh: isforce, completion: completion)
        
    }
    
    private func validate(receiptData:Data,completion: @escaping (VerifyReceiptResult) -> Void){
        let receiptString = receiptData.base64EncodedString(options: [])
        guard !receiptString.isEmpty else {
            completion(.error(error: .noReceiptData))
            return
        }
        let parameters = ["receiptData": receiptString]
        CBServer.shared.dataTask(endpoint: .subscription(.receiptVerify), method: .post, parameters:parameters, encoding: .JSON, headers: nil) { result in
            switch result{
            case .success(let data):
                
                // cannot decode data
                guard let receiptInfo = try? JSONSerialization.jsonObject(with: data, options:.mutableLeaves) as? ReceiptInfo ?? [:] else {
                    let jsonStr = String(data: data, encoding: String.Encoding.utf8)
                    completion(.error(error: .jsonDecodeError(string: jsonStr)))
                    return
                }
                
                // get status from info
                if let status = receiptInfo["status"] as? Int {
                    /*
                     * http://stackoverflow.com/questions/16187231/how-do-i-know-if-an-in-app-purchase-receipt-comes-from-the-sandbox
                     * How do I verify my receipt (iOS)?
                     * Always verify your receipt first with the production URL; proceed to verify
                     * with the sandbox URL if you receive a 21007 status code. Following this
                     * approach ensures that you do not have to switch between URLs while your
                     * application is being tested or reviewed in the sandbox or is live in the
                     * App Store.
                     
                     * Note: The 21007 status code indicates that this receipt is a sandbox receipt,
                     * but it was sent to the production service for verification.
                     */
                    let receiptStatus = ReceiptStatus(rawValue: status) ?? ReceiptStatus.unknown
                    if case .valid = receiptStatus {
                        completion(.success(receipt: receiptInfo))
                        
                    }else{
                        completion(.error(error: .receiptInvalid(receipt: receiptInfo, status: receiptStatus)))
                    }
                } else {
                    completion(.error(error: .receiptInvalid(receipt: receiptInfo, status: ReceiptStatus.none)))
                }
                
                
            case .failure(let error):
                completion(.error(error: .networkError(error: error)))
                
            }
        }
        
    }
}
extension IAPManager{
    var count:Int{
        return products.count
    }
    subscript(at index:Int)->IAPProduct?{
        return products[index]
    }
    func removeAll() {
        products.removeAll()
    }
}
extension SKError{
    var errorMessage:String{
        switch self.code {
        case .clientInvalid: // client is not allowed to issue the request, etc.
            return "Not allowed to make the payment"
        case .paymentCancelled:  // user cancelled the request, etc.
            return "user cancelled the request"
        case .paymentInvalid: // purchase identifier was invalid, etc.
            return "The purchase identifier was invalid"
        case .paymentNotAllowed: // this device is not allowed to make the payment
            return "The device is not allowed to make the payment"
        case .storeProductNotAvailable: // Product is not available in the current storefront
            return "The product is not available in the current storefront"
        case .cloudServicePermissionDenied: // user has not allowed access to cloud service information
            return "Access to cloud service information is not allowed"
        case .cloudServiceNetworkConnectionFailed: // the device could not connect to the nework
            return "Could not connect to the network"
        case .cloudServiceRevoked: // user has revoked permission to use this cloud service
            return "Cloud service was revoked"
        default:
            return self.localizedDescription
        }
    }
}
extension IAPReceiptError{
    var errorMessage:String{
        switch self {
        case .noReceiptData:
            return "No receipt data"
        case .networkError(let error):
            return "Network error while verifying receipt:\n \(error.localizedDescription)"
        case .requestBodyEncodeError(let error):
            return "Receipt verification failed:\n \(error.localizedDescription)"
        case .jsonDecodeError(let string):
            print(String(describing: string))
            return "Receipt verification failed:\n The data couldn't be read becuase isn't in the correct formate."//string ?? ""
        case .noRemoteData:
            return "No receipt data avialble"
        case .receiptInvalid(let receipt, let status):
            print("\(receipt.description) = \(status.rawValue)")
            return "Receipt verification failed:\n \(status.rawValue)"
            //default:
            //return "Receipt verification failed: \(self.localizedDescription)"
        }
    }
}
