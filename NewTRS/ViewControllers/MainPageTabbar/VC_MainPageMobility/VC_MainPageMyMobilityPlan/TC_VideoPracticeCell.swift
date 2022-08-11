//
//  TC_VideoPracticeCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_VideoPracticeCell: UITableViewCell {
    
    let videoThumbnailImage     = UIImageView()
    let videoTitleLabel         = UILabel()
    //let videoViewCountLabel     = UILabel()
    let videoDurationLabel      = UILabel()
    
    private let prePostView     = UIView()
    private let prePostLabel    = UILabel()
    private let playingView     = UIView()
    private let topView         = UIView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layer.masksToBounds = true
        
        videoThumbnailImage.image = UIImage.init(named: "default_thumbnail_image")
        videoThumbnailImage.contentMode = .scaleAspectFill
        videoThumbnailImage.layer.masksToBounds = true
        self.addSubview(videoThumbnailImage)
        videoThumbnailImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(5)
            make.left.equalToSuperview().offset(20)
            make.width.equalTo(162)
            make.height.equalTo(91)
        }
        
        let opacityView = UIView()
        opacityView.layer.opacity = 0.2
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        videoTitleLabel.text = ""
        videoTitleLabel.font = setFontSize(size: 14, weight: .regular)
        videoTitleLabel.numberOfLines = 0
        videoTitleLabel.textColor = UIColor.init(hexString: "666666")
        self.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(videoThumbnailImage.snp.centerY).offset(-2)
            make.left.equalTo(videoThumbnailImage.snp.right).offset(20)
            make.right.equalToSuperview().offset(-10)
        }
        
        prePostView.isHidden = true
        prePostView.backgroundColor = UIColor.init(hexString: "2d00ff")
        self.videoThumbnailImage.addSubview(prePostView)
        prePostView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        prePostLabel.isHidden = true
        prePostLabel.font = setFontSize(size: 10, weight: .regular)
        prePostLabel.textColor = UIColor.init(hexString: "ffffff")
        prePostView.addSubview(prePostLabel)
        prePostLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.top.left.equalToSuperview().offset(3)
        }
        
//        videoViewCountLabel.text = "20 views"
//        videoViewCountLabel.font = setFontSize(size: 11, weight: .semibold)
//        videoViewCountLabel.textColor = UIColor.init(hexString: "666666")
//        self.addSubview(videoViewCountLabel)
//        videoViewCountLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(videoThumbnailImage.snp.centerY).offset(2)
//            make.left.equalTo(videoThumbnailImage.snp.right).offset(20)
//        }
        
//        let spaceView = UIView()
//        spaceView.backgroundColor = UIColor.init(hexString: "888888")
//        spaceView.layer.cornerRadius = 2
//        self.addSubview(spaceView)
//        spaceView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(videoViewCountLabel)
//            make.left.equalTo(videoViewCountLabel.snp.right).offset(6)
//            make.width.height.equalTo(4)
//        }
        
        videoDurationLabel.text = "15 mins"
        videoDurationLabel.font = setFontSize(size: 10, weight: .regular)
        videoDurationLabel.textColor = UIColor.init(hexString: "cacaca")
        self.addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(videoThumbnailImage.snp.centerY).offset(2)
            make.left.equalTo(videoThumbnailImage.snp.right).offset(20)
        }
        
        playingView.isHidden = true
        self.addSubview(playingView)
        playingView.snp.makeConstraints { (make) in
            make.center.size.equalTo(videoThumbnailImage)
        }
        
        let opacityView2 = UIView()
        opacityView2.backgroundColor = .black
        opacityView2.layer.opacity = 0.7
        playingView.addSubview(opacityView2)
        opacityView2.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let playingIcon = UIImageView(image: UIImage.init(named: "cell_playing_icon"))
        playingView.addSubview(playingIcon)
        playingIcon.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(16.2)
            make.width.equalTo(30)
        }
        
        let playingTitle = UILabel()
        playingTitle.font = setFontSize(size: 14, weight: .semibold)
        playingTitle.textColor = .white
        playingTitle.textAlignment = .center
        playingView.addSubview(playingTitle)
        playingTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(playingIcon.snp.bottom).offset(4.3)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func showOpacityView() {
          topView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
          topView.frame = self.frame
          self.addSubview(topView)
          topView.snp.makeConstraints { (make) in
              make.center.size.equalToSuperview()
          }
          let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(userFreemium))
          self.addGestureRecognizer(singleTap)
      }
    
    //MARK: - Data
    
    func setDataSource(videoData: VideoDataSource) {
        self.videoTitleLabel.text = videoData.videoTitle
        
        if let thumbnailURL = URL(string: videoData.imageThumnailStr) {
            self.videoThumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
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
//                                          value: setFontSize(size: 11, weight: .semibold),
//                                          range: NSMakeRange(0, numberStr.count))
//        videoViewCountLabel.attributedText = viewAttributedStr
        
        let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: videoData.videoDuration,
                                                                         color: UIColor.init(hexString: "888888")!,
                                                                         fontActive: setFontSize(size: 11, weight: .semibold),
                                                                         fontInactive: setFontSize(size: 11, weight: .regular))
        videoDurationLabel.attributedText = durationAttributedStr
        
        switch videoData.isPrePostTag {
        case .none:
            self.showPrePostLabel(isHidden: true)
            break
        case .preOnly:
            self.prePostLabel.text = "Pre"
            break
        case .postOnly:
            self.prePostLabel.text = "Post"
            break
        case .both:
            self.prePostLabel.text = "Pre/Post"
            break
        }
    }
    
    func setCellIsPlaying(isPlaying: Bool) {
        self.playingView.isHidden = !isPlaying
    }
    
    func showPrePostLabel(isHidden: Bool) {
        self.prePostView.isHidden = isHidden
        self.prePostLabel.isHidden = isHidden
    }
    
    @objc func userFreemium() {
        _NavController.presentAlertForFreemium()
    }
}
