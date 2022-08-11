//
//  VW_QuizContent.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_QuizContentDelegate {
    func didSelectAnswer(title: String, index: Int)
}

class VW_QuizSingSelectionContent: UIView {
    
    var delegate : VW_QuizContentDelegate?
    private let questionLabel   = UILabel()
    private var quizData        : [String: Any]? = nil
    private var listBtn         : [UIButton] = []

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        questionLabel.font = setFontSize(size: 27, weight: .bold)//HurmeGeometricSans2
        questionLabel.textAlignment = .center
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        self.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // Set DataSource
    func setData(data: [String: Any]) {
        
        self.quizData = data
        
        questionLabel.text = data["title"] as? String
        
        self.listBtn = []
        
        var markBtn : UIView? = nil
        var index = 0
        
        for answer in data["answers"] as! [String] {
            
            let button = UIButton()
            button.tag = index
            button.layer.cornerRadius = 30 //bo tròn
            button.layer.borderColor = UIColor.lightGray.cgColor
            button.layer.borderWidth = 2
            button.addTarget(self, action: #selector(didSelectButton), for: .touchUpInside)
            self.addSubview(button)
            self.listBtn.append(button)
            
            if (markBtn != nil) {
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(markBtn!.snp.bottom).offset(15)
                    make.width.equalToSuperview().offset(-60)
                    make.centerX.equalToSuperview()
                    make.height.equalTo(60)
                }
            }
            else {
                button.snp.makeConstraints { (make) in
                    make.top.equalTo(questionLabel.snp.bottom).offset(40)
                    make.width.equalToSuperview().offset(-60)
                    make.centerX.equalToSuperview()
                     make.height.equalTo(60)
                }
            }
            
            let titleLabel = UILabel()
            titleLabel.numberOfLines = 2
            titleLabel.textColor = .white
            titleLabel.font = setFontSize(size: 14, weight: .semibold)
            titleLabel.text = answer
            titleLabel.textAlignment = .center
            button.addSubview(titleLabel)
            titleLabel.snp.makeConstraints { (make) in
                make.center.height.equalToSuperview()
                make.width.equalToSuperview().offset(-10)
            }
            
            markBtn = button
            index = index + 1
        }
        
        if (markBtn != nil) {
            markBtn?.snp.makeConstraints({ (make) in
                make.bottom.equalToSuperview()
            })
        }        
    }
    
    // Handle action
    
    @objc func didSelectButton(button: UIButton) {
        
        for button in self.listBtn {
            button.backgroundColor = .clear
        }
        
        button.backgroundColor = UIColor.init(hexString: "333333")
        
        guard let title = self.quizData?["title"] as? String else {return}
        
        if (delegate != nil) {
            delegate?.didSelectAnswer(title: title, index: button.tag)
        }
    }
}
