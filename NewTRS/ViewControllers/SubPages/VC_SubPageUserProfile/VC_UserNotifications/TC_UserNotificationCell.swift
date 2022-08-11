//
//  TC_UserNotificationCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/25/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TC_UserNotificationCell: UITableViewCell {
    
    private let cellContentView = UIView()
    let avatarImageView         = UIImageView()
    let titleLabel              = UILabel()
    let contentLabel            = UILabel()
    let dateLabel               = UILabel()

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.layer.masksToBounds = true
        self.backgroundColor = UIColor.init(hexString: "fafafa")
        
        cellContentView.layer.shadowColor = UIColor.init(hexString: "0c1d00ff")?.cgColor
        cellContentView.layer.shadowOpacity = 1
        cellContentView.layer.shadowOffset = CGSize(width: 5, height: 0)
        cellContentView.layer.shadowRadius = 5
        cellContentView.backgroundColor = .white
        cellContentView.layer.cornerRadius = 15
        self.addSubview(cellContentView)
        cellContentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalToSuperview().offset(-6)
            make.width.equalToSuperview().offset(-20)
        }
        
        avatarImageView.image = UIImage.init(named: "default_avatar")
        avatarImageView.layer.cornerRadius = 20
        avatarImageView.layer.masksToBounds = true
        cellContentView.addSubview(avatarImageView)
        avatarImageView.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(10)
            make.height.width.equalTo(40)
        }
        
        titleLabel.text = ""
        titleLabel.font = setFontSize(size: 14, weight: .semibold)
        titleLabel.textColor = UIColor.init(hexString: "666666")
        cellContentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(27)
            make.left.equalTo(avatarImageView.snp.right).offset(16.5)
            make.right.equalToSuperview()
        }
        
        dateLabel.text = "Jul 25"
        dateLabel.font = setFontSize(size: 10, weight: .semibold)
        dateLabel.textColor = UIColor.init(hexString: "888888")
        dateLabel.textAlignment = .right
        cellContentView.addSubview(dateLabel)
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(27.5)
            make.right.equalToSuperview().offset(-10)
        }
        
        contentLabel.text = ""
        contentLabel.numberOfLines = 0
        contentLabel.font = setFontSize(size: 10, weight: .regular) 
        contentLabel.textColor = UIColor.init(hexString: "888888")
        cellContentView.addSubview(contentLabel)
        contentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(10)
            make.left.right.equalTo(titleLabel)
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        if selected {
            UIView.animate(withDuration: 0.2) {
                self.cellContentView.backgroundColor = UIColor.init(hexString: "F3F1FF")!
            }
        } else {
            UIView.animate(withDuration: 0.2) {
                self.cellContentView.backgroundColor = .white
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
