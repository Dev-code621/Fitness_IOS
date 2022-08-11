//
//  VW_WorkoutSportCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/31/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol WorkoutSportCellDelegate {
    func didSelectCtegories(category: CollectionType)
}

class VW_WorkoutSportCell: UIView {

    var delegate        : WorkoutSportCellDelegate?
    
    var thumbnailImage  = UIImageView()
    var categoryLabel   = UILabel()
    
    var collectionType  = CollectionType.workout
    
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
        opacityView.layer.opacity = 0.5
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        categoryLabel.font = setFontSize(size: 14, weight: .bold)
        categoryLabel.textAlignment = .center
        categoryLabel.numberOfLines = 0
        categoryLabel.textColor = .white
        self.addSubview(categoryLabel)
        categoryLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(didSelectCell))
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didSelectCell() {
        if delegate != nil {
            delegate?.didSelectCtegories(category: collectionType)
        }
    }
}
