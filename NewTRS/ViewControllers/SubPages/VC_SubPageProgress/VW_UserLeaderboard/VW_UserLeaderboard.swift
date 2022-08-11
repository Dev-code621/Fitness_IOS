//
//  VW_UserLeaderboard.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_UserLeaderboard: UIView,
                        UITableViewDataSource, UITableViewDelegate {
    
    var delegate        : VC_SubPageProgress?
    
    let topUserAvatar   = UIImageView()
    let topUserName     = UILabel()
    let topUserBadge    = UILabel()
    let topUserPoint    = UILabel()
    
    let circleView      = UIView()
    let tableView       = UITableView()
    
    let nodataView      = UIView()
    
    var currentUserRank : UserProfileRank?
    var listLeaderboard : [UserProfileRank] = []
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "fafafa")
        
        circleView.backgroundColor = .white
        circleView.layer.cornerRadius = 50
        circleView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        circleView.layer.masksToBounds = true
        self.addSubview(circleView)
        circleView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(130)
        }
        
        topUserAvatar.image = UIImage.init(named: "default_avatar")
        topUserAvatar.layer.cornerRadius = 50
        topUserAvatar.layer.masksToBounds = true
        circleView.addSubview(topUserAvatar)
        topUserAvatar.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(17)
            make.height.width.equalTo(100)
        }
        
