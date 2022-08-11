//
//  UserProfileDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/1/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

enum UserPlanPlatform : Int {
    case free = 0
    case iOS = 1
    case android = 2
    case web = 3
}

enum CancelStatus : Int {
    case onAutoRenew = 0
    case canceled   = 1
}

enum DidMakePayment : Int {
    case doNotPayment   = 0
    case didMakePayment = 1
}

class UserProfileDataSource: NSObject, Mappable {
    
    var userAvatar          : String! = ""
    var firstName           : String! = ""
    var lastName            : String! = ""
    var dob                 : Int = 0
    var userPlan            : String! = "Freemium"
    var userPlanRegisterDate: Int = 0
    var userPlanExpriedDate : Int = 0
    var userPlanPlatform    : UserPlanPlatform = .free
    var userSettings        = UserProfileSettings.init(JSONString: "{}")!
    var userProfileRank     = UserProfileRank.init(JSONString: "{}")!
    var cancelPlanLink      : String = ""
    var cancelStatus        : CancelStatus = .onAutoRenew
    var userDidMakePayment  : DidMakePayment = .doNotPayment
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        userAvatar              <- map["user_avatar"]
        firstName               <- map["first_name"]
        lastName                <- map["last_name"]
        dob                     <- map["dob"]
        userPlan                <- map["user_plan"]
        userPlanRegisterDate    <- map["plan_register_date"]
        userPlanExpriedDate     <- map["plan_expire_date"]
        userSettings            <- map["user_settings"]
        userProfileRank         <- map["user_rank"]
        userPlanPlatform        <- map["plan_platform"]
        cancelPlanLink          <- map["cancel_subscription_link"]
        cancelStatus            <- map["pending_cancel"]
        userDidMakePayment      <- map["user_did_make_payment"]
    }
    
    func isFreemiumUser() -> Bool {
        if (self.userPlan == "Freemium") || (self.userPlan == "") {
            return true
        } else if (self.userPlan == "TRS Comp") || (self.userPlan == "VMC") {
            return false
        }
        return (self.userPlanExpriedDate <= (Int(Date().timeIntervalSince1970)) - 259200)
    }
}

class UserProfileSettings: NSObject, Mappable {
    
    var myEquipments    : [SystemEquipmentDataSource] = []
    var myFocusAreas    : [SystemFocusAreaDataSource] = []
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        myEquipments        <- map["my_equipments"]
        myFocusAreas        <- map["my_focus_areas"]
    }
}

class UserProfileRank: Mappable, Equatable {
    
    var userRankIndex   : Int = 0
    var userAvatar      : String = ""
    var userName        : String! = ""
    var userPoint       : String = ""
    var userBadge       : String = ""
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        userRankIndex       <- map["user_rank_index"]
        userAvatar          <- map["user_avatar"]
        userName            <- map["username"]
        userPoint           <- map["user_point"]
        userBadge           <- map["user_badge"]
    }
    
    static func == (lhs: UserProfileRank, rhs: UserProfileRank) -> Bool {
        
        if lhs.userRankIndex == rhs.userRankIndex &&
            lhs.userAvatar    == rhs.userAvatar &&
            lhs.userName      == rhs.userName &&
            lhs.userPoint     == rhs.userPoint &&
            lhs.userBadge     == rhs.userBadge {
            return true
        }
        return false
    }
}
