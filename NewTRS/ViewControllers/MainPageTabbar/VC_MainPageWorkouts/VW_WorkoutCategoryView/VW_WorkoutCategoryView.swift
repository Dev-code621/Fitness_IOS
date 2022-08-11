//
//  VW_WorkoutCategoryView.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_WorkoutCategoryViewDelegate {
    func didSelectCategory(selectedCategory: CategoryDataSource)
}

class VW_WorkoutCategoryView: UIView {
    
    var delegate            : VW_WorkoutCategoryViewDelegate?
    
    let thumbnailImage      = UIImageView()
    let categoryTitleLabel  = UILabel()
    private let topView     = UIView()
    
    var dataSource          : CategoryDataSource?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        thumbnailImage.image = UIImage.init(named: "default_thumbnail_image")
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
        
        categoryTitleLabel.text = "Air squads"
        categoryTitleLabel.numberOfLines = 0
        categoryTitleLabel.font = setFontSize(size: 14, weight: .semibold)
        categoryTitleLabel.textColor = .white
        categoryTitleLabel.textAlignment = .center
        self.addSubview(categoryTitleLabel)
        categoryTitleLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-20)
        }
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(cellTapped))
        self.addGestureRecognizer(singleTap)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
//    func reloadLayout() {
//        
//        let gradientLayer = CAGradientLayer()
//        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
//        gradientLayer.frame = self.bounds
//        gradientLayer.locations = [0.5, 1.0]
//        self.layer.addSublayer(gradientLayer)
//        
//        self.bringSubviewToFront(groupTitleLabel)
//    }
    
    func showOpacityView() {
        topView.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        topView.frame = self.frame
        self.addSubview(topView)
        topView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(userFreemium))
        self.addGestureRecognizer(singleTap)
    }
    
    //MARK: -
    func setCollectionData(data: CategoryDataSource) {
        
        self.dataSource = data
        
        if let imageURL = URL(string: data.categoryImage) {
            self.thumbnailImage.setImage(url: imageURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
        self.categoryTitleLabel.text = data.categoryTitle
    }
    
    //MARK:- Tap
    @objc func cellTapped() {
        if (delegate != nil) && (self.dataSource != nil) {
            delegate!.didSelectCategory(selectedCategory: self.dataSource!)
        }
    }
    
    @objc func userFreemium() {
        _NavController.presentAlertForFreemium()
    }
}
