//
//  SystemPainAreaDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/30/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

struct SystemPainAreaDataSource: Mappable {
    
    var painAreaTitle       : String = ""
    var painAreaKey         : String! = ""
    var painAreaId          : Int = 0
    
    // Mappable
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        painAreaTitle       <- map["pain_area_title"]
        painAreaKey         <- map["pain_area_key"]
        painAreaId          <- map["pain_area_id"]
    }
}
