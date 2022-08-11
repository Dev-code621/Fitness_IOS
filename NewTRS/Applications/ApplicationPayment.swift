//
//  ApplicationPayment.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import SwiftyStoreKit
import StoreKit

enum UserVerifyStatus : Int {
    case brandNewUser       = 0     // User has no transaction, and current Apple ID is brand new
    case brandNewAppleID    = 1     // User has some transaction, but current Apple ID is brand new
    case userReactive       = 2     // User has only one transaction, that accociate with current Apple ID
    case myUserInclude      = 3     // User has some transaction, that include current Apple ID
    case notMyuser          = 4     // User has some transaction, but not include current Apple ID
}

class ApplicationPayment: NSObject {
    
    static let shared               = ApplicationPayment()
    
    private let appSpecificKey      = "027ca3ef52e34b4ba3abc96c1d8c2a6f"
    private var receiptDataSource   : ReceiptDataSource?
    private var lastestReceiptStr   = ""
    var listProduct                 : [ProductSubscriptionData] = []
    
    //MARK: - Init functions
    func configPayment() {
        
        // Complete pending transactions and validate receipt
        self.completeTransaction()
        self.verifyReceipt()
        
        _AppDataHandler.getListProduct { (isSuccess, error, listProducts) in
            if isSuccess {
                self.listProduct = listProducts
            } else {
                bfprint(String(format:"IAP - SwiftyStoreKit.notGetListProduct: %@", error), tag: "IAP", level: .default)
            }
        }
    }
    
    //MARK: - Private functions
    private func handeAppStorePayment() {
        SwiftyStoreKit.shouldAddStorePaymentHandler = { payment, product in
            // return true if the content can be delivered by your app
            // return false otherwise
            return false
        }
    }
    
    private func completeTransaction() {
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.completeTransactions"), tag: "IAP", level: .default)

        SwiftyStoreKit.completeTransactions(atomically: true) { purchases in
            for purchase in purchases {
                switch purchase.transaction.transactionState {
                case .purchased, .restored:
                    if purchase.needsFinishTransaction {
                        
                        // Deliver content from server, then:
                        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.needsFinishTransaction"), tag: "IAP", level: .default)
                        SwiftyStoreKit.finishTransaction(purchase.transaction)
                    }
                // Unlock content
                case .failed, .purchasing, .deferred:
                break // do nothing
                @unknown default:
                    break
                }
            }
        }
    }
    
    //MARK: - Verify Purchases
    
    // This function get lastest receipt and saved as local. Using this to verify the user state
    private func verifyReceipt() {
        var service  : AppleReceiptValidator.VerifyReceiptURLType = .sandbox
        
        if kIsProductionReleaseMode {
            service = .production
        }
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.verifyReceipt"), tag: "IAP", level: .default)
        
        let appleValidator = AppleReceiptValidator(service: service, sharedSecret: appSpecificKey)
        SwiftyStoreKit.verifyReceipt(using: appleValidator, forceRefresh: false) { result in
            switch result {
            case .success(let receiptInfo):
                
                if !self.listProduct.isEmpty {
                    for product in self.listProduct {
                        if let productId = product.subscriptionId {
                            let purchaseResult = SwiftyStoreKit.verifySubscription(
                                ofType: .autoRenewable, // or .nonRenewing (see below)
                                productId: productId,
                                inReceipt: receiptInfo)
                            
                            switch purchaseResult {
                            case .purchased(let expiryDate, let items):
                                bfprint(String(format:"IAP.verifyReceipt: %@", "\(productId) is valid until \(expiryDate)\n\(items)\n"), tag: "IAP", level: .default)
                                if let receiptDict = receiptInfo["receipt"] as? [String:Any] {
                                    self.receiptDataSource = ReceiptDataSource.init(JSON: receiptDict)
                                    _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 80: verifyReceipt success", log: receiptDict)
                                }
                                break
                            case .expired(let expiryDate, let items):
                                bfprint(String(format:"IAP.verifyReceipt: %@", "\(productId) is expired since \(expiryDate)\n\(items)\n"), tag: "IAP", level: .default)
                                break
                            case .notPurchased:
                                bfprint(String(format:"IAP.verifyReceipt: %@", "The user has never purchased \(productId)"), tag: "IAP", level: .default)
                                break
                            }
                        }
                    }
                }
            case .error(let error):
                print("Verify receipt failed: \(error)")
                _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 80: verifyReceipt fail", log: error)
            }
        }
    }
    
