//
//  VW_RetangleVideoViewCellFull.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/10/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_RetangleVideoViewCellViewCount: UIView {
    
    let thumbnailImage          = UIImageView()
    let opacityView             = UIView()
    
    let frontView               = UIView()
    private let downloadBtn     = UIButton()
    let videoTitleLabel         = UILabel()
    //let videoViewCount          = UILabel()
    let videoDuration           = UILabel()
    
    private let prePostView     = UIView()
    private let prePostLabel    = UILabel()
    
    var delegate                : VideoCellDelegate?
    var videoDataSource         : VideoDataSource?
    private let topView         = UIView()
    
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
        
//        frontView.addSubview(videoViewCount)
//        videoViewCount.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(16)
//            make.bottom.equalToSuperview().offset(-15)
//            make.height.equalTo(10)
//        }
        
//        let spaceView = UIView()
//        spaceView.backgroundColor = UIColor.init(hexString: "6f6f6f")
//        spaceView.layer.cornerRadius = 2
//        frontView.addSubview(spaceView)
//        spaceView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(videoViewCount)
//            make.left.equalTo(videoViewCount.snp.right).offset(5)
//            make.width.height.equalTo(4)
//        }
        
        frontView.addSubview(videoDuration)
        videoDuration.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(10)
        }
        
        videoTitleLabel.text = ""
        videoTitleLabel.font = setFontSize(size: 14, weight: .semibold)
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
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(cellTapped))
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func reloadLayout() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.5, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        self.bringSubviewToFront(frontView)
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
    
    func showDownloadOption(isHidden: Bool) {
        self.downloadBtn.isHidden = isHidden
    }
    
    func showPrePostLabel(isHidden: Bool) {
        self.prePostView.isHidden = isHidden
        self.prePostLabel.isHidden = isHidden
    }
    
    //MARK: - Datas
    func setVideoDataSource(videoData: VideoDataSource) {
        
        self.videoDataSource = videoData
        
        self.videoTitleLabel.text = videoData.videoTitle
        
        if let thumbnailURL = URL(string: videoData.imageThumnailStr) {
            self.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
        // Video count views
//        var viewCountStr = "views"
//        if videoData.viewCount == 1 { viewCountStr = "view" }
//        let viewCountText = String(format: "%ld \(viewCountStr)", videoData.viewCount)
//
//        let viewAttributedString = NSMutableAttributedString(string: viewCountText, attributes: [
//          .font: setFontSize(size: 10, weight: .regular),
//          .foregroundColor: UIColor(white: 221.0 / 255.0, alpha: 1.0),
//          .kern: 0.2
//        ])
//        viewAttributedString.addAttribute(.font, value: setFontSize(size: 10, weight: .semibold), range: NSRange(location: 0, length: viewCountText.count))
//        videoViewCount.attributedText = viewAttributedString

        //Video Duration
        let durationAttributedString = _AppDataHandler.timeAttributedString(seconds: videoData.videoDuration, color: UIColor(white: 221.0 / 255.0, alpha: 1.0), fontActive: setFontSize(size: 10, weight: .semibold), fontInactive: setFontSize(size: 10, weight: .regular))
        videoDuration.attributedText = durationAttributedString
        
    }
    
    // MARK: - Buttons
    @objc func downloadButtonTapped() {
        if delegate != nil {
            if let videoData = self.videoDataSource {
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
}
