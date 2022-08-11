//
//  VW_QuizUserGender.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_QuizUserGender: UIView {
    
    var delegate        : VW_QuizContentDelegate?
    let questionLabel   = UILabel()
    
    var listButtons     : [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel.text = NSLocalizedString("kQuizAskGender", comment: "")
        questionLabel.font = setFontSize(size: 27, weight: .bold)//HurmeGeometricSans2 
        questionLabel.textAlignment = .center
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        self.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        //Female
        
        let femaleBtn = UIButton()
        femaleBtn.tag = 0
        femaleBtn.layer.cornerRadius = 20
        femaleBtn.layer.borderColor = UIColor.lightGray.cgColor
        femaleBtn.layer.borderWidth = 2
        femaleBtn.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        self.addSubview(femaleBtn)
        femaleBtn.snp.makeConstraints { (make) in
            make.top.equalTo(questionLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-60)
        }
        
        listButtons.append(femaleBtn)
        
        let femaleTitle = UILabel()
        femaleTitle.text = "Female"
        femaleTitle.font = setFontSize(size: 14, weight: .semibold)
        femaleTitle.textColor = .white
        femaleBtn.addSubview(femaleTitle)
        femaleTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
          //  make.centerX.equalToSuperview().offset(7)
        }
        
//        let femaleIcon = UIImageView()
//        femaleIcon.image = UIImage.init(named: "female_icon")
//        femaleBtn.addSubview(femaleIcon)
//        femaleIcon.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(femaleTitle.snp.left).offset(-6)
//        }
        
        
        
        //Male
        let maleBtn = UIButton()
        maleBtn.tag = 1
        maleBtn.layer.cornerRadius = 20
        maleBtn.layer.borderColor = UIColor.lightGray.cgColor
        maleBtn.layer.borderWidth = 2
        maleBtn.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        self.addSubview(maleBtn)
        maleBtn.snp.makeConstraints { (make) in
            make.top.equalTo(femaleBtn.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-60)
        }
        
        listButtons.append(maleBtn)
        
        let maleTitle = UILabel()
        maleTitle.text = "Male"
        maleTitle.font = setFontSize(size: 14, weight: .semibold)
        maleTitle.textColor = .white
        maleBtn.addSubview(maleTitle)
        maleTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
           // make.centerX.equalToSuperview().offset(11)
        }
        
//        let maleIcon = UIImageView()
//        maleIcon.image = UIImage.init(named: "male_icon")
//        maleBtn.addSubview(maleIcon)
//        maleIcon.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(maleTitle.snp.left).offset(-6)
//        }
        
        
        
        //Other
        let otherBtn = UIButton()
        otherBtn.tag = 2
        otherBtn.layer.cornerRadius = 20
        otherBtn.layer.borderColor = UIColor.lightGray.cgColor
        otherBtn.layer.borderWidth = 2
        otherBtn.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        self.addSubview(otherBtn)
        otherBtn.snp.makeConstraints { (make) in
            make.top.equalTo(maleBtn.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-60)
        }
        
        listButtons.append(otherBtn)
        
        let otherTitle = UILabel()
        otherTitle.text = "Non-binary"
        otherTitle.font = setFontSize(size: 14, weight: .semibold)
        otherTitle.textColor = .white
        otherBtn.addSubview(otherTitle)
        otherTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
           // make.centerX.equalToSuperview().offset(11)
        }
        
//        let otherIcon = UIImageView()
//        otherIcon.image = UIImage.init(named: "other_icon")
//        otherBtn.addSubview(otherIcon)
//        otherIcon.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(otherTitle.snp.left).offset(-6)
//        }
        
        //prefer
        let preferBtn = UIButton()
        preferBtn.tag = 3
        preferBtn.layer.cornerRadius = 20
        preferBtn.layer.borderColor = UIColor.lightGray.cgColor
        preferBtn.layer.borderWidth = 2
        preferBtn.addTarget(self, action: #selector(didSelectButton(button:)), for: .touchUpInside)
        self.addSubview(preferBtn)
        preferBtn.snp.makeConstraints { (make) in
            make.top.equalTo(otherBtn.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-60)
            make.bottom.equalToSuperview()
        }
        
        listButtons.append(preferBtn)
        
        let preferTitle = UILabel()
        preferTitle.text = "Prefer Not To Say"
        preferTitle.font = setFontSize(size: 14, weight: .semibold)
        preferTitle.textColor = .white
        preferBtn.addSubview(preferTitle)
        preferTitle.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
           // make.centerX.equalToSuperview().offset(11)
        }
        
//        let preferIcon = UIImageView()
//        preferIcon.image = UIImage.init(named: "other_icon")
//        preferBtn.addSubview(preferIcon)
//        preferIcon.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.right.equalTo(preferTitle.snp.left).offset(-6)
//        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: Button
    @objc func didSelectButton(button: UIButton) {
        
        let title = "Gender"
        
        for button in self.listButtons {
            button.backgroundColor = .clear
        }
        
        button.backgroundColor = UIColor.init(hexString: "333333")

        
        if (delegate != nil) {
            delegate?.didSelectAnswer(title: title, index: button.tag)
        }
        
//        UIView.animate(withDuration: 0.2,
//                       delay: 0,
//                       usingSpringWithDamping: 0.2,
//                       initialSpringVelocity: 0.5,
//                       options: .curveEaseIn,
//                       animations: {
//                        animatedView.transform = CGAffineTransform(scaleX: 0.92, y: 0.92)
//        }) { (_) in
//            UIView.animate(withDuration: 0.4,
//                           delay: 0,
//                           usingSpringWithDamping: 0.2,
//                           initialSpringVelocity: 0.5,
//                           options: .curveEaseIn,
//                           animations: {
//                            animatedView.transform = CGAffineTransform(scaleX: 1, y: 1)
//            }) { (_) in
//                if (self.delegate != nil) {
//                    self.delegate?.didSelectAnswer(title: title, index: button.tag)
//                }
//            }
//        }
    }
}
