//
//  VW_UpsellCell.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/18/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_UpsellCell: UIView {
    
    private let productImageView    = UIImageView()
    private let productName         = UILabel()
    private var productURL          = URL.init(string: "https://www.cbidigital.com")
    private var dataSource          : UpSellDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let contentView = UIView()
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 17
        contentView.layer.shadowColor = UIColor.init(hexString: "112d00ff")!.cgColor
        contentView.layer.shadowOpacity = 0.9
        contentView.layer.shadowOffset = CGSize(width: 2, height: 9)
        contentView.layer.shadowRadius = 20
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-2.5)
            make.height.equalToSuperview().offset(-20)
        }
        
        productImageView.image = UIImage.init(named: "default_thumbnail_image")
        productImageView.contentMode = .scaleAspectFill
        productImageView.layer.masksToBounds = true
        contentView.addSubview(productImageView)
        productImageView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        productName.text = "Test Product Name"
        productName.font = setFontSize(size: 12, weight: .regular)
        productName.textColor = UIColor.init(hexString: "666666")
        productName.textAlignment = .center
        contentView.addSubview(productName)
        productName.snp.makeConstraints { (make) in
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-10)
        }
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(upsellTapped))
        self.addGestureRecognizer(singleTap)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Datas
    
    func setDataSource(upsellData: UpSellDataSource) {
        
        self.dataSource = upsellData
        
        self.productName.text = upsellData.productTitle
        self.productURL = URL.init(string: upsellData.productReferenceUrlStr)
        
        if let imageURL = URL(string: upsellData.imageThumbnailStr) {
            self.productImageView.setImage(url: imageURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
            
        }
        
    }
    
    @objc func upsellTapped() {
        
        guard let productURL = self.dataSource?.productReferenceUrlStr else {return}
        self.productURL = URL.init(string: productURL)
        UIApplication.shared.open(self.productURL!)
    }
}


