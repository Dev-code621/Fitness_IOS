//
//  ProductSubscriptionData.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/3/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class ProductSubscriptionData: Mappable {
    
    var title           : String! = ""
    var billingPeriod   : String! = ""
    var subscriptionId  : String! = ""
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        title           <- map["title"]
        billingPeriod   <- map["billing_period"]
        subscriptionId  <- map["subscription_id"]
    }
}
