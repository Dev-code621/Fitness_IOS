//
//  VW_MobilityCircle.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/17/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_MobilityCircle: UIView {
    
    private let mobilityLabel   = UILabel()
    private let mobilityValue   = UILabel()
    let progressBar     = MBCircularProgressBarView()
    let mobilityName    = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage.init(named: "mobility_circle_background_image")
        self.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { (make) in
            make.top.centerX.width.equalToSuperview()
            make.height.equalTo(backgroundImage.snp.width)
        }
        
        progressBar.backgroundColor = .clear
        progressBar.progressStrokeColor = .clear
        progressBar.valueFont = setFontSize(size: 14, weight: .bold)
        progressBar.unitFont = setFontSize(size: 14, weight: .bold)
        progressBar.emptyLineWidth = 0
        progressBar.progressLineWidth = 8
        progressBar.progressCapType = 2
        progressBar.progressAngle = 96
        progressBar.maxValue = 100
        self.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.center.equalTo(backgroundImage)
            make.size.equalTo(backgroundImage).multipliedBy(0.96)
        }
        
        mobilityName.textAlignment = .center
        mobilityName.numberOfLines = 0
        mobilityName.font = setFontSize(size: 14, weight: .regular)
        mobilityName.textColor = UIColor.init(hexString: "666666")
        self.addSubview(mobilityName)
        mobilityName.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(backgroundImage.snp.bottom).offset(12)
        }
    }
    
    func setData(value: Double, name: String) {
        
        let newValue = value*100
        
        progressBar.progressRotationAngle = 350
        progressBar.value = CGFloat(newValue)
        mobilityName.text = name
        
        if newValue >= 0 && newValue <= 34 {
            progressBar.fontColor = UIColor.init(hexString: "ff5555")!
            progressBar.progressColor = UIColor.init(hexString: "ff5555")!
        }
        else if newValue <= 67 {
            progressBar.fontColor = UIColor.init(hexString: "ffbd34")!
            progressBar.progressColor = UIColor.init(hexString: "ffbd34")!
        } else {
            progressBar.fontColor = UIColor.init(hexString: "0bd493")!
            progressBar.progressColor = UIColor.init(hexString: "0bd493")!
        }
    }
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
