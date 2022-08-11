//
//  VC_ForgotPassword.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/31/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

enum ActionStatus {
    case getEmail
    case getOTP
    case createPass
}

class VC_ForgotPassword: UIViewController {

    let bannerImage     = UIImageView()
    
    let getEmailView    = UIView()
    let getOTPView      = UIView()
    let createNewPass   = UIView()
    
    let emailTxt        = UITextField()
    let otpTxt          = UITextField()
    let newPasswordTxt  = UITextField()
    let confirmPassTxt  = UITextField()
    
    let actionBtn       = UIButton()
    let loadingAnimation = VW_LoadingAnimation()
    
    var actionStatus    : ActionStatus = .getEmail
    
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
        
        self.loadPasswordView()
        self.loadOTPView()
        self.loadEmailView()
        
        actionBtn.setTitle(NSLocalizedString("kNextBtn", comment: "").uppercased(), for: .normal)
        actionBtn.setTitleColor(.white, for: .normal)
        actionBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        actionBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        actionBtn.layer.cornerRadius = 20
        actionBtn.addTarget(self, action: #selector(actionButtonTapped), for: .touchUpInside)
        self.view.addSubview(actionBtn)
        actionBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
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
        
        buttonConstraint = actionBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
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
        
        buttonConstraint.constant = -10 - keyboardHeight
        
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        buttonConstraint.constant = -10
        
        let userInfo = notification.userInfo
        let animationDuration = userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        UIView.animate(withDuration: animationDuration) {
            self.view.layoutIfNeeded()
        }
    }
    
