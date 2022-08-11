//
//  CC_RelatedVideosCell.swift
//  NewTRS
//
//  Created by yaya on 9/14/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_PreWorkoutCell: UITableViewCell, VideoCellDelegate {
    
    let preVideoCell        = VW_RetangleVideoViewCellTagging()
    var delegate            : VideoCellDelegate?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(preVideoCell)
        preVideoCell.delegate = self
        preVideoCell.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setData(videoData: VideoDataSource) {
        self.preVideoCell.setVideoDataSource(newVideoData: videoData)
        self.preVideoCell.showPrePostLabel(isHidden: false)
        self.preVideoCell.showDownloadOption(isHidden: true)
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        if delegate != nil {
            delegate?.didSelectVideo(videoData: videoData)
        }
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        //
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
    }
}
