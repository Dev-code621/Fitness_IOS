//
//  ResponseData.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/30/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

struct ResponseData: Mappable {
    
    var isSuccess       : Bool = false
    var errorCode       : Int = 0
    var message         : String = ""
    var messageCode     : Int = 4 //Using only for sign in APIs
    var objectData      : [String:Any]?
    var objectList      : [[String:Any]] = []
    
    // Mappable
    init?(map: Map) {
        //
    }
    
    mutating func mapping(map: Map) {
        isSuccess       <- map["isSuccess"]
        errorCode       <- map["errorCode"]
        message         <- map["message"]
        messageCode     <- map["message_code"]
        objectData      <- map["data"]
        objectList      <- map["data"]
    }
}
