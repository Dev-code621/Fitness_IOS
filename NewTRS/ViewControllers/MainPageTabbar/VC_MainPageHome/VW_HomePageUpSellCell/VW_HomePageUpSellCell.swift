//
//  VM_HomePageUpSellCell.swift
//  NewTRS
//
//  Created by yaya on 9/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_HomePageUpSellCell: UICollectionViewCell {
    
    var viewUpSell = VW_UpsellCell()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.contentView.addSubview(viewUpSell)
        viewUpSell.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