    func loadEmailView() {
        getEmailView.backgroundColor = UIColor.init(hexString: "ccffffff")
        getEmailView.layer.cornerRadius = 20
        getEmailView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        getEmailView.layer.shadowOpacity = 0.5
        getEmailView.layer.shadowOffset = CGSize(width: 2, height: 9)
        getEmailView.layer.shadowRadius = 20
        self.view.addSubview(getEmailView)
        getEmailView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(-70)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(220)
        }
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("kRecoveryPass", comment: "")
        titleLabel.font = setFontSize(size: 18, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "333333")
        getEmailView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("kRecoveryPassExplain", comment: ""))
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
        getEmailView.addSubview(explaintionLabel)
        explaintionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
        }
        
        let cornerView = UIView()
        cornerView.layer.borderWidth = 0.5
        cornerView.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerView.layer.cornerRadius = 15
        getEmailView.addSubview(cornerView)
        cornerView.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        emailTxt.placeholder = NSLocalizedString("kEmailPlaceHolder", comment: "")
        emailTxt.font = setFontSize(size: 14, weight: .regular)
        emailTxt.keyboardType = .emailAddress
        emailTxt.autocapitalizationType = .none
        getEmailView.addSubview(emailTxt)
        emailTxt.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
    }
    
    func loadOTPView() {
        getOTPView.backgroundColor = UIColor.init(hexString: "ccffffff")
        getOTPView.layer.cornerRadius = 20
        getOTPView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        getOTPView.layer.shadowOpacity = 0.5
        getOTPView.layer.shadowOffset = CGSize(width: 2, height: 9)
        getOTPView.layer.shadowRadius = 20
        self.view.addSubview(getOTPView)
        getOTPView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(-70)
            make.left.equalTo(self.view.snp.right)
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(220)
        }
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("kRecoveryPass", comment: "")
        titleLabel.font = setFontSize(size: 18, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "333333")
        getOTPView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        let explaintionLabel = UILabel()
        let attributedString = NSMutableAttributedString(string: "Your text")
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 6 // Whatever line spacing you want in points
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attributedString.length))
        
        explaintionLabel.attributedText = attributedString
        explaintionLabel.numberOfLines = 0
        explaintionLabel.textAlignment = .center
        explaintionLabel.text = NSLocalizedString("kRequestOTPExplain", comment: "")
        explaintionLabel.font = setFontSize(size: 14, weight: .regular)
        explaintionLabel.textColor = UIColor.init(hexString: "666666")
        getOTPView.addSubview(explaintionLabel)
        explaintionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
        }
        
        let cornerView = UIView()
        cornerView.layer.borderWidth = 0.5
        cornerView.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerView.layer.cornerRadius = 15
        getOTPView.addSubview(cornerView)
        cornerView.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        otpTxt.placeholder = NSLocalizedString("kOTPPlaceHolder", comment: "")
        otpTxt.font = setFontSize(size: 14, weight: .regular)
        getOTPView.addSubview(otpTxt)
        otpTxt.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(22)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
    }
    
    func loadPasswordView() {
        createNewPass.backgroundColor = UIColor.init(hexString: "ccffffff")
        createNewPass.layer.cornerRadius = 20
        createNewPass.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        createNewPass.layer.shadowOpacity = 0.5
        createNewPass.layer.shadowOffset = CGSize(width: 2, height: 9)
        createNewPass.layer.shadowRadius = 20
        self.view.addSubview(createNewPass)
        createNewPass.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(-70)
            make.left.equalTo(self.view.snp.right)
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(265)
        }
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("kResetPass", comment: "")
        titleLabel.font = setFontSize(size: 18, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "333333")
        createNewPass.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        let explaintionLabel = UILabel()
        explaintionLabel.numberOfLines = 0
        explaintionLabel.textAlignment = .center
        explaintionLabel.text = NSLocalizedString("kNewPasswordExplain", comment: "")
        explaintionLabel.font = setFontSize(size: 14, weight: .regular)
        explaintionLabel.textColor = UIColor.init(hexString: "666666")
        createNewPass.addSubview(explaintionLabel)
        explaintionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
        }
        
        let cornerView2 = UIView()
        cornerView2.layer.borderWidth = 0.5
        cornerView2.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerView2.layer.cornerRadius = 15
        createNewPass.addSubview(cornerView2)
        cornerView2.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        confirmPassTxt.placeholder = NSLocalizedString("kConfirmNewPassword", comment: "")
        confirmPassTxt.font = setFontSize(size: 14, weight: .regular)
        confirmPassTxt.isSecureTextEntry = true
        cornerView2.addSubview(confirmPassTxt)
        confirmPassTxt.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
        
        let cornerView1 = UIView()
        cornerView1.layer.borderWidth = 0.5
        cornerView1.layer.borderColor = UIColor.init(hexString: "7f7f7f")?.cgColor
        cornerView1.layer.cornerRadius = 15
        createNewPass.addSubview(cornerView1)
        cornerView1.snp.makeConstraints { (make) in
            make.bottom.equalTo(cornerView2.snp.top).offset(-16)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(275)
        }
        
        newPasswordTxt.placeholder = NSLocalizedString("kNewPassword", comment: "")
        newPasswordTxt.font = setFontSize(size: 14, weight: .regular)
        newPasswordTxt.isSecureTextEntry = true
        newPasswordTxt.disableAutoFillStrongPassword()
        cornerView1.addSubview(newPasswordTxt)
        newPasswordTxt.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.equalTo(30)
            make.width.equalTo(245)
        }
    }
    
    func loadBlurView() {
        self.view.layoutIfNeeded()
        
        let blurEffect1 = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect1)
        blurEffectView1.frame = getEmailView.bounds
        blurEffectView1.layer.cornerRadius = 20
        blurEffectView1.layer.masksToBounds = true
        blurEffectView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        getEmailView.addSubview(blurEffectView1)
        getEmailView.sendSubviewToBack(blurEffectView1)
        
        let blurEffect2 = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView2 = UIVisualEffectView(effect: blurEffect2)
        blurEffectView2.frame = getOTPView.bounds
        blurEffectView2.layer.cornerRadius = 20
        blurEffectView2.layer.masksToBounds = true
        blurEffectView2.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        getOTPView.addSubview(blurEffectView2)
        getOTPView.sendSubviewToBack(blurEffectView2)
        
        let blurEffect3 = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView3 = UIVisualEffectView(effect: blurEffect3)
        blurEffectView3.frame = createNewPass.bounds
        blurEffectView3.layer.cornerRadius = 20
        blurEffectView3.layer.masksToBounds = true
        blurEffectView3.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        createNewPass.addSubview(blurEffectView3)
        createNewPass.sendSubviewToBack(blurEffectView3)
    }
    
    //MARK: -
    
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        switch actionStatus {
        case .getEmail:
            self.navigationController?.popViewController(animated: true)
            
        case .getOTP:
            self.getOTPView.snp.remakeConstraints { (make) in
                make.top.equalTo(bannerImage.snp.bottom).offset(-70)
                make.left.equalTo(self.view.snp.right)
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(220)
            }
            self.getEmailView.snp.remakeConstraints { (make) in
                make.top.equalTo(self.bannerImage.snp.bottom).offset(-70)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(220)
            }
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            },
                           completion: nil)
            actionStatus = .getEmail
            
        case .createPass:
            self.createNewPass.snp.remakeConstraints { (make) in
                make.top.equalTo(bannerImage.snp.bottom).offset(-70)
                make.left.equalTo(self.view.snp.right)
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(265)
            }
            self.getOTPView.snp.remakeConstraints { (make) in
                make.height.equalTo(220)
                make.top.equalTo(bannerImage.snp.bottom).offset(-70)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(220)
            }
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            },
                           completion: nil)
            actionStatus = .getOTP
        }
    }
    
    @objc func actionButtonTapped() {
        
        switch self.actionStatus {
        case .getEmail:
            // slide getEmail View to left
            
            if self.emailTxt.text == "" {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFailedOTP", comment: ""),
                                                   message: NSLocalizedString("kErrorEmailEmpty", comment: ""))
                return
            }
            
            if !(self.emailTxt.isValidEmail()) {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFailedOTP", comment: ""),
                                                   message: NSLocalizedString("kErrorEmailInvalid", comment: ""))
                return
            }
            
            loadingAnimation.isHidden = false
            _AppDataHandler.forgotPasswordByEmail(email: emailTxt.text!) { (isSuccess, error) in
                
                self.loadingAnimation.isHidden = true
                if isSuccess {
                    self.getEmailView.snp.remakeConstraints { (make) in
                        make.top.equalTo(self.bannerImage.snp.bottom).offset(-70)
                        make.right.equalTo(self.view.snp.left).offset(-10)
                        make.width.equalToSuperview().offset(-40)
                        make.height.equalTo(220)
                    }
                    
                    self.getOTPView.snp.remakeConstraints { (make) in
                        make.top.equalTo(self.bannerImage.snp.bottom).offset(-70)
                        make.centerX.equalToSuperview()
                        make.width.equalToSuperview().offset(-40)
                        make.height.equalTo(220)
                    }
                    
                    UIView.animate(withDuration: 0.3,
                                   delay: 0,
                                   options: UIView.AnimationOptions.curveEaseOut,
                                   animations: {
                                    self.view.layoutIfNeeded()
                    },
                                   completion: nil)
                    
                    self.actionStatus = .getOTP
                } else {
                    self.emailTxt.text = ""
                    _NavController.presentAlertForCase(title: NSLocalizedString("kFailedOTP", comment: ""),
                                                       message: error)
                    return
                }
            }
            
            break
        case .getOTP:
            
            if (otpTxt.text == "") {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFailRecoveryTitle", comment: ""),
                                                   message: NSLocalizedString("kRequestOTPWarnings", comment: ""))
                return
            }
            
            getOTPView.snp.remakeConstraints { (make) in
                make.top.equalTo(bannerImage.snp.bottom).offset(-70)
                make.right.equalTo(self.view.snp.left).offset(-10)
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(220)
            }
            
            createNewPass.snp.remakeConstraints { (make) in
                make.top.equalTo(bannerImage.snp.bottom).offset(-70)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(265)
            }
            
            actionBtn.setTitle(NSLocalizedString("kConfirmBtn", comment: "").uppercased(), for: .normal)
            
            UIView.animate(withDuration: 0.3,
                           delay: 0,
                           options: UIView.AnimationOptions.curveEaseOut,
                           animations: {
                            self.view.layoutIfNeeded()
            },
                           completion: nil)
            
            self.actionStatus = .createPass
            
            break
        case .createPass:
            
            if (newPasswordTxt.text == "") {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFailPasswordReset", comment: ""),
                                                   message: NSLocalizedString("kPasswordEmpty", comment: ""))
                return
            }
            
            if !(newPasswordTxt.text == confirmPassTxt.text) {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFailPasswordReset", comment: ""),
                                                   message: NSLocalizedString("kPasswordDoNotMatch", comment: ""))
                return
            }
            
            let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&.])(?=.*[A-Z]).{8,16}$")
            
            if !(password.evaluate(with: newPasswordTxt.text)) {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFailPasswordReset", comment: ""),
                                                   message: NSLocalizedString("kPasswordFormatWarning", comment: ""))
                return
            }
            
            self.loadingAnimation.isHidden = false
            _AppDataHandler.forgotPassword(OTPcode: self.otpTxt.text!,
                                           password: self.newPasswordTxt.text!, email: self.emailTxt.text!)
            { (isSuccess, error) in
                self.loadingAnimation.isHidden = true
                
                if isSuccess {
                    self.getEmailView.isHidden = true
                    self.getOTPView.isHidden = true
                    
                    let alertVC = UIAlertController.init(title: NSLocalizedString("kChangePasswordSucessTitle", comment: ""),
                                                         message: NSLocalizedString("kChangePasswordSucessMessage", comment: ""),
                                                         preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                      style: .default) { (action) in
                                                        alertVC.dismiss(animated: true, completion: nil)
                                                        self.navigationController?.popToRootViewController(animated: true)
                                                        
                    }
                    
                    alertVC.addAction(okAction)
                    self.present(alertVC, animated: true, completion: nil)
                    
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                    return
                }
                
            }
            break
        }
    }
}
