//
//  PagingDataSource.swift
//  NewTRS
//
//  Created by yaya on 8/19/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import Foundation
import ObjectMapper

class PagingDataSource: Mappable {
    
    var totalVideo       : Int = 0
    var maxPage          : Int = 0
    var currentPage        : Int = 0
    var limitVideo       : Int = 0
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        totalVideo           <- map["total"]
        maxPage              <- map["max_page"]
        currentPage          <- map["page"]
        limitVideo           <- map["limit"]
    }
}
