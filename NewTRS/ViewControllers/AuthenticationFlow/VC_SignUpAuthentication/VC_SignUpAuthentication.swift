//
//  VC_SignUpAuthentication.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/10/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_SignUpAuthentication: UIViewController {
    
    let bannerImage     = UIImageView()
    
    let contentView     = UIView()
    let emailTxt        = TextField()
    let passwordTxt     = TextField()
    
    let signUpBtn       = UIButton()
    
    let loadingAnimation    = VW_LoadingAnimation()
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
        
        contentView.backgroundColor = UIColor.init(hexString: "ccffffff")
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 2, height: 9)
        contentView.layer.shadowRadius = 20
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(-70)
            make.centerX.equalTo(self.view.snp.centerX)
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(265)
        }
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("kSignUpBtn", comment: "")
        titleLabel.font = setFontSize(size: 18, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "333333")
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        let explaintionLabel = UILabel()
        explaintionLabel.numberOfLines = 0
        explaintionLabel.textAlignment = .center
        explaintionLabel.text = NSLocalizedString("kSignInExplaintion", comment: "")
        explaintionLabel.font = setFontSize(size: 14, weight: .regular)
        explaintionLabel.textColor = UIColor.init(hexString: "666666")
        contentView.addSubview(explaintionLabel)
        explaintionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(12)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(18)
        }
        
        let emailLine = UIView()
        emailLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.contentView.addSubview(emailLine)
        emailLine.snp.makeConstraints { (make) in
            make.top.equalTo(explaintionLabel.snp.bottom).offset(58)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(0.5)
        }
        
        emailTxt.placeholder = NSLocalizedString("kEmailPlaceHolder", comment: "")
        emailTxt.leftViewMode = .always
        emailTxt.leftView = UIImageView(image: UIImage.init(named: "email_icon"))
        emailTxt.keyboardType = .emailAddress
        emailTxt.autocapitalizationType = .none
        self.contentView.addSubview(emailTxt)
        emailTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(emailLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-60)
        }
        
        let passwordLine = UIView()
        passwordLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.contentView.addSubview(passwordLine)
        passwordLine.snp.makeConstraints { (make) in
            make.top.equalTo(emailLine.snp.bottom).offset(58.5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(0.5)
        }
        
        passwordTxt.placeholder = NSLocalizedString("kPassword", comment: "")
        passwordTxt.leftViewMode = .always
        passwordTxt.isSecureTextEntry = true
        passwordTxt.disableAutoFillStrongPassword()
        passwordTxt.leftView = UIImageView(image: UIImage.init(named: "password_icon"))
        self.contentView.addSubview(passwordTxt)
        passwordTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(passwordLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-60)
        }
        
        signUpBtn.setTitle(NSLocalizedString("kSignUpBtn", comment: "").uppercased(), for: .normal)
        signUpBtn.setTitleColor(.white, for: .normal)
        signUpBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        signUpBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        signUpBtn.layer.cornerRadius = 20
        signUpBtn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        self.view.addSubview(signUpBtn)
        signUpBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        self.view.layoutIfNeeded()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView1 = UIVisualEffectView(effect: blurEffect)
        blurEffectView1.frame = contentView.bounds
        blurEffectView1.layer.cornerRadius = 20
        blurEffectView1.layer.masksToBounds = true
        blurEffectView1.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        contentView.addSubview(blurEffectView1)
        contentView.sendSubviewToBack(blurEffectView1)
        
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        buttonConstraint = signUpBtn.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
                buttonConstraint.isActive = true
        self.subscribeToShowKeyboardNotifications()
    }

    func subscribeToShowKeyboardNotifications() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    //MARK: - Button
    
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
    
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func signUpButtonTapped() {
        
        guard let email = emailTxt.text else {
            return
        }
        
        guard let password = passwordTxt.text else {
            return
        }
        
        if emailTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                           message: NSLocalizedString("kErrorEmailEmpty", comment: ""))
            return
        }
        
        if !(self.emailTxt.isValidEmail()) {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                           message: NSLocalizedString("kErrorEmailInvalid", comment: ""))
            return
        }
        
        if passwordTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                           message: NSLocalizedString("kErrorPasswordEmpty", comment: ""))
            return
        }
        
        //KH bỏ yêu cầu password
//        if !passwordTxt.isValidPassword() {
//            _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
//                                               message: NSLocalizedString("kPasswordFormatWarning", comment: ""))
//            return
//        }
        
        self.loadingAnimation.isHidden = false
        
        _AppDataHandler.signUpWithTRSAccount(email: email, password: password)
        { (isSuccess, error, responseData ) in
            
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                
                guard let responseData = responseData else {
                    //Response data = nil
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle",
                                                                                comment: ""),
                                                       message: NSLocalizedString("kSignInMessageFail", comment: ""))
                    return
                }
                
                switch responseData.messageCode {
                case 0:
                    // Sai password
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage0", comment: ""))
                    break
                case 1:
                    // Account bị lock do đăng nhập sai pass nhiều lần
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage1", comment: ""))
                    break
                case 2:
                    // Email không tồn tại trong hệ thống.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage2", comment: ""))
                    break
                case 3:
                    // User chưa đổi password lần đầu.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage3", comment: ""))
                    break
                default:
                    self.processLoginDone()
                    break
                }
                
                if responseData.isSuccess == false {
                    //Request fail
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                                       message: responseData.message)
                    return
                }
                
            } else {
                //Request API fails
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
                                                   message:error)
            }
        }
    }
    
    private func processLoginDone() {
        
        //call api streak
        _NavController.dailyTrackingAccess(forceRefesh: true)
        
        let userProfile = _AppDataHandler.getUserProfile()
        
        if let email = emailTxt.text {
            Bugfender.setDeviceString(email, forKey: "user_Iden")
        }
        
        if (userProfile.firstName == "") || (userProfile.lastName == "") || (userProfile.dob == 0) {
            guard let userWatchLaterOption = UserDefaults.standard.value(forKey: kUserSignUpIntroSkip) as? Int else {
                let introVideoVC = VC_SignUpIntroVideo()
                _NavController.pushViewController(introVideoVC, animated: true)
                return
            }
            
            let currentDateInt = Int(Date().timeIntervalSince1970)
            
            UserDefaults.standard.removeObject(forKey: kUserSignUpIntroSkip)
            if (currentDateInt - userWatchLaterOption) >= 86400 { // 1 days
                let introVideoVC = VC_SignUpIntroVideo()
                _NavController.pushViewController(introVideoVC, animated: true)
            } else {
                let userNameVC = VC_SubPageUpdateUser()
                self.navigationController?.pushViewController(userNameVC, animated: true)
            }
            return
        }
            
        self.loadingAnimation.isHidden = false
         let _ = _AppDataHandler.getInitialQuizStatus { (isSucess, error, didMakeInitialQuiz) in
            self.loadingAnimation.isHidden = true
            
            if isSucess {
                if didMakeInitialQuiz {
                    if userProfile.isFreemiumUser() {
                        let inAppReviewVC = VC_InAppReviews()
                        self.navigationController?.pushViewController(inAppReviewVC, animated: true)
                    }
                    else {
                        _NavController.setViewControllers([MainPageTabbar()], animated: true)
                        return
                    }
                } else {
                    let quizVC = VC_SubPageQuiz()
                    self.navigationController?.pushViewController(quizVC, animated: true)
                }
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
}
