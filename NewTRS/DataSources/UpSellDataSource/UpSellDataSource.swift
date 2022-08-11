//
//  UpSellDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class UpSellDataSource: Mappable {
    
    var upsellId                : Int = 0
    var imageThumbnailStr       : String = ""
    var productTitle            : String = ""
    var productReferenceUrlStr  : String = ""
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        upsellId                <- map["upsell_id"]
        imageThumbnailStr       <- map["image_thumbnail"]
        productTitle            <- map["product_title"]
        productReferenceUrlStr  <- map["product_reference_url"]
    }
}
