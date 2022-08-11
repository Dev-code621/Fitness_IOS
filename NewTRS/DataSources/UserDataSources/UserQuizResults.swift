//
//  UserQuizResults.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/6/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class UserQuizResults: Mappable {
    
    var gender                  : Int = -1
    var activityLevel           : Int = -1
    var experienceMobilizing    : Int = -1
    var reasonToJoin            : Int = -1
    var myEquipmentIds          : [String] = []
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        gender                  <- map["gender"]
        activityLevel           <- map["activity_level"]
        experienceMobilizing    <- map["experience_mobilizing"]
        reasonToJoin            <- map["reason_to_join"]
        myEquipmentIds          <- map["my_equipment_ids"]
    }
}
