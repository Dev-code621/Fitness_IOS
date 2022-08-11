//
//  VW_ReviewContent.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/30/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_ReviewContent: UIView {
    
    let avatar              = UIImageView()
    let userName            = UILabel()
    let userJoin            = UILabel()
    let userReview          = UILabel()
    let pageControl         = UIPageControl()

    override init(frame: CGRect) {
        super.init(frame: frame)
            
        avatar.image = UIImage.init(named: "default_avatar")
        avatar.layer.cornerRadius = 30
        avatar.layer.masksToBounds = true
        self.addSubview(avatar)
        avatar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.height.width.equalTo(60)
            make.centerX.equalToSuperview()
        }
        
        userName.text = "Micheal Lee"
        userName.font = setFontSize(size: 14, weight: .bold)
        userName.textColor = UIColor.init(hexString: "333333")
        userName.textAlignment = .center
        self.addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.top.equalTo(avatar.snp.bottom).offset(8)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
        }
        
        userJoin.text = "Since 2019"
        userJoin.font = setFontSize(size: 11, weight: .regular)
        userJoin.textColor = UIColor.init(hexString: "a5a5a5")
        userJoin.textAlignment = .center
        self.addSubview(userJoin)
        userJoin.snp.makeConstraints { (make) in
            make.top.equalTo(userName.snp.bottom).offset(3)
            make.centerX.equalToSuperview()
            make.height.equalTo(14)
        }
        
        let star1 = UIImageView()
        star1.image = UIImage.init(named: "star_rating_selected")
        star1.layer.masksToBounds = true
        self.addSubview(star1)
        star1.snp.makeConstraints { (make) in
            make.top.equalTo(userJoin.snp.bottom).offset(3)
            make.height.width.equalTo(11)
        }
        
        let star2 = UIImageView()
        star2.image = UIImage.init(named: "star_rating_selected")
        star2.layer.masksToBounds = true
        self.addSubview(star2)
        star2.snp.makeConstraints { (make) in
            make.top.equalTo(userJoin.snp.bottom).offset(3)
            make.height.width.equalTo(11)
            make.left.equalTo(star1.snp.right).offset(4)
        }
        
        let star3 = UIImageView()
        star3.image = UIImage.init(named: "star_rating_selected")
        star3.layer.masksToBounds = true
        self.addSubview(star3)
        star3.snp.makeConstraints { (make) in
            make.top.equalTo(userJoin.snp.bottom).offset(3)
            make.height.width.equalTo(11)
            make.left.equalTo(star2.snp.right).offset(4)
            make.centerX.equalToSuperview()
        }
        
        let star4 = UIImageView()
        star4.image = UIImage.init(named: "star_rating_selected")
        star4.layer.masksToBounds = true
        self.addSubview(star4)
        star4.snp.makeConstraints { (make) in
            make.top.equalTo(userJoin.snp.bottom).offset(3)
            make.height.width.equalTo(11)
            make.left.equalTo(star3.snp.right).offset(4)
        }
        
        let star5 = UIImageView()
        star5.image = UIImage.init(named: "star_rating_selected")
        star5.layer.masksToBounds = true
        self.addSubview(star5)
        star5.snp.makeConstraints { (make) in
            make.top.equalTo(userJoin.snp.bottom).offset(3)
            make.height.width.equalTo(11)
            make.left.equalTo(star4.snp.right).offset(4)
        }
        
        let scrollContent = UIScrollView()
        self.addSubview(scrollContent)
        scrollContent.snp.makeConstraints { (make) in
            make.top.equalTo(star1.snp.bottom).offset(17)
            make.bottom.equalToSuperview().offset(-30)
            make.left.right.width.equalToSuperview()
        }
        
        let attributedString = NSMutableAttributedString(string: "")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        userReview.attributedText = attributedString
        userReview.font = setFontSize(size: 15, weight: .regular)
        userReview.textColor = UIColor.init(hexString: "666666")
        userReview.numberOfLines = 0
        scrollContent.addSubview(userReview)
        userReview.snp.makeConstraints { (make) in
            make.centerX.top.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-36)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Data
    func setReviewData(_ reviewData: ReviewDataSource) {
        
        if let avatarURL = URL(string: reviewData.reviewerAvatar) {
            self.avatar.setImage(url: avatarURL, placeholder: UIImage.init(named: "default_avatar")!)
        }
        
        self.userName.text = reviewData.reviewerName
        self.userJoin.text = NSLocalizedString("kReviewUserJoin", comment: "").replacingOccurrences(of: "%@", with: String(reviewData.reviewdateSince))
        
        let attributedString = NSMutableAttributedString(string: reviewData.reviewContent)
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        self.userReview.attributedText = attributedString
        self.userReview.textAlignment = .center
    }
}
