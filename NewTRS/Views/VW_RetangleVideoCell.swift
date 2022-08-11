//
//  VW_RetangleVideoCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/15/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_RetangleVideoViewCell: UIView {
    
    let thumbnailImage      = UIImageView()
    let videoTitleLabel     = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbnailImage.image = UIImage.init(named: "test_image")
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        videoTitleLabel.text = "Example Title"
        videoTitleLabel.numberOfLines = 0
        videoTitleLabel.font = UIFont.init(name: "HurmeGeometricSans1-SemiBold", size: 12)
        videoTitleLabel.textColor = .white
        self.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
            make.width.equalToSuperview().offset(-20)
        }
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
        
        self.bringSubviewToFront(videoTitleLabel)
    }
    
}