    // Verify user : This function to get status from BE user, to make sure warning user in correct case
    func updateUserTransaction(completion:@escaping (UserVerifyStatus)-> ()) {
        
        _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 94: ", log: "updateUserTransaction")
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.updateUserTransaction"), tag: "IAP", level: .default)

        _AppDataHandler.getUserTransaction { (listTransaction) in
            
            _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 98: ", log: listTransaction)
            bfprint(String(format:"IAP: %@", listTransaction), tag: "IAP", level: .default)

            guard let receiptData = self.receiptDataSource else {
                if listTransaction.count == 0 {
                    //Case 0: User has no transaction, and current Apple ID is brand new
                    completion(.brandNewUser)
                } else {
                    //Case 2: User has some transaction, but current Apple ID is brand new
                    completion(.brandNewAppleID)
                }
                return
            }
            
            if receiptData.inAppPurchase.count == 0 {
                if listTransaction.count == 0 {
                    //Case 0: User has no transaction, and current Apple ID is brand new
                    completion(.brandNewUser)
                } else {
                    //Case 2: User has some transaction, but current Apple ID is brand new
                    completion(.brandNewAppleID)
                }
                return
            }
            
            if let receiptOriginalTransactionId = receiptData.inAppPurchase.first?.originalTransactionId {
                
                if listTransaction.count == 1 {
                    if listTransaction.first == receiptOriginalTransactionId {
                        //Case 3: User has only one transaction, that accociate with current Apple ID
                        completion(.userReactive)
                        return
                    }
                }

                for transaction in listTransaction {
                    if transaction == receiptOriginalTransactionId {
                        //Case 4: User has some transaction, that include current Apple ID
                        completion(.myUserInclude)
                        return
                    }
                }
            }
            
            completion(.notMyuser)
        }
    }
    
    // Get user lastest Receipt
    func getUserReceipt (completion:@escaping (Bool, String, String)-> ()) {
        
        _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 145: getUserReceipt", log: "")
        
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.fetchReceipt"), tag: "IAP", level: .default)
        
        SwiftyStoreKit.fetchReceipt(forceRefresh: true) { result in
            switch result {
            case .success(let receiptData):
                self.lastestReceiptStr = receiptData.base64EncodedString(options: [])
                completion(true,"", self.lastestReceiptStr)
                _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 153: getUserReceipt", log: self.lastestReceiptStr)
                print("Fetch receipt success:\n\(self.lastestReceiptStr)")
                bfprint(String(format:"IAP fetchReceipt Success: %@", self.lastestReceiptStr), tag: "IAP", level: .default)
            case .error(let error):
                print("Fetch receipt failed: \(error)")
                completion(false, "The operation couldn't be completed.","")
                bfprint(String(format:"IAP fetchReceipt Error: %@", "\(error)"), tag: "IAP", level: .default)
            }
        }
    }
    
}
extension ApplicationPayment {
    
    
    // Request AppStore Connect to get product informations
    func getProductData(product: ProductSubscriptionData,
                        completion:@escaping (Bool, String, SKProduct?)-> ()) {
        
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.retrieveProductsInfo"), tag: "IAP", level: .default)

        SwiftyStoreKit.retrieveProductsInfo([product.subscriptionId]) { result in
            
            if let product = result.retrievedProducts.first {
                
                completion(true, "", product)
            }
            else if let invalidProductId = result.invalidProductIDs.first {
                print("Invalid product identifier: \(invalidProductId)")
                completion(false, "Invalid product identifier: \(invalidProductId)", nil)
            }
            else {
                print("Error: \(result.error?.localizedDescription ?? "")")
                completion(false, result.error?.localizedDescription ?? "", nil)
            }
        }
    }
    
