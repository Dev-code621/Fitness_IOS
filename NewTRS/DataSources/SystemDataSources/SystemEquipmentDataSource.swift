//
//  SystemEquipmentDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/30/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

struct SystemEquipmentDataSource: Mappable, Equatable {
    
    var equipmentTitle     : String = ""
    var equipmentId        : Int = 0
    
    // Mappable
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        equipmentTitle     <- map["equipment_title"]
        equipmentId        <- map["equipment_id"]
    }
}
