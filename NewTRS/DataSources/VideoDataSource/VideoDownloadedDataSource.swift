//
//  VideoDownloadedDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/30/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class VideoDownloadedDataSource: Mappable, Equatable {
    
    var videoID             : Int = 0
    var videoTitle          : String = ""
    
    var videoDownloadLink   : String! = ""
    var imageDownloadLink   : String! = ""
    var videoExprired       : Int = 0
    
    var savedDate           : Int = 0
//    var savedVideoLink      : String?
//    var savedThumbnailLink  : String?
    var videoDownloadPercent = 0.0
    var task                 : URLSessionDownloadTask?
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        videoID             <- map["video_id"]
        videoTitle          <- map["video_title"]
        
        videoDownloadLink   <- map["download_url"]
        imageDownloadLink   <- map["image_thumbnail"]
        videoExprired       <- map["exprired_time"]
        
        savedDate           <- map["saved_date"]
        videoDownloadPercent    <- map["download_percent"]
//        savedVideoLink      <- map["saved_video_link"]
//        savedThumbnailLink  <- map["saved_thumbnail_link"]
    }
    
    static func == (lhs: VideoDownloadedDataSource, rhs: VideoDownloadedDataSource) -> Bool {
        return lhs.videoID == rhs.videoID
    }
    
    func getSavedVideoURL() -> URL {
        var videoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        videoURL = videoURL.appendingPathComponent(String(format: "Downloaded/%ld.mp4", self.videoID))
        return videoURL
    }
    
    func getSavedImageURL() -> URL {
        var videoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        videoURL = videoURL.appendingPathComponent(String(format: "Downloaded/%ld.png", self.videoID))
        return videoURL
    }
    
}
