//
//  UserAccessDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/13/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class UserTRSToken: NSObject, Mappable, NSCoding {
    
    var userID          : Int = 0
    var refreshToken    : String! = ""
    var accessToken     : String! = ""
    var expirationTime  : Int     = 0
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        userID              <- map["userID"]
        refreshToken        <- map["refresh_token"]
        accessToken         <- map["jwt"]
        expirationTime      <- map["expire_date"]
    }
    
    required init(coder aDecoder: NSCoder) {
        self.userID = aDecoder.decodeInteger(forKey: "userID")
        self.refreshToken = aDecoder.decodeObject(forKey: "refresh_token") as? String ?? ""
        self.accessToken = aDecoder.decodeObject(forKey: "jwt") as? String ?? ""
        self.expirationTime = aDecoder.decodeInteger(forKey: "expire_date")
    }
    
    func encode(with aCoder: NSCoder) {
        
        aCoder.encode(self.userID, forKey: "userID")
        
        if let refreshToken = self.refreshToken {
            aCoder.encode(refreshToken, forKey: "refresh_token")
        }
        
        if let accessToken = self.accessToken {
            aCoder.encode(accessToken, forKey: "jwt")
        }
        
        aCoder.encode(self.expirationTime, forKey: "expire_date")
    }
}
