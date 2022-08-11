//
//  ReceiptDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

struct ReceiptDataSource: Mappable {
    
    var receiptType         : String! = ""
    var inAppPurchase       : [InAppPurchaseData] = []
    var pendingRenewalInfo  = RenewalInfoDataSource.init(JSONString: "{}")!
    
    // Mappable
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        receiptType         <- map["receipt_type"]
        inAppPurchase       <- map["in_app"]
        pendingRenewalInfo  <- map["pending_renewal_info"]
    }
}

struct InAppPurchaseData : Mappable {
    
    var productId               : String! = ""
    var transactionID           : String! = ""
    var originalTransactionId   : String! = ""
    
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        productId               <- map["product_id"]
        transactionID           <- map["transaction_id"]
        originalTransactionId   <- map["original_transaction_id"]
    }
}

struct RenewalInfoDataSource : Mappable {
    
    var autoRenewProductID      : String! = ""
    var originalTransactionId   : String! = ""
    
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        autoRenewProductID      <- map["auto_renew_product_id"]
        originalTransactionId   <- map["original_transaction_id"]
    }
}
