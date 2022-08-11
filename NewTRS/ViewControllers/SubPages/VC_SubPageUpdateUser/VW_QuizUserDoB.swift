//
//  VW_QuizUserDoB.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/1/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_QuizUserDoBDelegate {
    func didSelectDate(unixTime: Int)
}

class VW_QuizUserDoB: UIView {
    
    let dateOfBirthTxt      = UITextField()
    let datePicker          = UIDatePicker()
    
    let doneBtn             = UIButton()
    
    var delegate            : VW_QuizUserDoBDelegate?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let questionLabel = UILabel()
        questionLabel.text = NSLocalizedString("kQuizAskUserDOB", comment: "")
        questionLabel.font = setFontSize(size: 27, weight: .bold)//HurmeGeometricSans2 
        questionLabel.textAlignment = .center
        questionLabel.textColor = .white
        questionLabel.numberOfLines = 0
        self.addSubview(questionLabel)
        questionLabel.snp.makeConstraints { (make) in
            make.centerX.top.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        dateOfBirthTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("kDOBPlaceHolder", comment: ""),
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "b5b5b5")!,
                                                                             NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)])
        dateOfBirthTxt.textColor = .white
        dateOfBirthTxt.returnKeyType = .next
        dateOfBirthTxt.inputView = datePicker
        self.addSubview(dateOfBirthTxt)
        dateOfBirthTxt.snp.makeConstraints { (make) in
            make.top.equalTo(questionLabel.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-80)
        }
        
        let firstLine = UIView()
        firstLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.addSubview(firstLine)
        firstLine.snp.makeConstraints { (make) in
            make.width.centerX.bottom.equalTo(dateOfBirthTxt)
            make.height.equalTo(1)
        }
        
        self.addDoneButtonOnKeyboard()
        
        doneBtn.setTitle(NSLocalizedString("kDoneBtn", comment: "").uppercased(), for: .normal)
        doneBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        doneBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        doneBtn.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        doneBtn.layer.cornerRadius = 20
        self.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.top.equalTo(firstLine.snp.bottom).offset(30)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.bottom.equalToSuperview()
        }
        
        let userProfile = _AppDataHandler.getUserProfile()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if userProfile.dob > 0 {
            dateOfBirthTxt.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(userProfile.dob)))
            datePicker.date = Date(timeIntervalSince1970: TimeInterval(userProfile.dob))
        } else {
            datePicker.date = Date()
        }
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action:#selector(doneButtonAction))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

        self.dateOfBirthTxt.inputAccessoryView = doneToolbar
    }
    
    //MARK: - Buttons
    @objc func doneButtonTapped() {
        
        let currentDateValue = Int(Date().timeIntervalSince1970)
        let datePickerValue = Int(datePicker.date.timeIntervalSince1970)
        
        if (currentDateValue - datePickerValue) >= 409968000 {
            //13 years
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dateOfBirthTxt.text = dateFormatter.string(from: datePicker.date)
            delegate?.didSelectDate(unixTime: Int(datePicker.date.timeIntervalSince1970))
            
        } else {
            _NavController.presentAlertForCase(title: NSLocalizedString("kOopTitle", comment: ""),
                                               message: NSLocalizedString("kUnder13YsMessage", comment: ""))
        }
    }
    
    @objc func doneButtonAction() {
        
        self.endEditing(true)
        
        let currentDateValue = Int(Date().timeIntervalSince1970)
        let datePickerValue = Int(datePicker.date.timeIntervalSince1970)
        
        if (currentDateValue - datePickerValue) >= 409968000 {
            //13 years
            
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "MM/dd/yyyy"
            dateOfBirthTxt.text = dateFormatter.string(from: datePicker.date)
            self.endEditing(true)
        } else {
            _NavController.presentAlertForCase(title: NSLocalizedString("kOopTitle", comment: ""),
                                               message: NSLocalizedString("kUnder13YsMessage", comment: ""))
        }
    }
}
