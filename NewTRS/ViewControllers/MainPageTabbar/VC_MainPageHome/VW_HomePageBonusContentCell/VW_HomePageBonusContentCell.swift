//
//  VW_HomePageBonusContentCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/31/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol HomePageBonusContentCellDelegate {
    func didSelectCell(bonusData: SystemBonusDataSource)
}

class VW_HomePageBonusContentCell: UIView {
    
    var delegate                : HomePageBonusContentCellDelegate?
    
    private let thumbnailImage  = UIImageView()
    private let titleLabel      = UILabel()
    
    private var dataSource      : SystemBonusDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.masksToBounds = true
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.4
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        titleLabel.font = setFontSize(size: 14, weight: .bold)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        titleLabel.textColor = .white
        self.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(didSelectCell))
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Data
    func setDataSource(_ bonusContent: SystemBonusDataSource) {
        
        self.dataSource = bonusContent
        
        self.titleLabel.text = bonusContent.bonusTitle
        
        if let thumbnailURL = URL(string: bonusContent.bonusImage) {
            self.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
    }
    
    @objc func didSelectCell() {
        if delegate != nil && self.dataSource != nil {
            delegate?.didSelectCell(bonusData: self.dataSource!)
        }
    }
}
