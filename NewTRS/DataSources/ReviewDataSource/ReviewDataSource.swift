//
//  ReviewDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class ReviewDataSource: Mappable {
    
    var reviewerAvatar  : String = ""
    var reviewerName    : String = ""
    var reviewContent   : String = ""
    var reviewdateSince : Int = 2010
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        reviewerAvatar      <- map["reviewer_avatar"]
        reviewerName        <- map["reviewer_name"]
        reviewContent       <- map["review_content"]
        reviewdateSince           <- map["reviewer_member_since"]
    }    
}
