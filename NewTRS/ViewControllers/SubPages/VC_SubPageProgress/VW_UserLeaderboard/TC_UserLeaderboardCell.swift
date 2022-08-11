//
//  TC_UserLeaderboardCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_UserLeaderboardCell: UITableViewCell {
    
    let userRank        = UILabel()
    let userAvatar      = UIImageView()
    let userName        = UILabel()
    let userBadge       = UILabel()
    let userPoint       = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        userRank.font = setFontSize(size: 14, weight: .semibold)
        userRank.textColor = UIColor.init(hexString: "666666")
        self.addSubview(userRank)
        userRank.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(20)
        }
        
        userAvatar.image = UIImage.init(named: "default_avatar")
        userAvatar.layer.cornerRadius = 20
        userAvatar.layer.masksToBounds = true
        self.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalToSuperview().offset(50)
            make.height.width.equalTo(40)
        }
        
        userName.text = "Example User Name"
        userName.font = setFontSize(size: 14, weight: .semibold)
        userName.textColor = UIColor.init(hexString: "666666")
        self.addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.bottom.equalTo(userAvatar.snp.centerY)
            make.left.equalTo(userAvatar.snp.right).offset(16.5)
        }
        
        userBadge.text = ""
        userBadge.font = setFontSize(size: 10, weight: .regular)
        userBadge.textColor = UIColor.init(hexString: "888888")
        self.addSubview(userBadge)
        userBadge.snp.makeConstraints { (make) in
            make.top.equalTo(userName.snp.bottom).offset(6)
            make.left.equalTo(userName)
        }
        
        self.addSubview(userPoint)
        userPoint.snp.makeConstraints { (make) in
            make.centerY.equalTo(userBadge)
            make.right.equalToSuperview().offset(-20)
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
