//
//  CollectionDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/9/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class CategoryDataSource: Mappable {
    
    var categoryTitle       : String = ""
    var categoryID          : Int = 0
    var categoryImage       : String = ""
    var listVideoRef        : Int = 0
    
    var collectionSlug      : String = ""
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        categoryTitle       <- map["category_title"]
        categoryID          <- map["category_id"]
        categoryImage       <- map["category_thumbnail"]
        listVideoRef        <- map["video_count"]
        collectionSlug      <- map["collection_slug"]
    }
}
