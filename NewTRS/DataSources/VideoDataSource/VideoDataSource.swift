//
//  VideoDataSource.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/3/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

enum PrePostTag : Int {
    case none = 0
    case preOnly = 1
    case postOnly = 2
    case both = 3
}

protocol VideoCellDelegate {
    func didSelectVideo(videoData: VideoDataSource)
    func didSelectDownloadVideo(videoData: VideoDataSource)
    func didDeleteVideo(videoData: VideoDataSource)
}

class VideoDataSource: Mappable, Equatable {
    
    var videoID                 : Int = 0
    var imageThumnailStr        : String! = ""
    var videoTitle              : String! = ""
    var videoDescription        : String! = ""
    var requiredEquipmentIDs    : [Int] = []
    var areasIDs                : [Int] = []
    var coachTips               : [String] = []
    var videoPlayUrl            : String! = ""
    var videoDownloadUrl        : String! = ""
    var viewCount               : Int = 0
    var videoDuration           : Int = 0       // seconds
    var isFavorite              : Bool = false
    var isPrePostTag            : PrePostTag = .none
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        videoID                 <- map["video_id"]
        imageThumnailStr        <- map["image_thumbnail"]
        videoTitle              <- map["video_title"]
        videoDescription        <- map["video_description"]
        requiredEquipmentIDs    <- map["required_equipment_ids"]
        areasIDs                <- map["area_ids"]
        coachTips               <- map["coach_tips"]
        videoPlayUrl            <- map["video_play_url"]
        videoDownloadUrl        <- map["video_download_url"]
        viewCount               <- map["view_count"]
        videoDuration           <- map["video_duration"]
        isFavorite              <- map["video_is_favorite"]
        isPrePostTag            <- map["pre_post_type"]
    }
    
    static func == (lhs: VideoDataSource, rhs: VideoDataSource)  -> Bool{
        return lhs.videoID == rhs.videoID
    }
}
