//
//  TC_DownloadedVideoCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol TC_DownloadedVideoCellDelegate {
    func didDeleteVideo(videoData: VideoDownloadedDataSource)
}

class TC_DownloadedVideoCell: UITableViewCell {
    
    var delegate        : TC_DownloadedVideoCellDelegate?
    var videoData       : VideoDownloadedDataSource?
    
    let videoThumbnail  = UIImageView()
    let contentLayout   = UIView()
    
    let deleteBtn       = UIButton()
    let videoTitle      = UILabel()
    let dateDownload    = UILabel()
    
    let downloadStatus  = UIView()
    let progressDownload = UIProgressView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white
        
        progressDownload.progress = 0
        progressDownload.tintColor = UIColor.init(hexString: "2d00ff")
        self.addSubview(progressDownload)
        
        progressDownload.snp.makeConstraints { (make) in
            make.top.equalTo(5)
            make.height.equalTo(5)
            make.left.right.equalToSuperview()
        }
        
        videoThumbnail.image = UIImage.init(named: "default_thumbnail_image")
        videoThumbnail.contentMode = .scaleAspectFill
        videoThumbnail.layer.masksToBounds = true
        self.addSubview(videoThumbnail)
        videoThumbnail.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().offset(-20)
        }
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.2
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().offset(-20)
        }
        
        self.addSubview(contentLayout)
        contentLayout.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().offset(-20)
        }
        
        let attributedString = NSMutableAttributedString(string: "Download date May 10, 2020", attributes: [
          .font: setFontSize(size: 11, weight: .regular),
          .foregroundColor: UIColor(white: 221.0 / 255.0, alpha: 1.0),
          .kern: 0.23
        ])
        attributedString.addAttribute(.font, value: setFontSize(size: 11, weight: .semibold), range: NSRange(location: 14, length: 12))
        dateDownload.attributedText = attributedString
        self.addSubview(dateDownload)
        dateDownload.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-30)
            make.left.equalToSuperview().offset(20)
        }
        
        videoTitle.text = "Example Video"
        videoTitle.font = setFontSize(size: 14, weight: .semibold)
        videoTitle.textColor = .white
        self.addSubview(videoTitle)
        videoTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(dateDownload.snp.top).offset(-1)
            make.left.equalToSuperview().offset(20)
        }
        
        deleteBtn.layer.cornerRadius = 18
        deleteBtn.backgroundColor = UIColor.init(hexString: "b31d00ff")
        deleteBtn.addTarget(self, action: #selector(didDeleteButtonTapped), for: .touchUpInside)
        self.addSubview(deleteBtn)
        deleteBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-10)
            make.height.width.equalTo(36)
        }
        
        let closeIcon = UIImageView.init(image: (UIImage.init(named: "close_btn")))
        deleteBtn.addSubview(closeIcon)
        closeIcon.snp.makeConstraints { (make) in
            make.center.equalTo(deleteBtn)
            make.height.width.equalTo(20)
        }
        
        downloadStatus.backgroundColor = UIColor.init(hexString: "2d00ff")
        self.addSubview(downloadStatus)
        downloadStatus.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(20)
        }
        
        let downloadingLabel = UILabel()
        downloadingLabel.text = "Downloading"
        downloadingLabel.font = setFontSize(size: 10, weight: .regular)
        downloadingLabel.textColor = UIColor.init(hexString: "ffffff")
        downloadStatus.addSubview(downloadingLabel)
        downloadingLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.top.left.equalToSuperview().offset(6)
        }
    }
    
    override func didMoveToSuperview() {
                
        var cellFrame = UIScreen.main.bounds
        cellFrame.size.height = (cellFrame.size.width * 0.533 ) - 10
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = cellFrame
        gradientLayer.locations = [0.5, 1.0]
        
        self.layer.insertSublayer(gradientLayer, below: self.contentLayout.layer)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setVideoData(newVideoData: VideoDownloadedDataSource) {
        
        self.videoData = newVideoData
        self.videoTitle.text = newVideoData.videoTitle
        self.bringSubviewToFront(deleteBtn)
        var imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        imageURL = imageURL.appendingPathComponent(String(format: "Downloaded/%ld.png", newVideoData.videoID))
        self.videoThumbnail.setImage(url: imageURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        
        let date = Date.init(timeIntervalSince1970: TimeInterval(newVideoData.savedDate))
        let string = String(format: "Download date %@", dateFormatter.string(from: date))
        
        let attributedString = NSMutableAttributedString(string: string, attributes: [
          .font: setFontSize(size: 11, weight: .regular),
          .foregroundColor: UIColor(white: 221.0 / 255.0, alpha: 1.0),
          .kern: 0.23
        ])
        attributedString.addAttribute(.font, value: setFontSize(size: 11, weight: .semibold), range: NSRange(location: 14, length: 12))
        
        self.dateDownload.attributedText = attributedString
        
        if newVideoData.videoDownloadPercent < 1 {
            self.downloadStatus.isHidden   = false
            self.progressDownload.isHidden = false
        } else {
            self.downloadStatus.isHidden   = true
            self.progressDownload.isHidden = true
        }
        self.progressDownload.progress = Float(newVideoData.videoDownloadPercent)
    }
    
    //MARK: - Delegate
    @objc private func didDeleteButtonTapped() {
        if delegate != nil, self.videoData != nil {
            delegate?.didDeleteVideo(videoData: self.videoData!)
        }
    }
}
