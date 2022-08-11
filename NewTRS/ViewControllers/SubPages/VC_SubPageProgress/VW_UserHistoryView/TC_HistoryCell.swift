//
//  TC_HistoryCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_HistoryCell: UITableViewCell {
    
    let videoThumbnail      = UIImageView()
    let contentLayout       = UIView()
    let videoTitleLabel     = UILabel()
    
    //let videoViewLabel      = UILabel()
    let videoDurationLabel  = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.backgroundColor = .white

        videoThumbnail.image = UIImage.init(named: "default_thumbnail_image")
        videoThumbnail.contentMode = .scaleAspectFill
        videoThumbnail.layer.masksToBounds = true
        self.addSubview(videoThumbnail)
        videoThumbnail.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().offset(-16)
        }
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.2
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().offset(-16)
        }
        
        self.addSubview(contentLayout)
        contentLayout.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
            make.height.equalToSuperview().offset(-16)
        }
        
//        self.addSubview(videoViewLabel)
//        videoViewLabel.snp.makeConstraints { (make) in
//            make.left.equalToSuperview().offset(20)
//            make.bottom.equalTo(videoThumbnail.snp.bottom).offset(-20)
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
            make.left.equalToSuperview().offset(20)
            make.bottom.equalTo(videoThumbnail.snp.bottom).offset(-20)
        }
        
        videoTitleLabel.text = "Example video title"
        videoTitleLabel.font = setFontSize(size: 14, weight: .semibold)
        videoTitleLabel.textColor = .white
        self.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(videoDurationLabel.snp.top).offset(-1)
            make.left.equalToSuperview().offset(20)
        }
    }
    
    override func didMoveToSuperview() {
                
        var cellFrame = UIScreen.main.bounds
        cellFrame.size.height = (cellFrame.size.width * 0.533)
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = cellFrame
        gradientLayer.locations = [0.5, 1.0]
        
        self.layer.insertSublayer(gradientLayer, below: self.contentLayout.layer)
    }
    
    func updateVideoInfo(view: Int, durations: Int) {
        
//        var viewCountStr = "views"
//        if view == 1 { viewCountStr = "view" }
//        let viewAttributedString = NSMutableAttributedString(string: "\(view) \(viewCountStr)", attributes: [
//          .font: setFontSize(size: 11, weight: .regular),
//          .foregroundColor: UIColor(white: 221.0 / 255.0, alpha: 1.0),
//          .kern: 0.23
//        ])
//        viewAttributedString.addAttributes([
//          .font: setFontSize(size: 11, weight: .semibold),
//          .kern: 0.22
//        ], range: NSRange(location: 0, length: String(view).count))
//        videoViewLabel.attributedText = viewAttributedString
        
        let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: durations,
                                                                         color: UIColor(white: 221.0 / 255.0, alpha: 1.0),
                                                                         fontActive: setFontSize(size: 11, weight: .semibold),
                                                                         fontInactive: setFontSize(size: 11, weight: .regular))
        videoDurationLabel.attributedText = durationAttributedStr
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Data
    func setDataSource(newDataSource: VideoDataSource) {
        
        if let thumbnailURL = URL(string: newDataSource.imageThumnailStr) {
            self.videoThumbnail.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
        self.videoTitleLabel.text = newDataSource.videoTitle
        self.updateVideoInfo(view: newDataSource.viewCount, durations: newDataSource.videoDuration)
    }
}
