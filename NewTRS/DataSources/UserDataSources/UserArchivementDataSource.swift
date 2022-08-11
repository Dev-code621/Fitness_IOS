//
//  UserArchivementDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/18/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class UserArchivementDataSource: Mappable, Codable {
    
    var achievementId               : Int = 0
    var achievementTitle            : String = ""
    var achievementDescription      : String = ""
    var achievementMilestone        : Int = 0
    var achievementActiveImage      : String = ""
    var achievementInactiveImage    : String = ""
    var achievementIsActive         : Bool = false
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        achievementId               <- map["achievement_id"]
        achievementTitle            <- map["achievement_title"]
        achievementDescription      <- map["achievement_description"]
        achievementMilestone        <- map["achievement_milestone"]
        achievementActiveImage      <- map["achievement_active_image"]
        achievementInactiveImage    <- map["achievement_inactive_image"]
        achievementIsActive         <- map["achievement_is_active"]
    }
}
