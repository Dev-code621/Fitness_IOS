//
//  VW_StreaksCircle.swift
//  NewTRS
//
//  Created by Phuong Duy on 9/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_StreaksCircle: UIView {
    
    private let progressBar      = MBCircularProgressBarView()
    private let nextStreaksImage = UIImageView()

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        progressBar.progressColor = UIColor.init(hexString: "2d00ff")!
        progressBar.backgroundColor = .clear
        progressBar.progressStrokeColor = .clear
        progressBar.emptyLineWidth = 12
        progressBar.emptyLineColor = UIColor.init(hexString: "718cfe")?.withAlphaComponent(0.15)
        progressBar.emptyLineStrokeColor = .clear
        progressBar.progressLineWidth = 6
        progressBar.progressCapType = 1
        progressBar.progressAngle = 100
        progressBar.maxValue = 7
        
        self.addSubview(progressBar)
        progressBar.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        nextStreaksImage.image = UIImage.init(named: "archiverment_cougar_image")
        progressBar.addSubview(nextStreaksImage)
        nextStreaksImage.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview().offset(-40)
        }
    }
    
    func setData(imageURL: String, value: Int, maxValue: Int) {
                
        progressBar.progressRotationAngle = 350
        if let url = URL(string: imageURL) {
        nextStreaksImage.setImage(url: url, placeholder: UIImage.init(named: "default_archiverment_image")!)
        }
        progressBar.value = CGFloat(value)
        progressBar.maxValue = CGFloat(maxValue)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
