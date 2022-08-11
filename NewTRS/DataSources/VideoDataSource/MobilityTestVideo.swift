//
//  MobilityTestVideo.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/14/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import ObjectMapper

class MobilityTestVideo: Mappable, Equatable {
    
    var videoID             : Int = 0
    var thumbnailImage      : String! = ""
    var videoTitle          : String! = ""
    var videoURLString      : String! = ""
    var videoDuration       : Int = 0
    var videoInstruction    : [String] = []
    var videoCompensations  : [String] = []
    var poseImages          : MobilityPoseDataSource = MobilityPoseDataSource.init(JSONString: "{}")!
    var selectedResult      : Int = 0   //defaule = 0, it mean do not make answer
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        videoID                 <- map["video_id"]
        thumbnailImage          <- map["image_thumbnail"]
        videoTitle              <- map["video_title"]
        videoURLString          <- map["video_play_url"]
        videoDuration           <- map["video_duration"]
        videoInstruction        <- map["video_instruction"]
        videoCompensations      <- map["video_compensations"]
        poseImages              <- map["pose_image"]
    }
    
    static func == (lhs: MobilityTestVideo, rhs: MobilityTestVideo) -> Bool {
        return (lhs.videoID == rhs.videoID) && (lhs.videoTitle == rhs.videoTitle)
    }
}

class MobilityPoseDataSource: Mappable {
    
    var greenPose           : String! = ""
    var yellowPose          : String! = ""
    var redPose             : String! = ""
    var greenText           : String! = ""
    var yellowText          : String! = ""
    var redText             : String! = ""
    
    required init?(map: Map) {
        //
    }
    
    func mapping(map: Map) {
        greenPose           <- map["green_pose"]
        yellowPose          <- map["yellow_pose"]
        redPose             <- map["red_pose"]
        greenText               <- map["green_text"]
        yellowText              <- map["yellow_text"]
        redText                 <- map["red_text"]
    }
}
