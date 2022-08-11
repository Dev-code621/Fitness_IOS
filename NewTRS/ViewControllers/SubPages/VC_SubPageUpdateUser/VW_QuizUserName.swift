//
//  VW_QuizUserName.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/1/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_QuizUserNameDelegate {
    func didEnterUserName(firstName: String, lastName: String)
}

class VW_QuizUserName: UIView, UITextFieldDelegate {
    
    let firstNameTxt    = UITextField()
    let lastNameTxt     = UITextField()
    
    let doneBtn         = UIButton()
    
    var delegate        : VW_QuizUserNameDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let questionLabel = UILabel()
        questionLabel.text = NSLocalizedString("kQuizAskAboutYou", comment: "")
        questionLabel.font = setFontSize(size: 27, weight: .bold)//HurmeGeometricSans2 
        questionLabel.textAlignment = .center
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        self.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }

        firstNameTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("kFirstNamePlaceHolder", comment: ""),
        attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "b5b5b5")!,
                     NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)])
        firstNameTxt.textColor = .white
        firstNameTxt.returnKeyType = .next
        firstNameTxt.delegate = self
        self.addSubview(firstNameTxt)
        firstNameTxt.snp.makeConstraints { (make) in
            make.top.equalTo(questionLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-80)
        }
        
        let firstLine = UIView()
        firstLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.addSubview(firstLine)
        firstLine.snp.makeConstraints { (make) in
            make.width.centerX.bottom.equalTo(firstNameTxt)
            make.height.equalTo(1)
        }
        
        lastNameTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("kLastNamePlaceHolder", comment: ""),
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "b5b5b5")!,
                                                                            NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)])
        lastNameTxt.textColor = .white
        lastNameTxt.returnKeyType = .done
        lastNameTxt.delegate = self
        self.addSubview(lastNameTxt)
        lastNameTxt.snp.makeConstraints { (make) in
            make.top.equalTo(firstLine.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-80)
        }
        
        let lastLine = UIView()
        lastLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.addSubview(lastLine)
        lastLine.snp.makeConstraints { (make) in
            make.width.centerX.bottom.equalTo(lastNameTxt)
            make.height.equalTo(1)
        }
        
        doneBtn.setTitle(NSLocalizedString("kDoneBtn", comment: "").uppercased(), for: .normal)
        doneBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        doneBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        doneBtn.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneBtn.layer.cornerRadius = 20
        self.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(lastLine.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
        }
        
        let userProfile = _AppDataHandler.getUserProfile()
        firstNameTxt.text = userProfile.firstName
        lastNameTxt.text = userProfile.lastName
        
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Buttons
    @objc func doneButtonTapped() {
        
        self.endEditing(true)
        
        if delegate != nil {
            delegate!.didEnterUserName(firstName: firstNameTxt.text!,
                                       lastName: lastNameTxt.text!)
        }
    }

    //MARK: - UITextFieldDelegate
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        if textField == firstNameTxt {
            textField.resignFirstResponder()
            lastNameTxt.becomeFirstResponder()
        } else if textField == lastNameTxt {
            textField.resignFirstResponder()
        }
        
        return true
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let maxLength = 30
        let currentString: NSString = textField.text! as NSString
        let newString: NSString = currentString.replacingCharacters(in: range, with: string) as NSString
        return newString.length <= maxLength
    }
}
