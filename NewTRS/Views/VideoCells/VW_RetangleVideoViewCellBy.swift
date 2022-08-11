//
//  VW_RetangleNewVideoCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/10/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_RetangleVideoViewCellBy: UIView {
    
    let thumbnailImage          = UIImageView()
    let opacityView             = UIView()
    
    let frontView               = UIView()
    private let downloadBtn     = UIButton()
    let videoTitleLabel         = UILabel()
    let videoPostedBy           = UILabel()
    let videoDuration           = UILabel()
    
    private let prePostView     = UIView()
    private let prePostLabel    = UILabel()
    
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
        
        let attributedString = NSMutableAttributedString(string: "By Bily", attributes: [
            .font: setFontSize(size: 10, weight: .semibold),
          .foregroundColor: UIColor(white: 221.0 / 255.0, alpha: 1.0),
          .kern: 0.2
        ])
        attributedString.addAttribute(.font, value: setFontSize(size: 10, weight: .regular), range: NSRange(location: 0, length: 2))
        videoPostedBy.attributedText = attributedString
        frontView.addSubview(videoPostedBy)
        videoPostedBy.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
            make.bottom.equalToSuperview().offset(-15)
            make.height.equalTo(10)
        }
        
        
        let dattributedString = NSMutableAttributedString(string: "5 min", attributes: [
            .font: setFontSize(size: 10, weight: .regular),
          .foregroundColor: UIColor(white: 221.0 / 255.0, alpha: 1.0),
          .kern: 0.2
        ])
        dattributedString.addAttribute(.font, value: setFontSize(size: 10, weight: .semibold), range: NSRange(location: 0, length: 1))
        videoDuration.attributedText = dattributedString
        frontView.addSubview(videoDuration)
        videoDuration.snp.makeConstraints { (make) in
            make.left.equalTo(videoPostedBy.snp.right).offset(6)
            make.height.equalTo(10)
            make.bottom.equalToSuperview().offset(-15)
        }
        
        videoTitleLabel.text = ""
        videoTitleLabel.font = setFontSize(size: 14, weight: .semibold)
        videoTitleLabel.textColor = .white
        frontView.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(16)
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
    
    func showDownloadOption(isHidden: Bool) {
        self.downloadBtn.isHidden = isHidden
    }
    
    func showPrePostLabel(isHidden: Bool) {
        self.prePostView.isHidden = isHidden
        self.prePostLabel.isHidden = isHidden
    }
    
    //MARK: - Datas
    func setVideoDataSource(videoData: VideoDataSource) {
        self.videoTitleLabel.text = videoData.videoTitle
        
        if let thumbnailURL = URL(string: videoData.imageThumnailStr) {
            self.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
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
}
