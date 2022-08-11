//
//  SystemAreaDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/30/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

struct SystemFocusAreaDataSource: Mappable {
    
    var areaTitle       : String = ""
    var areaId          : Int = 0
    
    // Mappable
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        areaTitle       <- map["area_title"]
        areaId          <- map["area_id"]
    }
}
