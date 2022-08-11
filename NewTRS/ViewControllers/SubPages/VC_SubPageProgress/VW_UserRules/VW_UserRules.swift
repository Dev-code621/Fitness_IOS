//
//  VW_UserLeaderBoardRun.swift
//  NewTRS
//
//  Created by Phuong Duy on 9/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_UserRules: UIView {
    
    var delegate        : VC_SubPageProgress?
    let nodataView      = UIView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        nodataView.backgroundColor = UIColor.init(hexString: "fafafa")
        self.addSubview(nodataView)
        nodataView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.size.equalToSuperview()
        }
        
        let nodataMessage = UILabel()
        nodataMessage.text = NSLocalizedString("kUserRulesNoData", comment: "")
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
        nodataTitle.text = NSLocalizedString("kUserRulesNoDataTitle", comment: "")
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
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Actions
    
    //MARK: - UITableViewDataSource
    
    //MARK: - UITableViewDelegate
}
