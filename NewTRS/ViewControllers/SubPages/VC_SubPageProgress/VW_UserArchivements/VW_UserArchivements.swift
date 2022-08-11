//
//  VW_UserArchivements.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_UserArchivements: UIView,
                            UICollectionViewDataSource, UICollectionViewDelegate,
                            UICollectionViewDelegateFlowLayout {
    
    var delegate        : VC_SubPageProgress?
    
    let backgroundImage            = UIImageView()
    let nextStreaksCircle          = VW_StreaksCircle()
    let nextStreaksTitle           = UILabel()
    let nextStreaksDescription     = UILabel()
    
    var userRankPoints      : [UserArchivementDataSource] = []
    var collectionView      : UICollectionView?
    let nodataView          = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.layer.masksToBounds = true
        backgroundImage.layer.opacity = 0.2
        backgroundImage.contentMode = .scaleAspectFit
        self.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview().multipliedBy(1.5)
        }
        
        self.addSubview(nextStreaksCircle)
        nextStreaksCircle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(140)
        }
        
        nextStreaksTitle.textAlignment = .center
        nextStreaksTitle.textColor = UIColor.init(hexString: "2d00ff")
        nextStreaksTitle.font = setFontSize(size: 14, weight: .semibold)
        self.addSubview(nextStreaksTitle)
        nextStreaksTitle.snp.makeConstraints { (make) in
            make.top.equalTo(nextStreaksCircle.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        nextStreaksDescription.textAlignment = .center
        nextStreaksDescription.numberOfLines = 0
        nextStreaksDescription.textColor = UIColor.init(hexString: "666666")
        nextStreaksDescription.font = setFontSize(size: 14, weight: .regular)
        self.addSubview(nextStreaksDescription)
        nextStreaksDescription.snp.makeConstraints { (make) in
            make.top.equalTo(nextStreaksTitle.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-100)
        }
        
        let layout = UICollectionViewFlowLayout()
        
        self.collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        self.collectionView?.register(CC_UserArchivermentCell.self, forCellWithReuseIdentifier: "userArchivermentCell")
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = UIColor.clear
        self.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.bottom.centerX.width.equalToSuperview()
            make.top.equalTo(nextStreaksDescription.snp.bottom).offset(30)
        })
        
        nodataView.isHidden = true
        nodataView.backgroundColor = UIColor.init(hexString: "fafafa")
        self.addSubview(nodataView)
        nodataView.snp.makeConstraints { (make) in
            make.bottom.centerX.width.equalToSuperview()
            make.top.equalToSuperview()
        }
        
        let nodataMessage = UILabel()
        nodataMessage.text = NSLocalizedString("kUserArchivementNoData", comment: "")
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
        nodataTitle.text = NSLocalizedString("kUserStreaksNoDataTitle", comment: "")
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
    
    //MARK: - Buttons
    @objc private func okButtonTapped() {
        if delegate != nil {
            delegate?.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Data
    func setDataSource(userArchevement: [UserArchivementDataSource], gotUnlocked: Bool, point: Int, nextRankImageURL: String, nextRankPoint: Int) {
        self.userRankPoints = userArchevement
        self.nextStreaksTitle.text = NSLocalizedString("kUserStreaksPointDay", comment: "").replacingOccurrences(of: "%@", with: String(point))
        self.nextStreaksDescription.text = NSLocalizedString("kUserStreaksPointDayDesc", comment: "").replacingOccurrences(of: "%@", with: String(nextRankPoint))
        
        collectionView?.reloadData()

        if let url = URL(string: nextRankImageURL) {
            backgroundImage.setImage(url: url, placeholder: UIImage())
        }
        nextStreaksCircle.setData(imageURL: nextRankImageURL, value: point, maxValue: nextRankPoint)
        
       // self.nodataView.isHidden = !(point <= 0 && !gotUnlocked)
    }
    
    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return userRankPoints.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "userArchivermentCell", for: indexPath) as! CC_UserArchivermentCell
        
        let cellData = userRankPoints[indexPath.row]
        
        cell.streaksName.text = cellData.achievementTitle
        
        if cellData.achievementIsActive {
            if let thumbnailURL = URL(string: cellData.achievementActiveImage) {
                cell.streaksImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_archiverment_image")!)
            }
            cell.dayToNextStreak.text  = "Unlocked"
            
        } else if let thumbnailURL = URL(string: cellData.achievementInactiveImage) {
            cell.streaksImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_archiverment_image")!)
            cell.dayToNextStreak.text  = "\(cellData.achievementMilestone)-day streak"

        }
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (self.frame.size.width)/3 - 10
        return CGSize(width: width, height: width)
    }
    
}
