//
//  VW_AppTutorialScreen.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit

class VW_AppTutorialScreen: UIView {
    
    let avPlayerViewController  = AVPlayerViewController()
    var playerView              : AVPlayer?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = .black
        
        playerView = AVPlayer()
        avPlayerViewController.player = playerView
        avPlayerViewController.showsPlaybackControls = false
        self.addSubview(avPlayerViewController.view)
        avPlayerViewController.view.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Data
    func setVideoData(newVideoData: VideoDataSource) {
        
        self.layoutIfNeeded()
        
        if let videoURL = URL(string:newVideoData.videoPlayUrl) {
            playerView = AVPlayer(url: videoURL)
            avPlayerViewController.player = playerView
            playerView?.volume = 0.5
        }
    }
}
