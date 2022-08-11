//
//  CC_ChipSelectionCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/15/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class ChipSelectionFlowLayout: UICollectionViewFlowLayout {
    
    let cellSpacing:CGFloat = 4
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        self.minimumLineSpacing = 4.0
        self.sectionInset = UIEdgeInsets(top: 10, left: 8, bottom: 10, right: 6)
        let attributes = super.layoutAttributesForElements(in: rect)
        
        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }
            layoutAttribute.frame.origin.x = leftMargin
            leftMargin += layoutAttribute.frame.width + cellSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }
        return attributes
    }
}

class CC_ChipSelectionCell: UICollectionViewCell {
    
    var layoutView          = UIView()
    var selectOption        = UILabel()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        layoutView.backgroundColor = .white
        
        layoutView.backgroundColor = UIColor.init(hexString: "ccffffff")
        layoutView.layer.cornerRadius = 17
        layoutView.layer.shadowColor = UIColor.init(hexString: "222d00ff")!.cgColor
        layoutView.layer.shadowOpacity = 0.9
        layoutView.layer.shadowOffset = CGSize(width: 2, height: 9)
        layoutView.layer.shadowRadius = 20
        layoutView.backgroundColor = .white
        self.addSubview(layoutView)
        layoutView.snp.makeConstraints { (make) in
            make.top.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-12)
            make.bottom.equalToSuperview().offset(-12)
        }
                
        selectOption.textAlignment = .center
        selectOption.font = setFontSize(size: 14, weight: .regular)
        selectOption.textColor = UIColor.init(hexString: "929292")
        layoutView.addSubview(selectOption)
        selectOption.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
        
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
