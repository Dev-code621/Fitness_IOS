//
//  VW_RetangleVideoViewCellFull.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/10/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_RetangleVideoViewCellTagging: UIView {
    
    let thumbnailImage          = UIImageView()
    let opacityView             = UIView()
    
    let frontView               = UIView()
    private let downloadBtn     = UIButton()
    private let downloadActivityIndicator = UIActivityIndicatorView(style: .white)
    let videoTitleLabel         = UILabel()
    let videoDurationLabel      = UILabel()
    let videoTaggingLabel       = UILabel()
    
    private let prePostView     = UIView()
    private let prePostLabel    = UILabel()
    
    private let playingView     = UIView()
    private let topView         = UIView()
    
    var delegate                : VideoCellDelegate?
    var videoDataSource         : VideoDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbnailImage.image = UIImage.init(named: "default_thumbnail_image")
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.masksToBounds = true
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.2
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.addSubview(frontView)
        frontView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        downloadActivityIndicator.hidesWhenStopped = true
        frontView.addSubview(downloadActivityIndicator)
        downloadActivityIndicator.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.width.equalTo(30)
        }
        
        downloadBtn.backgroundColor = UIColor.init(hexString: "b31d00ff")
        downloadBtn.layer.cornerRadius = 15
        downloadBtn.layer.masksToBounds = true
        downloadBtn.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        frontView.addSubview(downloadBtn)
        downloadBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
            make.height.width.equalTo(30)
        }
        
        let downloadIcon = UIImageView()
        downloadIcon.image = UIImage.init(named: "download_icon_white")
        downloadBtn.addSubview(downloadIcon)
        downloadIcon.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(15)
        }
        
        videoDurationLabel.text = "6:23"
        videoDurationLabel.font = setFontSize(size: 10, weight: .bold)
        videoDurationLabel.textColor = .white
        frontView.addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(10)
        }
        
        videoTaggingLabel.text = "Video & Audio"
        videoTaggingLabel.font = setFontSize(size: 10, weight: .regular)
        videoTaggingLabel.textColor = UIColor.init(hexString: "cacaca")
        frontView.addSubview(videoTaggingLabel)
        videoTaggingLabel.snp.makeConstraints { (make) in
            make.left.equalTo(videoDurationLabel.snp.right).offset(6)
            make.height.equalTo(10)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        videoTitleLabel.text = ""
        videoTitleLabel.font = setFontSize(size: 14, weight: .regular)
        videoTitleLabel.textColor = .white
        frontView.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.right.equalToSuperview().offset(-16)
            make.bottom.equalToSuperview().offset(-27)
        }
        
        prePostView.backgroundColor = UIColor.init(hexString: "2d00ff")
        frontView.addSubview(prePostView)
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
            make.top.left.equalToSuperview().offset(6)
        }
        
        //Playing view
        playingView.isHidden = true
        self.addSubview(playingView)
        playingView.snp.makeConstraints { (make) in
            make.center.size.equalTo(self)
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
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(cellTapped))
        self.addGestureRecognizer(singleTap)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: kDownloadVideoDoneNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: kDownloadVideoCancelNotification, object: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func reloadLayout() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        self.bringSubviewToFront(frontView)
    }
    
    func showDownloadOption(isHidden: Bool) {
        self.downloadBtn.isHidden = isHidden
    }
    
    func showPrePostLabel(isHidden: Bool) {
        self.prePostView.isHidden = isHidden
        self.prePostLabel.isHidden = isHidden
    }
    
    func showOpacityView() {
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
        topView.frame = self.frame
        frontView.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(userFreemium))
        self.addGestureRecognizer(singleTap)
    }
    //MARK: - Data
    
    @objc private func handleNotification(noti: Notification) {
        if noti.name == kDownloadVideoDoneNotification {
            if let videoID = noti.userInfo?["video_id"] as? Int {
                if self.videoDataSource?.videoID == videoID {
                    DispatchQueue.main.async {
                        self.downloadActivityIndicator.stopAnimating()
                    }
                }
            }
        } else if noti.name == kDownloadVideoCancelNotification {
            if let videoID = noti.userInfo?["video_id"] as? Int {
                if self.videoDataSource?.videoID == videoID {
                    DispatchQueue.main.async {
                        self.downloadActivityIndicator.stopAnimating()
                        self.downloadBtn.isHidden = false
                    }
                }
            }
        }
    }
    
    func setVideoDataSource(newVideoData: VideoDataSource) {
        self.videoDataSource = newVideoData
        
        if let thumbnailURL = URL(string: newVideoData.imageThumnailStr) {
            self.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
        if _AppVideoManager.isVideoIsDownloading(videoID: newVideoData.videoID) {
            DispatchQueue.main.async {
                self.downloadActivityIndicator.startAnimating()
                self.downloadBtn.isHidden = true
            }
        }
        
        self.videoTitleLabel.text = newVideoData.videoTitle
        self.videoDurationLabel.text = "\(newVideoData.videoDuration/60) min"
        
        switch newVideoData.isPrePostTag {
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
    
    // MARK: - Buttons
    @objc func downloadButtonTapped() {
        if delegate != nil {
            if let videoData = self.videoDataSource {
                DispatchQueue.main.async {
                    self.downloadActivityIndicator.startAnimating()
                    self.downloadBtn.isHidden = true
                }
                delegate!.didSelectDownloadVideo(videoData: videoData)
            }
        }
    }
    
    @objc func cellTapped() {
        if (delegate != nil) {
            if let videoData = self.videoDataSource {
            delegate!.didSelectVideo(videoData: videoData)
            }
        }
    }
    
    @objc func userFreemium() {
        _NavController.presentAlertForFreemium()
    }
    
    func setCellIsPlaying(isPlaying: Bool) {
        self.playingView.isHidden = !isPlaying
    }
}
