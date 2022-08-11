//
//  VW_RetangleVideoCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/15/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_RetangleVideoViewCellTitleOnly: UIView {
    
    var delegate            : VideoCellDelegate?
    
    let thumbnailImage      = UIImageView()
    let videoTitleLabel     = UILabel()
    let videoDuration       = UILabel()
    
    var videoDataSource     : VideoDataSource?
    private let frontView       = UIView()
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
        
        self.addSubview(frontView)
        frontView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        videoTitleLabel.text = ""
        videoTitleLabel.numberOfLines = 0
        videoTitleLabel.font = setFontSize(size: 12, weight: .semibold)
        videoTitleLabel.textColor = .white
        frontView.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.width.equalToSuperview().offset(-20)
        }
        
        frontView.addSubview(videoDuration)
        videoDuration.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-8)
            make.height.equalTo(10)
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
    
    //MARK: - Datas
    func setVideoDataSource(videoData: VideoDataSource) {
        
        self.videoDataSource = videoData
        
        self.videoTitleLabel.text = videoData.videoTitle
        
        if let thumbnailURL = URL(string: videoData.imageThumnailStr) {
            self.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
        let durationAttributedString = _AppDataHandler.timeAttributedString(seconds: videoData.videoDuration, color: UIColor.white, fontActive: setFontSize(size: 10, weight: .semibold), fontInactive: setFontSize(size: 10, weight: .regular))
        videoDuration.attributedText = durationAttributedString
    }
    
    //MARK:- Tap
    @objc func cellTapped() {
        
        guard let videoData = self.videoDataSource else {return}
        
        if (delegate != nil) {
            delegate!.didSelectVideo(videoData: videoData)
        }
    }
    
    @objc func userFreemium() {
        _NavController.presentAlertForFreemium()
    }
}
