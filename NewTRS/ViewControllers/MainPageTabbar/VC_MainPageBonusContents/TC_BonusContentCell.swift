//
//  TC_BonusContentCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_BonusContentCell: UITableViewCell {
    
    let thumbnailImage          = UIImageView()
    let titleLabel              = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.masksToBounds = true
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.bottom.equalToSuperview().offset(-10)
            make.left.equalToSuperview().offset(20)
            make.width.height.equalTo(74.5)
        }
        
        titleLabel.font = setFontSize(size: 18, weight: .semibold)
        titleLabel.textColor = UIColor.init(hexString: "666666")
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(thumbnailImage)
            make.left.equalTo(thumbnailImage.snp.right).offset(20)
            make.right.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
