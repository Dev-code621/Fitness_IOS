//
//  VC_UserChangePass.swift
//  NewTRS
//
//  Created by yaya on 25/03/2021.
//  Copyright © 2021 Luu Lucas. All rights reserved.
//

import UIKit

class VC_UserChangePass: UIViewController {

    let bannerImage     = UIImageView()
    
    private let getChangePassView    = UIView()
    private let oldPasswordTxt        = UITextField()
    private let newPasswordTxt        = UITextField()
    private let confirmPassTxt        = UITextField()
    
    let actionBtn                     = UIButton()
    let loadingAnimation              = VW_LoadingAnimation()
        
    var buttonConstraint    : NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyBoard))
        self.view.addGestureRecognizer(singleTap)

        bannerImage.image = UIImage.init(named: "head_banner")
        bannerImage.layer.cornerRadius = 30
        bannerImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.432)
        }
        
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage.init(named: "back_white_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(35)
            make.height.width.equalTo(30)
        }
        
        self.loadChangePassView()
        
        actionBtn.setTitle(NSLocalizedString("kUserChangePassBtn", comment: "").uppercased(), for: .normal)
        actionBtn.setTitleColor(.white, for: .normal)
        actionBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        actionBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        actionBtn.layer.cornerRadius = 20
        actionBtn.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        self.view.addSubview(actionBtn)
        actionBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        self.loadBlurView()
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        buttonConstraint = actionBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40)
                buttonConstraint.isActive = true
        self.subscribeToShowKeyboardNotifications()
    }
    
    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - UX Functions
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = notification.userInfo
        let keyboardSize = userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue
        let keyboardHeight = keyboardSize.cgRectValue.height
        
        buttonConstraint.constant = 30 - keyboardHeight
        
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        buttonConstraint.constant = -1
        
        let userInfo = notification.userInfo
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func loadChangePassView() {
        getChangePassView.backgroundColor = UIColor.init(hexString: "ccffffff")
        getChangePassView.layer.cornerRadius = 20
        getChangePassView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        getChangePassView.layer.shadowOpacity = 0.5
        getChangePassView.layer.shadowOffset = CGSize(width: 2, height: 9)
        getChangePassView.layer.shadowRadius = 20
        self.view.addSubview(getChangePassView)
        getChangePassView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(-70)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(285)
        }
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("kUserChangePassTitle", comment: "")
        titleLabel.font = setFontSize(size: 18, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "333333")
        getChangePassView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("kUserChangePassMessage", comment: ""))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle,
                                      range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.font, value:setFontSize(size: 14, weight: .regular),
                                      range:NSMakeRange(0, attributedString.length))
        attributedString.addAttribute(NSAttributedString.Key.foregroundColor, value:UIColor.init(hexString: "666666")!,
                                      range:NSMakeRange(0, attributedString.length))
        
        let explaintionLabel = UILabel()
        explaintionLabel.attributedText = attributedString
        explaintionLabel.numberOfLines = 0
        explaintionLabel.textAlignment = .center
        getChangePassView.addSubview(explaintionLabel)
        explaintionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
        }
        
        let cornerView = UIView()
        cornerView.layer.borderWidth = 0.5
        cornerView.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerView.layer.cornerRadius = 15
        getChangePassView.addSubview(cornerView)
        cornerView.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        let cornerViewNew = UIView()
        cornerViewNew.layer.borderWidth = 0.5
        cornerViewNew.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerViewNew.layer.cornerRadius = 15
        getChangePassView.addSubview(cornerViewNew)
        cornerViewNew.snp.makeConstraints { (make) in
            make.top.equalTo(cornerView.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        let cornerViewConfirm = UIView()
        cornerViewConfirm.layer.borderWidth = 0.5
        cornerViewConfirm.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerViewConfirm.layer.cornerRadius = 15
        getChangePassView.addSubview(cornerViewConfirm)
        cornerViewConfirm.snp.makeConstraints { (make) in
            make.top.equalTo(cornerViewNew.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        let showPassBtn = UIButton(type: .custom)
        showPassBtn.tag = 1
        showPassBtn.setImage(UIImage.init(named: "password_eye_icon"), for: .normal)
        showPassBtn.setImage(UIImage.init(named: "password_eye_off_icon"), for: .selected)
        showPassBtn.frame.size = CGSize(width: CGFloat(20), height: CGFloat(25))
        showPassBtn.addTarget(self, action: #selector(passwordSecurityEntryChange), for: .touchUpInside)
        
        oldPasswordTxt.placeholder = NSLocalizedString("kCurrentPasswordPlaceHolder", comment: "")
        oldPasswordTxt.font = setFontSize(size: 14, weight: .regular)
        oldPasswordTxt.isSecureTextEntry = true
        oldPasswordTxt.rightViewMode = .always
        oldPasswordTxt.rightView = showPassBtn
        getChangePassView.addSubview(oldPasswordTxt)
        oldPasswordTxt.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
        
        let showNewPassBtn = UIButton(type: .custom)
        showNewPassBtn.tag = 2
        showNewPassBtn.setImage(UIImage.init(named: "password_eye_icon"), for: .normal)
        showNewPassBtn.setImage(UIImage.init(named: "password_eye_off_icon"), for: .selected)
        showNewPassBtn.frame.size = CGSize(width: CGFloat(20), height: CGFloat(25))
        showNewPassBtn.addTarget(self, action: #selector(passwordSecurityEntryChange), for: .touchUpInside)
        
        newPasswordTxt.placeholder = NSLocalizedString("kNewPasswordPlaceHolder", comment: "")
        newPasswordTxt.font = setFontSize(size: 14, weight: .regular)
        newPasswordTxt.isSecureTextEntry = true
        newPasswordTxt.rightViewMode = .always
        newPasswordTxt.rightView = showNewPassBtn
        getChangePassView.addSubview(newPasswordTxt)
        newPasswordTxt.snp.makeConstraints { (make) in
            make.top.equalTo(oldPasswordTxt.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
        
        let showNewConfirmPassBtn = UIButton(type: .custom)
        showNewConfirmPassBtn.tag = 3
        showNewConfirmPassBtn.setImage(UIImage.init(named: "password_eye_icon"), for: .normal)
        showNewConfirmPassBtn.setImage(UIImage.init(named: "password_eye_off_icon"), for: .selected)
        showNewConfirmPassBtn.frame.size = CGSize(width: CGFloat(20), height: CGFloat(25))
        showNewConfirmPassBtn.addTarget(self, action: #selector(passwordSecurityEntryChange), for: .touchUpInside)
        
        confirmPassTxt.placeholder = NSLocalizedString("kConfirmNewPasswordPlaceHolder", comment: "")
        confirmPassTxt.font = setFontSize(size: 14, weight: .regular)
        confirmPassTxt.isSecureTextEntry = true
        confirmPassTxt.rightViewMode = .always
        confirmPassTxt.rightView = showNewConfirmPassBtn
        getChangePassView.addSubview(confirmPassTxt)
        confirmPassTxt.snp.makeConstraints { (make) in
            make.top.equalTo(newPasswordTxt.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
    }
    
    func loadBlurView() {
        self.view.layoutIfNeeded()
        
        let blurEffect1 = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
        blurEffectView1.frame = getChangePassView.bounds
        blurEffectView1.layer.cornerRadius = 20
        blurEffectView1.layer.masksToBounds = true
        blurEffectView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        getChangePassView.addSubview(blurEffectView1)
        getChangePassView.sendSubviewToBack(blurEffectView1)
        
    }
    
    //MARK: -
    
    @objc func passwordSecurityEntryChange(sender: UIButton) {
        switch sender.tag {
        case 1:
            oldPasswordTxt.isSecureTextEntry = !oldPasswordTxt.isSecureTextEntry
            if oldPasswordTxt.rightView is UIButton {
                let btn = oldPasswordTxt.rightView as! UIButton
                btn.isSelected = !btn.isSelected
            }
            break
        case 2:
            newPasswordTxt.isSecureTextEntry = !newPasswordTxt.isSecureTextEntry
            if newPasswordTxt.rightView is UIButton {
                let btn = newPasswordTxt.rightView as! UIButton
                btn.isSelected = !btn.isSelected
            }
            break
        case 3:
            confirmPassTxt.isSecureTextEntry = !confirmPassTxt.isSecureTextEntry
            if confirmPassTxt.rightView is UIButton {
                let btn = confirmPassTxt.rightView as! UIButton
                btn.isSelected = !btn.isSelected
            }
            break
        default:
            break
        }
    }
    
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func actionButtonTapped() {
        if oldPasswordTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kChangePasswordSucessTitle", comment: ""),
                                               message: NSLocalizedString("kErrorPasswordEmpty", comment: ""))
            return
        }
        
        if newPasswordTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kChangePasswordSucessTitle", comment: ""),
                                               message: NSLocalizedString("kPasswordNewEmptyMessage", comment: ""))
            return
        }
        
        if confirmPassTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kChangePasswordSucessTitle", comment: ""),
                                               message: NSLocalizedString("kPasswordConfirmEmptyMessage", comment: ""))
            return
        }
        
        if newPasswordTxt.text != confirmPassTxt.text  {
            _NavController.presentAlertForCase(title: NSLocalizedString("kChangePasswordSucessTitle", comment: ""),
                                               message: NSLocalizedString("kPasswordConfirmMatchMessage", comment: ""))
            return
        }
        let password = oldPasswordTxt.text ?? ""
        let newPassword = newPasswordTxt.text ?? ""
        let confirmPass = confirmPassTxt.text ?? ""
        self.loadingAnimation.isHidden = false

        let _ =  _AppDataHandler.changePassword(password: password,
                                                newPassword: newPassword, confirmPassword: confirmPass)
        { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                let alertVC = UIAlertController.init(title: NSLocalizedString("kChangePasswordSucessTitle", comment: ""),
                                                     message: NSLocalizedString("kChangePasswordSucessMessage", comment: ""),
                                                     preferredStyle: .alert)
                let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                  style: .default) { (action) in
                    alertVC.dismiss(animated: true, completion: nil)
                    _AppDataHandler.signout()
                    _NavController.dismiss(animated: true, completion: nil)
                    _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
                }
                
                alertVC.addAction(okAction)
                self.present(alertVC, animated: true, completion: nil)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: error )
            }
        }
    }
}

