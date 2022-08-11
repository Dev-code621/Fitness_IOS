//
//  CC_SquareCategoryCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class CC_SquareCategoryCell: UICollectionViewCell {
        
    let thumbnailImage      = UIImageView()
    let categoryTitleLabel  = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        
        thumbnailImage.contentMode = .scaleAspectFill
        thumbnailImage.layer.masksToBounds = true
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.snp.width)
        }
        
        categoryTitleLabel.text = "Example Category"
        categoryTitleLabel.font = setFontSize(size: 14, weight: .semibold)
        categoryTitleLabel.textColor = UIColor.init(hexString: "ffffff")
        categoryTitleLabel.textAlignment = .center
        self.addSubview(categoryTitleLabel)
        categoryTitleLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-32)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(16)
        }
        
        self.reloadLayout()
    }
    
    func updateCategoryInfo(categoryData: CategoryDataSource) {
        
        if let imageURL = URL(string: categoryData.categoryImage) {
            self.thumbnailImage.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "default_thumbnail_image")!)
        }
        
        self.categoryTitleLabel.text = categoryData.categoryTitle
    }
    
    func reloadLayout() {
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = self.bounds
        gradientLayer.locations = [0.6, 1.0]
        self.layer.addSublayer(gradientLayer)
        
        self.bringSubviewToFront(categoryTitleLabel)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
