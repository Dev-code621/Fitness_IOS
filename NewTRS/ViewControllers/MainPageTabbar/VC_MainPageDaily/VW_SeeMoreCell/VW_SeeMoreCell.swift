//
//  VW_SeeMoreCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/16/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_SeeMoreCellDelegate {
    func didSelectSeeMore()
}

class VW_SeeMoreCell: UIView {
    
    var delegate        : VW_SeeMoreCellDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = UIColor.init(hexString: "718cfe")
        
        let seeMoreLabel = UILabel()
        seeMoreLabel.text = NSLocalizedString("kSeeMore", comment: "")
        seeMoreLabel.font = setFontSize(size: 14, weight: .semibold)
        seeMoreLabel.textColor = .white
        seeMoreLabel.textAlignment = .center
        self.addSubview(seeMoreLabel)
        seeMoreLabel.snp.makeConstraints { (make) in
            make.center.width.equalToSuperview()
        }
        
        let button = UIButton()
        button.addTarget(self, action: #selector(didSelectSeeMoreButton), for: .touchUpInside)
        self.addSubview(button)
        button.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didSelectSeeMoreButton() {
        if delegate != nil {
            delegate?.didSelectSeeMore()
        }
    }
    
}