//        let ovalView = UIView()
//        ovalView.backgroundColor = UIColor.init(hexString: "1d00ff")
//        ovalView.layer.cornerRadius = 14
//        ovalView.layer.borderColor = UIColor.white.cgColor
//        ovalView.layer.borderWidth = 3
//        circleView.addSubview(ovalView)
//        ovalView.snp.makeConstraints { (make) in
//            make.bottom.equalTo(topUserAvatar)
//            make.right.equalTo(topUserAvatar).offset(-5.5)
//            make.height.width.equalTo(28)
//        }
//
//        let top1Label = UILabel()
//        top1Label.text = "1"
//        top1Label.font = setFontSize(size: 19, weight: .bold)
//        top1Label.textColor = .white
//        top1Label.textAlignment = .center
//        ovalView.addSubview(top1Label)
//        top1Label.snp.makeConstraints { (make) in
//            make.centerX.size.equalToSuperview()
//            make.centerY.equalToSuperview().offset(2)
//        }
        
        topUserName.text = "Example User Name"
        topUserName.font = setFontSize(size: 18, weight: .semibold)
        topUserName.textColor = UIColor.init(hexString: "666666")
        circleView.addSubview(topUserName)
        topUserName.snp.makeConstraints { (make) in
            make.bottom.equalTo(topUserAvatar.snp.centerY)
            make.left.equalTo(topUserAvatar.snp.right).offset(20)
        }
        
        topUserBadge.text = "0 pts"
        topUserBadge.font = setFontSize(size: 14, weight: .regular)
        topUserBadge.textColor = UIColor.init(hexString: "888888")
        circleView.addSubview(topUserBadge)
        topUserBadge.snp.makeConstraints { (make) in
            make.top.equalTo(topUserName.snp.bottom).offset(6)
            make.left.equalTo(topUserName)
        }
        
        circleView.addSubview(topUserPoint)
        topUserPoint.snp.makeConstraints { (make) in
            make.centerY.equalTo(topUserBadge)
            make.right.equalToSuperview().offset(-20)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TC_UserLeaderboardCell.self, forCellReuseIdentifier: "userRankCell")
        self.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(circleView.snp.bottom).offset(4)
            make.left.right.bottom.equalToSuperview()
        }
        
        
        nodataView.isHidden = true
        nodataView.backgroundColor = UIColor.init(hexString: "fafafa")
        self.addSubview(nodataView)
        nodataView.snp.makeConstraints { (make) in
            make.bottom.centerX.width.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let nodataMessage = UILabel()
        nodataMessage.text = NSLocalizedString("kUserLeaderboardNoData", comment: "")
        nodataMessage.textAlignment = .center
        nodataMessage.font = setFontSize(size: 14, weight: .regular)
        nodataMessage.textColor = UIColor.init(hexString: "666666")
        nodataMessage.numberOfLines = 0
        nodataView.addSubview(nodataMessage)
        nodataMessage.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().offset(-50)
            make.width.equalToSuperview().offset(-40)
        }
        
        let nodataTitle = UILabel()
        nodataTitle.text = NSLocalizedString("kUserLeaderboardNoDataTitle", comment: "")
        nodataTitle.font = setFontSize(size: 18, weight: .bold)
        nodataTitle.textAlignment = .center
        nodataTitle.textColor = UIColor.init(hexString: "333333")
        nodataTitle.numberOfLines = 0
        nodataView.addSubview(nodataTitle)
        nodataTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(nodataMessage.snp.top).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        let okButton = UIButton()
        okButton.setTitle("OK", for: .normal)
        okButton.backgroundColor = UIColor.init(hexString: "2d00ff")
        okButton.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        okButton.layer.cornerRadius = 20
        okButton.addTarget(self, action: #selector(okButtonTapped), for: .touchUpInside)
        nodataView.addSubview(okButton)
        okButton.snp.makeConstraints { (make) in
            make.bottom.equalTo(nodataView.snp.bottom).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: -
    @objc private func okButtonTapped() {
        if delegate != nil {
            delegate?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Data
//    func set(userRank rank: UserProfileRank?, leaderboard list: [UserProfileRank]) {
//        self.currentUserRank = rank
//        self.listLeaderboard = list
//
//        self.nodataView.isHidden = !(list.count == 0)
//
//        //get top 1 rank
//        let topRank = list.first
//
//        if let imageURL = URL(string: topRank?.userAvatar ?? "") {
//            self.topUserAvatar.setImage(url: imageURL, placeholder: UIImage.init(named: "default_avatar")!)
//        }
//        self.topUserName.text = topRank?.userName
//        self.topUserBadge.text = topRank?.userBadge
//        self.topUserPoint.text = topRank?.userPoint == nil ? "" : (topRank?.userPoint)! + " pts"
//
//        if rank?.userName == topRank?.userName {
//            circleView.backgroundColor = UIColor.init(hexString: "ebe8ff")
//        }
//
//        self.tableView.reloadData()
//    }
    
    func set(userRank rank: UserProfileRank?, leaderboard list: [UserProfileRank]) {
        self.currentUserRank = rank
        self.listLeaderboard = list

        self.nodataView.isHidden = !(list.count == 0) || !(rank == nil)
        
        let escapedString = rank?.userAvatar.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let imageURL = URL(string: escapedString ?? "") {
            self.topUserAvatar.setImage(url: imageURL, placeholder: UIImage.init(named: "default_avatar")!)
        }
        self.topUserName.text = rank?.userName
        self.topUserBadge.text = rank?.userBadge
        
        let userPoint = rank?.userPoint == nil ? "" : (rank?.userPoint)!
        let attributedString = NSMutableAttributedString(string: userPoint + " pts", attributes: [
          .font: setFontSize(size: 14, weight: .semibold),
          .foregroundColor: UIColor(white: 136.0 / 255.0, alpha: 1.0),
          .kern: 0.28
        ])
        attributedString.addAttributes([
          .font: setFontSize(size: 14, weight: .regular),
          .kern: 0.39
        ], range: NSRange(location: userPoint.count, length: 4))
        self.topUserPoint.attributedText = attributedString
        
        self.tableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listLeaderboard.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userRankCell", for: indexPath) as! TC_UserLeaderboardCell
        
        let cellData = self.listLeaderboard[indexPath.row]
        
        let escapedString = cellData.userAvatar.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
        if let imageURL = URL(string: escapedString ?? "" ) {
            cell.userAvatar.setImage(url: imageURL, placeholder: UIImage.init(named: "default_avatar")!)
        }
        
        cell.userRank.text = String(format: "%ld", cellData.userRankIndex)
        cell.userName.text = cellData.userName
        cell.userBadge.text = cellData.userBadge
        
        let attributedString = NSMutableAttributedString(string: cellData.userPoint + " pts", attributes: [
          .font: setFontSize(size: 10, weight: .semibold),
          .foregroundColor: UIColor(white: 136.0 / 255.0, alpha: 1.0),
          .kern: 0.2
        ])
        attributedString.addAttributes([
          .font: setFontSize(size: 10, weight: .regular),
          .kern: 0.19
        ], range: NSRange(location: cellData.userPoint.count, length: 4))
        cell.userPoint.attributedText = attributedString
        
        if cellData == self.currentUserRank {
            cell.backgroundColor = UIColor.init(hexString: "ebe8ff")
        } else {
            cell.backgroundColor = .white
        }
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}
