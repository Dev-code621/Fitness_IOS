//
//  CC_SquareVideoCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/15/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class CC_SquareVideoCell: UICollectionViewCell {

    var delegate            : VideoCellDelegate?
    var dataSource          : VideoDataSource?
    
    let thumbnailImage      = UIImageView()
    let videoTitleLabel     = UILabel()
    //let videoViewLabel      = UILabel()
    let videoDurationLabel  = UILabel()
    
    let deleteBtn           = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        thumbnailImage.image = UIImage.init(named: "default_thumbnail_image")
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.masksToBounds = true
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }
        
        videoTitleLabel.text = "Example video title"
        videoTitleLabel.font = setFontSize(size: 14, weight: .semibold)
        videoTitleLabel.textColor = UIColor.init(hexString: "666666")
        self.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(thumbnailImage.snp.bottom).offset(10)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(16)
        }
        
//        self.addSubview(videoViewLabel)
//        videoViewLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview()
//            make.top.equalTo(videoTitleLabel.snp.bottom).offset(1)
//        }
        
//        let spaceView = UIView()
//        spaceView.backgroundColor = UIColor.init(hexString: "888888")
//        spaceView.layer.cornerRadius = 2
//        self.addSubview(spaceView)
//        spaceView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(videoViewLabel)
//            make.left.equalTo(videoViewLabel.snp.right).offset(6)
//            make.width.height.equalTo(4)
//        }
        
        self.addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(1)
        }
        
        deleteBtn.isHidden = true
        deleteBtn.setBackgroundImage(UIImage.init(named: "close_btn"), for: .normal)
        deleteBtn.layer.cornerRadius = 12
        deleteBtn.backgroundColor = UIColor.init(hexString: "b31d00ff")
        deleteBtn.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
        self.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.width.equalTo(24)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func deleteButtonTapped() {
        if delegate != nil && self.dataSource != nil {
            delegate?.didDeleteVideo(videoData: self.dataSource!)
        }
    }
    
    //MARK: - Data
    func updateVideoData(videoData: VideoDataSource) {
        self.dataSource = videoData
        self.videoTitleLabel.text = videoData.videoTitle
        
        if let thumbnailURL = URL(string: videoData.imageThumnailStr) {
            self.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
//        var viewCountStr: String = "views"
//        if videoData.viewCount == 1 { viewCountStr = "view" }
//        let numberStr = String(format: "%ld", videoData.viewCount)
//        let viewAttributedStr = NSMutableAttributedString(string: String(format: "%ld \(viewCountStr)", videoData.viewCount))
//        viewAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
//                                        value: UIColor.init(hexString: "888888")!,
//                                          range: NSMakeRange(0, viewAttributedStr.length))
//        viewAttributedStr.addAttribute(NSAttributedString.Key.font,
//                                        value: setFontSize(size: 11, weight: .regular),
//                                        range: NSMakeRange(0, viewAttributedStr.length))
//        viewAttributedStr.addAttribute(NSAttributedString.Key.font,
//                                          value:setFontSize(size: 11, weight: .semibold),
//                                          range: NSMakeRange(0, numberStr.count))
        //videoViewLabel.attributedText = viewAttributedStr
        
        let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: videoData.videoDuration,
                                                                          color: UIColor.init(hexString: "888888")!,
                                                                          fontActive: setFontSize(size: 11, weight: .semibold),
                                                                          fontInactive: setFontSize(size: 11, weight: .regular))
        videoDurationLabel.attributedText = durationAttributedStr
    }
}