    // Purchase product
    func purchaseProduct(product: SKProduct,
                         completion:@escaping (Bool, String)-> ()) {
        
        guard let userData = _AppDataHandler.getSessionDataSource() else {
            completion(false, "User not authorized")
            return
        }
        
        _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 185: purchaseProduct", log: "")
        
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.purchaseProduct"), tag: "IAP", level: .default)

        SwiftyStoreKit.purchaseProduct(product,
                                       quantity: 1,
                                       atomically: true,
                                       applicationUsername: String(userData.userID)) { result in
            switch(result) {
            case .success(_):
                
                _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 191: purchaseProduct success", log: result)
                bfprint(String(format:"IAP: %@", "SwiftyStoreKit.purchaseProduct - success "), tag: "IAP", level: .default)
                
                _AppPaymentManager.getUserReceipt() { (isSuccess, error, newUserReceipt) in
                    _AppDataHandler.uploadReceipt(receiptStr:newUserReceipt ) { (isSuccess, error) in
                        if isSuccess {
                            print("Upload Transaction ID: Success!")
                            self.completeTransaction()
                            _AppDataHandler.reloadUserProfile()
                            completion(true, "")
                            
                            return
                        } else {
                            completion(false, error)
                        }
                    }
                }
                break
            case .error(let error):
                bfprint(String(format:"IAP: %@ - %@", "SwiftyStoreKit.purchaseProduct - error", error.localizedDescription), tag: "IAP", level: .default)
                completion(false, error.localizedDescription)
                break
            }
        }
    }
    
    // Restore old purchase if need
    private func restorePurchased(completion:@escaping (Bool)-> ()) {
        guard let userData = _AppDataHandler.getSessionDataSource() else {
            completion(false)
            return
        }
        
        bfprint(String(format:"IAP: %@", "SwiftyStoreKit.restorePurchases"), tag: "IAP", level: .default)

        SwiftyStoreKit.restorePurchases(atomically: true,
                                        applicationUsername: String(userData.userID)) { (results) in
            for product in results.restoredPurchases {
                
                if product.needsFinishTransaction {
                    bfprint(String(format:"IAP: %@", "SwiftyStoreKit.finishTransaction"), tag: "IAP", level: .default)

                    SwiftyStoreKit.finishTransaction(product.transaction)
                }
            }
            if results.restoredPurchases.count > 0 {
                bfprint(String(format:"IAP: %@", "restoredPurchases > 0"), tag: "IAP", level: .default)
                completion(true)
            } else {
                bfprint(String(format:"IAP: %@", "restoredPurchases = 0"), tag: "IAP", level: .default)
                completion(false)
            }
        }
    }
    
    func restorePurchaseAction(completion:@escaping (Bool, String)-> ()) {
        
        _AppDataHandler.sendLog(apiName: "DEBUG point ApplicationPayment - 217: checkAndResendReceipt", log: "")
        bfprint(String(format:"IAP: %@", "checkAndResendReceipt"), tag: "IAP", level: .default)

        self.restorePurchased { (isSuccess) in
            if isSuccess {
                // get new receipt
                bfprint(String(format:"IAP: %@", "checkAndResendReceipt-Success"), tag: "IAP", level: .default)

                self.getUserReceipt() { (isSuccess, error, newReceipt) in
                    if isSuccess {
                        _AppDataHandler.uploadReceipt(receiptStr: newReceipt)
                        { (isSuccess, error) in
                            bfprint(String(format:"IAP-uploadReceipt: %@", newReceipt), tag: "IAP", level: .default)
                            completion(isSuccess, error)
                        }
                    } else {
                        bfprint(String(format:"IAP-uploadReceiptError: %@", error), tag: "IAP", level: .default)
                        completion(false, error)
                    }
                }
            } else {
                bfprint(String(format:"IAP-uploadReceiptNotSuccess: %@", NSLocalizedString("kPaymentsAwaitingMessage", comment: "")), tag: "IAP", level: .default)
                completion(false, NSLocalizedString("kPaymentsAwaitingMessage", comment: ""))
            }
        }
    }
}
