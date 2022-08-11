//
//  SystemBonusDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/16/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class SystemBonusDataSource: Mappable {
    var bonusTitle      : String = ""
    var bonusId         : Int = 0
    var bonusImage      : String = ""
    
    // Mappable
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        bonusTitle      <- map["bonus_title"]
        bonusId         <- map["bonus_id"]
        bonusImage      <- map["bonus_image"]
    }
}
