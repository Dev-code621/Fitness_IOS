//
//  UserMobilityDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/6/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class UserMobilityDataSource: Mappable {
    
    var shoulderPointAVG        : Double = 0.0
    var trunkPointAVG           : Double = 0.0
    var hipPointAVG             : Double = 0.0
    var anklePointAVG           : Double = 0.0
    var testDate                : Int    = 0
    var on_process              : Bool   = false
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        shoulderPointAVG        <- map["shoulder_point_avg"]
        trunkPointAVG           <- map["trunk_point_avg"]
        hipPointAVG             <- map["hip_point_avg"]
        anklePointAVG           <- map["ankle_point_avg"]
        testDate                <- map["test_date"]
        on_process              <- map["on_process"]
    }
}
