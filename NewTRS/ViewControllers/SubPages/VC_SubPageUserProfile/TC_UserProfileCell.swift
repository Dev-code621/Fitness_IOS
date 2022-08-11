//
//  TC_UserProfileCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/25/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_UserProfileCell: UITableViewCell {
    
    let cellIcon        = UIImageView()
    let cellTitle       = UILabel()
    let cellIconNext    = UIImageView()
    let bottomLine      = UIView()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.addSubview(cellIcon)
        cellIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.centerY.equalToSuperview()
            make.width.height.equalTo(15)
        }
        
        cellTitle.font = setFontSize(size: 14, weight: .regular)
        cellTitle.textColor = UIColor.init(hexString: "666666")
        self.addSubview(cellTitle)
        cellTitle.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(cellIcon.snp.right).offset(20)
            make.right.equalToSuperview().offset(-30)
        }
        
        cellIconNext.image = UIImage.init(named: "ic_next")
        self.addSubview(cellIconNext)
        cellIconNext.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-20)
            make.centerY.equalToSuperview()
            make.height.equalTo(12)
            make.width.equalTo(7)
        }
        
        bottomLine.backgroundColor = UIColor.init(hexString: "d8d8d8")
        self.addSubview(bottomLine)
        bottomLine.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview()
            make.left.equalTo(cellIcon)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(1)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
