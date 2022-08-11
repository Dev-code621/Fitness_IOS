//
//  UserNotificationDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/17/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

enum NotificationType: String {
    case newVideo = "new_video"
    case newArchiverment = "new_archiverment"
}

class UserNotificationDataSource: Mappable {
    
    var notificationId      : Int = 0
    var notificationType    : NotificationType = .newVideo
    var notificationName    : String! = ""
    var notificationDecs    : String = ""
    var notificaiotnDate    : Int = 0
    var notificationIsRead  : Bool = false
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        notificationId      <- map["notification_id"]
        notificationType    <- map["notification_type"]
        notificationName    <- map["notification_name"]
        notificationDecs    <- map["notification_description"]
        notificaiotnDate    <- map["notification_date"]
        notificationIsRead  <- map["notification_is_readed"]
        
    }
}
