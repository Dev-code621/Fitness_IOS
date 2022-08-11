//
//  VC_UserUpdateProfile.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/2/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol VW_UserUpdateProfileDelegate {
    func didCloseUpdateView()
    func didUpdateUserProfile(newUserProfile: UserProfileDataSource)
}

class VW_UserUpdateProfile: UIView, UITextFieldDelegate {
    
    var delegate            : VC_SubPageUserProfile?
    let contentView         = UIView()
    
    let firstNameTxt        = UITextField()
    let lastNameTxt         = UITextField()
    let dobTxt              = UITextField()
    
    let datePicker          = UIDatePicker()
    
    let cancelBtn           = UIButton()
    let saveBtn             = UIButton()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .clear
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.4
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let dismissKeyboard = UITapGestureRecognizer.init(target: self, action: #selector(cancelButtonTapped))
        opacityView.addGestureRecognizer(dismissKeyboard)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30
        self.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.centerY.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(370)
            make.width.equalTo(335)
        }
        
        let editProfileTitle = UILabel()
        editProfileTitle.text = NSLocalizedString("kEditProfileTitle", comment: "")
        editProfileTitle.textAlignment = .center
        editProfileTitle.textColor = UIColor.init(hexString: "333333")
        editProfileTitle.font = setFontSize(size: 18, weight: .bold)
        contentView.addSubview(editProfileTitle)
        editProfileTitle.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
            make.top.equalToSuperview().offset(50)
        }
        
        let editContentMessageLabel = UILabel()
        editContentMessageLabel.text = NSLocalizedString("kEditProfileMessage", comment: "")
        editContentMessageLabel.font = setFontSize(size: 14, weight: .regular)
        editContentMessageLabel.textColor = UIColor.init(hexString: "666666")
        editContentMessageLabel.textAlignment = .center
        contentView.addSubview(editContentMessageLabel)
        editContentMessageLabel.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(editProfileTitle.snp.bottom).offset(10)
        }
        
        let firstNameLine = UIView()
        firstNameLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        firstNameLine.layer.opacity = 0.4
        contentView.addSubview(firstNameLine)
        firstNameLine.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-70)
            make.centerX.equalToSuperview()
            make.top.equalTo(editContentMessageLabel.snp.bottom).offset(54)
            make.height.equalTo(1)
        }
        
        firstNameTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("kFirstNamePlaceHolder", comment: ""),
                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "888888")!,
                                                                             NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)])
        firstNameTxt.textColor = .black
        firstNameTxt.returnKeyType = .next
        firstNameTxt.delegate = self
        contentView.addSubview(firstNameTxt)
        firstNameTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(firstNameLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-70)
        }
        
        let lastNameLine = UIView()
        lastNameLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        lastNameLine.layer.opacity = 0.4
        contentView.addSubview(lastNameLine)
        lastNameLine.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-70)
            make.centerX.equalToSuperview()
            make.top.equalTo(firstNameLine).offset(54)
            make.height.equalTo(1)
        }
        
        lastNameTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("kLastNamePlaceHolder", comment: ""),
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "888888")!,
                                                                            NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)])
        lastNameTxt.textColor = .black
        lastNameTxt.returnKeyType = .next
        lastNameTxt.delegate = self
        contentView.addSubview(lastNameTxt)
        lastNameTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(lastNameLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-70)
        }
        
        let dobLine = UIView()
        dobLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        dobLine.layer.opacity = 0.4
        contentView.addSubview(dobLine)
        dobLine.snp.makeConstraints { (make) in
            make.width.equalToSuperview().offset(-70)
            make.centerX.equalToSuperview()
            make.top.equalTo(lastNameLine).offset(54)
            make.height.equalTo(1)
        }
        
        datePicker.addTarget(self, action: #selector(dateChanged(_:)), for: .valueChanged)
        datePicker.datePickerMode = .date
        datePicker.maximumDate = Calendar.current.date(byAdding: .month, value: 11, to: Date())
        if #available(iOS 14, *) {
            datePicker.preferredDatePickerStyle = .wheels
            datePicker.sizeToFit()
        }
        dobTxt.attributedPlaceholder = NSAttributedString(string: NSLocalizedString("kDOBPlaceHolder", comment: ""),
                                                               attributes: [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "888888")!,
                                                                            NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)])
        dobTxt.textColor = .black
        dobTxt.inputView = datePicker
        dobTxt.delegate = self
        contentView.addSubview(dobTxt)
        dobTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(dobLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-70)
        }
        
        cancelBtn.setTitle(NSLocalizedString("kCancelAction", comment: ""), for: .normal)
        cancelBtn.setTitleColor(UIColor.init(hexString: "ff5555"), for: .normal)
        cancelBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        cancelBtn.layer.borderColor = UIColor.init(hexString: "ff5555")!.cgColor
        cancelBtn.layer.borderWidth = 1
        cancelBtn.layer.cornerRadius = 20
        cancelBtn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        contentView.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.left.equalToSuperview().offset(35.5)
            make.height.equalTo(40)
            make.right.equalTo(contentView.snp.centerX).offset(-10)
        }
        
        saveBtn.setTitle(NSLocalizedString("kSaveBtn", comment: ""), for: .normal)
        saveBtn.setTitleColor(.white, for: .normal)
        saveBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        saveBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        saveBtn.layer.cornerRadius = 20
        saveBtn.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        contentView.addSubview(saveBtn)
        saveBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.right.equalToSuperview().offset(-35.5)
            make.height.equalTo(40)
            make.left.equalTo(contentView.snp.centerX).offset(10)
        }
        
        self.addDoneButtonOnKeyboard()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI/UX
    
    func addDoneButtonOnKeyboard()
    {
        let doneToolbar: UIToolbar = UIToolbar(frame: CGRect.init(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 50))
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action:#selector(doneKeyboardTapped))
        
        let items = [flexSpace, done]
        doneToolbar.items = items
        doneToolbar.sizeToFit()

//        self.firstNameTxt.inputAccessoryView = doneToolbar
//        self.lastNameTxt.inputAccessoryView = doneToolbar
        self.dobTxt.inputAccessoryView = doneToolbar
    }
    
    @objc func doneKeyboardTapped() {
        self.endEditing(true)
        
        let currentDateValue = Int(Date().timeIntervalSince1970)
        let datePickerValue = Int(datePicker.date.timeIntervalSince1970)
        
        if (currentDateValue - datePickerValue) <= 409968000 {
            //13 years
            _NavController.presentAlertForCase(title: NSLocalizedString("kOopTitle", comment: ""),
                                               message: NSLocalizedString("kUnder13YsMessage", comment: ""))
        }
    }
    
    @objc func cancelButtonTapped() {
        self.endEditing(true)
        self.closeViewAnimation()
    }
    
    @objc func saveButtonTapped() {
        
        if firstNameTxt.text == "" ||
            lastNameTxt.text == "" {
            
            _NavController.presentAlertForCase(title: "Edit Profile",
                                                         message: "First name, or last name can not be empty")
            return
        }
        
        let currentDateValue = Int(Date().timeIntervalSince1970)
        let datePickerValue = Int(datePicker.date.timeIntervalSince1970)
        
        if (currentDateValue - datePickerValue) <= 409968000 {
            //13 years old
            _NavController.presentAlertForCase(title: NSLocalizedString("kOopTitle", comment: ""),
                                               message: NSLocalizedString("kUnder13YsMessage", comment: ""))
            return
        }
        
        self.cancelButtonTapped()
        
        let userProfile = _AppDataHandler.getUserProfile()
        userProfile.firstName = firstNameTxt.text
        userProfile.lastName  = lastNameTxt.text
        
        userProfile.dob = Int(self.datePicker.date.timeIntervalSince1970)
        
        if delegate != nil {
            delegate?.didUpdateUserProfile(newUserProfile: userProfile)
        }
    }
    
    @objc func closeViewAnimation() {
        
        self.endEditing(true)
        
        if delegate != nil {
            delegate?.didCloseUpdateView()
        }
    }
    
    //MARK: - Data
    
    func reloadData() {
        let userProfile = _AppDataHandler.getUserProfile()
        self.firstNameTxt.text = userProfile.firstName
        self.lastNameTxt.text = userProfile.lastName
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        
        if userProfile.dob > 0 {
            dobTxt.text = dateFormatter.string(from: Date(timeIntervalSince1970: TimeInterval(userProfile.dob)))
            datePicker.date = Date(timeIntervalSince1970: TimeInterval(userProfile.dob))
        } else {
            datePicker.date = Date()
        }
    }
    
    //MARK: - UIDatePicker
    @objc func dateChanged(_ sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy"
        dobTxt.text = dateFormatter.string(from: sender.date)
    }
    
    //MARK: - UITextFieldDelegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == firstNameTxt {
            textField.resignFirstResponder()
            lastNameTxt.becomeFirstResponder()
        } else if textField == lastNameTxt {
            textField.resignFirstResponder()
            dobTxt.becomeFirstResponder()
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
