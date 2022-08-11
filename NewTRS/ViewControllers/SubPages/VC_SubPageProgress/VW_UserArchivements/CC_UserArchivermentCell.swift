//
//  CC_UserArchivermentCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class CC_UserArchivermentCell: UICollectionViewCell {
    
    let streaksImage       = UIImageView()
    let streaksName        = UILabel()
    let dayToNextStreak    = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        streaksImage.image = UIImage(named: "default_archiverment_image")
        streaksImage.layer.cornerRadius = 30
        streaksImage.layer.masksToBounds = true
        self.addSubview(streaksImage)
        streaksImage.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.height.width.equalTo(60)
        }
        
        streaksName.font = setFontSize(size: 14, weight: .regular)
        streaksName.textColor = UIColor.init(hexString: "666666")
        streaksName.textAlignment = .center
        self.addSubview(streaksName)
        streaksName.snp.makeConstraints { (make) in
            make.top.equalTo(streaksImage.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
        }
        
        dayToNextStreak.font = setFontSize(size: 10, weight: .regular)
        dayToNextStreak.textColor = UIColor.init(hexString: "666666")
        dayToNextStreak.textAlignment = .center
        self.addSubview(dayToNextStreak)
        dayToNextStreak.snp.makeConstraints { (make) in
            make.top.equalTo(streaksName.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
