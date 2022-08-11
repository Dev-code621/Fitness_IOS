//
//  VC_SignInAuthentication.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AuthenticationServices
import GoogleSignIn
import FBSDKLoginKit

class VC_SignUpInAuthentication: UIViewController,
    ASAuthorizationControllerDelegate,
GIDSignInDelegate {
    
    let contentView             = UIView()
    
    let signInLabel             = UILabel()
    
    var emailTxt                = TextField()
    var passwordTxt             = TextField()
    var passwordRequired        = false
    
    var googleSignIn            = UIButton()
    var facebookSignIn          = UIButton()
    
    var appIntroductionBtn      = UIButton()
    var signInBtn               = UIButton()
    var signUpBtn               = UIButton()
    
    var loadingAnimation        = VW_LoadingAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyBoard))
        self.view.addGestureRecognizer(singleTap)
        
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage.init(named: "signin_background_new")
        backgroundImage.contentMode = .scaleAspectFill
        backgroundImage.layer.masksToBounds = true
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.bottom.greaterThanOrEqualToSuperview().offset(-395)
        }
        self.view.sendSubviewToBack(backgroundImage)
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.3
        self.view.addSubview(opacityView)
        
        let avatarImage = UIImageView()
        avatarImage.image = UIImage.init(named: "app_logo")
        avatarImage.contentMode = .scaleAspectFit
        avatarImage.layer.masksToBounds = true
        self.view.addSubview(avatarImage)
        avatarImage.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(30)
            make.top.equalToSuperview().offset(47)
            make.height.equalTo(27)
            make.width.equalTo(83)
        }
        
        contentView.backgroundColor = UIColor.white
        contentView.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        contentView.layer.cornerRadius = 30
        contentView.layer.masksToBounds = true
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.bottom.left.right.equalToSuperview()
            make.height.equalTo(416.5)
        }
        
        signUpBtn.setTitle(NSLocalizedString("kSignUpFreeAccountBtn", comment: "").uppercased(), for: .normal)
        signUpBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        signUpBtn.backgroundColor = UIColor.init(hexString: "1d00ff")
        signUpBtn.setTitleColor(UIColor.white, for: .normal)
        signUpBtn.layer.cornerRadius = 20
        signUpBtn.addTarget(self, action: #selector(signUpButtonTapped), for: .touchUpInside)
        contentView.addSubview(signUpBtn)
        signUpBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(30)
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }

        signInLabel.text = NSLocalizedString("kSignInBtn", comment: "")
        signInLabel.font = setFontSize(size: 34, weight: .bold)//HurmeGeometricSans2 
        signInLabel.textColor = UIColor.init(hexString: "1b1b1b")
        signInLabel.textAlignment = .center
        contentView.addSubview(signInLabel)
        signInLabel.snp.makeConstraints { (make) in
            make.top.equalTo(signUpBtn.snp.bottom).offset(30)
            make.left.equalToSuperview().offset(30)
            make.height.equalTo(44)
        }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                  NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "1d00ff")!,
                                  NSAttributedString.Key.font : setFontSize(size: 11, weight: .regular)] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: NSLocalizedString("kSignInAppTutorialBtn", comment: ""), attributes: underlineAttribute)
        appIntroductionBtn.setAttributedTitle(underlineAttributedString, for: .normal)
        appIntroductionBtn.addTarget(self, action: #selector(appIntroductionButtonTapped), for: .touchUpInside)
        self.view.addSubview(appIntroductionBtn)
        appIntroductionBtn.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-40)
            make.centerY.equalTo(signInLabel)
            make.height.equalTo(20)
        }
        
        let emailLine = UIView()
        emailLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.contentView.addSubview(emailLine)
        emailLine.snp.makeConstraints { (make) in
            make.top.equalTo(signInLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-80)
            make.height.equalTo(1)
        }
        
        emailTxt.placeholder = NSLocalizedString("kEmailPlaceHolder", comment: "")
        emailTxt.leftViewMode = .always
        emailTxt.leftView = UIImageView(image: UIImage.init(named: "email_icon"))
        emailTxt.keyboardType = .emailAddress
        emailTxt.autocapitalizationType = .none
        self.view.addSubview(emailTxt)
        emailTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(emailLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-80)
        }
        
        let showPassBtn = UIButton(type: .custom)
        showPassBtn.setImage(UIImage.init(named: "password_eye_icon"), for: .normal)
        showPassBtn.setImage(UIImage.init(named: "password_eye_off_icon"), for: .selected)
        showPassBtn.frame.size = CGSize(width: CGFloat(20), height: CGFloat(25))
        showPassBtn.addTarget(self, action: #selector(passwordSecurityEntryChange), for: .touchUpInside)
        
        let passwordLine = UIView()
        passwordLine.backgroundColor = UIColor.init(hexString: "7f7f7f")
        self.contentView.addSubview(passwordLine)
        passwordLine.snp.makeConstraints { (make) in
            make.top.equalTo(emailLine).offset(58.5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-80)
            make.height.equalTo(1)
        }
        
        passwordTxt.placeholder = NSLocalizedString("kPassword", comment: "")
        passwordTxt.leftViewMode = .always
        passwordTxt.rightViewMode = .always
        passwordTxt.isSecureTextEntry = true
        passwordTxt.disableAutoFillStrongPassword()
        passwordTxt.leftView = UIImageView(image: UIImage.init(named: "password_icon"))
        passwordTxt.rightView = showPassBtn
        self.view.addSubview(passwordTxt)
        passwordTxt.snp.makeConstraints { (make) in
            make.bottom.equalTo(passwordLine)
            make.centerX.equalToSuperview()
            make.height.equalTo(50)
            make.width.equalToSuperview().offset(-80)
        }
        
        signInBtn.setTitle(NSLocalizedString("kSignInBtn", comment: ""), for: .normal)
        signInBtn.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        signInBtn.backgroundColor = UIColor.white
        signInBtn.setTitleColor(UIColor.init(hexString: "1d00ff"), for: .normal)
        signInBtn.layer.cornerRadius = 20
        signInBtn.layer.borderWidth = 2
        signInBtn.layer.borderColor = UIColor.init(hexString: "1d00ff")?.cgColor
        signInBtn.addTarget(self, action: #selector(signInButtonTapped), for: .touchUpInside)
        self.contentView.addSubview(signInBtn)
        signInBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(passwordLine).offset(30)
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }
        
        let forgotPassword = UIButton()
        forgotPassword.setTitle("Forgot password?", for: .normal)
        forgotPassword.setTitleColor(UIColor.init(hexString: "666666"), for: .normal)
        forgotPassword.titleLabel?.font = setFontSize(size: 11, weight: .regular)// UIFont.init(name: "HurmeGeometricSans1-RegularObl", size: 11)
        forgotPassword.addTarget(self, action: #selector(forgotPasswordTapped), for: .touchUpInside)
        self.contentView.addSubview(forgotPassword)
        forgotPassword.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(signInBtn.snp.bottom).offset(15)
        }
        
        ///Bottom View
        let bottomStackView = UIView()
        self.contentView.addSubview(bottomStackView)
        bottomStackView.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalTo(signInBtn)
        }
        
//        let dontHaveAccount = UILabel()
//        dontHaveAccount.text = "Don’t have an account?"
//        dontHaveAccount.font = setFontSize(size: 14, weight: .regular)
//        dontHaveAccount.textColor = UIColor.init(hexString: "333333")
//        bottomStackView.addSubview(dontHaveAccount)
//        dontHaveAccount.snp.makeConstraints { (make) in
//            make.left.top.bottom.equalToSuperview()
//            make.width.equalTo(153)
//        }
        
        ///SocialView
        #warning("hard code to show social login")
        let socialView = UIStackView()
        socialView.isHidden = true
        self.contentView.addSubview(socialView)
        socialView.snp.makeConstraints { (make) in
            make.bottom.equalTo(bottomStackView.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        googleSignIn.setBackgroundImage(UIImage.init(named: "google_login_icon"), for: .normal)
        googleSignIn.addTarget(self, action: #selector(googleSignInButtonTapped), for: .touchUpInside)
        socialView.addSubview(googleSignIn)
        googleSignIn.snp.makeConstraints { (make) in
            make.top.bottom.left.equalToSuperview()
            make.height.width.equalTo(44)
        }
        
        facebookSignIn.setBackgroundImage(UIImage.init(named: "facebook_login_icon"), for: .normal)
        facebookSignIn.addTarget(self, action: #selector(facebookSignInButtonTapped), for: .touchUpInside)
        socialView.addSubview(facebookSignIn)
        facebookSignIn.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.height.width.equalTo(44)
            make.left.equalTo(googleSignIn.snp.right).offset(10)
        }
        
        if #available(iOS 13.0, *) {
            let appleSignIn = UIButton()
            appleSignIn.setBackgroundImage(UIImage.init(named: "apple_login_icon"), for: .normal)
            appleSignIn.layer.cornerRadius = 10
            appleSignIn.addTarget(self, action: #selector(handleAuthorizationAppleIDButtonPress), for: .touchDown)
            socialView.addSubview(appleSignIn)
            appleSignIn.snp.makeConstraints { (make) in
                make.top.bottom.equalToSuperview()
                make.height.width.equalTo(44)
                make.right.equalToSuperview()
                make.left.equalTo(facebookSignIn.snp.right).offset(10)
            }
            
        } else {
            facebookSignIn.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
            }
        }
        
        ///Loading Aniamtion
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Button Functions
    
    @objc func signInButtonTapped() {
        
        self.dissmissKeyBoard()
        
        if emailTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                           message: NSLocalizedString("kErrorEmailEmpty", comment: ""))
            return
        }
        
        if !(self.emailTxt.isValidEmail()) {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                           message: NSLocalizedString("kErrorEmailInvalid", comment: ""))
            return
        }
        
        if passwordTxt.text == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                           message: NSLocalizedString("kErrorPasswordEmpty", comment: ""))
            return
        }
        
        //KH bỏ pass
//        if !passwordTxt.isValidPassword() {
//            _NavController.presentAlertForCase(title: NSLocalizedString("kSignUpFailTitle", comment: ""),
//                                               message: NSLocalizedString("kPasswordFormatWarning", comment: ""))
//            return
//        }

        loadingAnimation.isHidden = false
        _AppDataHandler.signInWithTRSAccount(email: emailTxt.text!,
                                             password: passwordTxt.text!)
        { (isSuccess, error, responseData ) in
            
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                
                guard let responseData = responseData else {
                    //Response data = nil
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle",
                                                                                comment: ""),
                                                       message: NSLocalizedString("kSignInMessageFail", comment: ""))
                    return
                }
                
                switch responseData.messageCode {
                case 0:
                    // Sai password
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage0", comment: ""))
                    break
                case 1:
                    // Account bị lock do đăng nhập sai pass nhiều lần
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage1", comment: ""))
                    break
                case 2:
                    // Email không tồn tại trong hệ thống.
                    let alertVC = UIAlertController.init(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                         message: NSLocalizedString("kSignInMessage2", comment: ""),
                                                         preferredStyle: .alert)
                    let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                      style: .default) { (action) in
                                                        alertVC.dismiss(animated: true, completion: nil)
                                                      //  self.registerNewAccount()
                    }
                    alertVC.addAction(okAction)
                    _NavController.present(alertVC, animated: true, completion: nil)
                    break
                case 3:
                    // User chưa đổi password lần đầu.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage3", comment: ""))
                    break
                default:
                    self.processLoginDone()
                    break
                }
                
            } else {
                
                if (responseData != nil) {
                    switch responseData!.messageCode {
                    case 0:
                        // Sai password
                        _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                           message: NSLocalizedString("kSignInMessage0", comment: ""))
                        return
                    case 1:
                        // Account bị lock do đăng nhập sai pass nhiều lần
                        _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                           message: NSLocalizedString("kSignInMessage1", comment: ""))
                        return
                    case 2:
                        // Email không tồn tại trong hệ thống.
                        let alertVC = UIAlertController.init(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                             message: NSLocalizedString("kSignInMessage2", comment: ""),
                                                             preferredStyle: .alert)
                        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                          style: .default) { (action) in
                                                            alertVC.dismiss(animated: true, completion: nil)
                                                           // self.registerNewAccount()
                                                            
                        }
                        alertVC.addAction(okAction)
                        _NavController.present(alertVC, animated: true, completion: nil)
                        return
                    case 3:
                        // User chưa đổi password lần đầu.
                        _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                           message: NSLocalizedString("kSignInMessage3", comment: ""))
                        return
                    default:
                        //
                        break
                    }
                }
                
                //Request API fails
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message:error)
            }
        }
    }
    
    @objc func appIntroductionButtonTapped() {
        let appTutorial = VC_AppTutorial()
        self.navigationController?.pushViewController(appTutorial, animated: true)
    }
    
    @objc func signUpButtonTapped() {
        let signUpVC = VC_SignUpAuthentication()
        self.navigationController?.pushViewController(signUpVC, animated: true)
    }
    
    @objc func registerNewAccount() {
        
        
        if !passwordTxt.isValidPassword() {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message: NSLocalizedString("kPasswordFormatWarning", comment: ""))
            return
        }
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.signUpWithTRSAccount(email: emailTxt.text!,
                                             password: passwordTxt.text!)
        { (isSuccess, error, responseData ) in
            
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                
                guard let responseData = responseData else {
                    //Response data = nil
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle",
                                                                                comment: ""),
                                                       message: NSLocalizedString("kSignInMessageFail", comment: ""))
                    return
                }
                
                switch responseData.messageCode {
                case 0:
                    // Sai password
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage0", comment: ""))
                    break
                case 1:
                    // Account bị lock do đăng nhập sai pass nhiều lần
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage1", comment: ""))
                    break
                case 2:
                    // Email không tồn tại trong hệ thống.
                    //                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                    //                                                   message: NSLocalizedString("kSignInMessage2", comment: ""))
                    break
                case 3:
                    // User chưa đổi password lần đầu.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: NSLocalizedString("kSignInMessage3", comment: ""))
                    break
                default:
                    self.processLoginDone()
                    break
                }
                
                if responseData.isSuccess == false {
                    //Request fail
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                       message: responseData.message)
                    return
                }
                
            } else {
                //Request API fails
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message:error)
            }
        }
    }
    
    @available(iOS 13.0, *)
    @objc func handleAuthorizationAppleIDButtonPress() {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.email]
        
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        //        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    @objc func googleSignInButtonTapped() {
        GIDSignIn.sharedInstance()?.delegate = self
        GIDSignIn.sharedInstance()?.presentingViewController = self
        GIDSignIn.sharedInstance()?.signIn()
    }
    
    @objc func facebookSignInButtonTapped() {
        let fbLoginManager : LoginManager = LoginManager()
        fbLoginManager.logOut()
        
        fbLoginManager.logIn(permissions: ["email","public_profile"],
                             viewController: self) { (result) in
                                print("")
                                switch result {
                                case .success(granted: _,
                                              declined: _,
                                              token: let token):
                                    let tokenStr = token.tokenString
                                    self.processFacebookLogin(tokenString: tokenStr)
                                    
                                    break
                                case .cancelled:
                                    break
                                case .failed(_):
                                    break
                                }
        }
    }
    
    //MARK: - UX Functions
    
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func passwordSecurityEntryChange() {
        passwordTxt.isSecureTextEntry = !passwordTxt.isSecureTextEntry
        if passwordTxt.rightView is UIButton {
            let btn = passwordTxt.rightView as! UIButton
            btn.isSelected = !btn.isSelected
        }
        
    }
    
    @objc func forgotPasswordTapped() {
        let forgotVC = VC_ForgotPassword()
        self.navigationController?.pushViewController(forgotVC, animated: true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if notification.userInfo != nil {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let keyboardYPos = keyboardRectangle.origin.y
                
                if keyboardYPos == UIScreen.main.bounds.size.height {
                    contentView.snp.remakeConstraints { (make) in
                        make.bottom.left.right.equalToSuperview()
                        make.height.equalTo(416.5)
                    }
                } else {
                    contentView.snp.remakeConstraints { (make) in
                        make.left.right.equalToSuperview()
                        make.bottom.equalToSuperview().offset(-keyboardHeight)
                        make.height.equalTo(416.5)
                    }
                }
                
                UIView.animate(withDuration: 1) {
                    self.view.layoutIfNeeded()
                }
                
            }
        }
    }
    
    
    
    //MARK: - ProcessLogin
    
    private func processAppleLogin(tokenString: String) {
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.signInWithAppleAccount(appleToken: tokenString) { (isSuccess, error, responseData ) in
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                
                guard let responseData = responseData else {
                    //Response data = nil
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle",
                                                                            comment: ""),
                                                   message: NSLocalizedString("kSignInMessageFail", comment: ""))
                    return
                }
                
                if responseData.isSuccess == false {
                    //Request fail
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: responseData.message)
                    return
                }
                
                switch responseData.messageCode {
                case 0:
                    // Sai password
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage0", comment: ""))
                    break
                case 1:
                    // Account bị lock do đăng nhập sai pass nhiều lần
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage1", comment: ""))
                    break
                case 2:
                    // Email không tồn tại trong hệ thống.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage2", comment: ""))
                    break
                case 3:
                    // User chưa đổi password lần đầu.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage3", comment: ""))
                    break
                default:
                    self.processLoginDone()
                    break
                }
            } else {
                //Request API fails
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message:error)
            }
        }
    }
    
    private func processFacebookLogin(tokenString: String) {
        self.loadingAnimation.isHidden = false
        _AppDataHandler.signInWithFacebookAccount(facebookToken: tokenString) { (isSuccess, error, responseData ) in
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                
                guard let responseData = responseData else {
                    //Response data = nil
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle",
                                                                            comment: ""),
                                                   message: NSLocalizedString("kSignInMessageFail", comment: ""))
                    return
                }
                
                if responseData.isSuccess == false {
                    //Request fail
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: responseData.message)
                    return
                }
                
                switch responseData.messageCode {
                case 0:
                    // Sai password
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage0", comment: ""))
                    break
                case 1:
                    // Account bị lock do đăng nhập sai pass nhiều lần
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage1", comment: ""))
                    break
                case 2:
                    // Email không tồn tại trong hệ thống.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage2", comment: ""))
                    break
                case 3:
                    // User chưa đổi password lần đầu.
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: NSLocalizedString("kSignInMessage3", comment: ""))
                    break
                default:
                    self.processLoginDone()
                    break
                }
            } else {
                //Request API fails
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message:error)
            }
        }
    }
    
    private func processGoogleLogin(tokenString: String) {
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.signInWithGoogleAccount(googleToken: tokenString) { (isSuccess, error, responseData ) in
            self.loadingAnimation.isHidden = true
            if isSuccess {
                
                guard let responseData = responseData else {
                    //Response data = nil
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle",
                                                                                comment: ""),
                                                       message: NSLocalizedString("kSignInMessageFail", comment: ""))
                return
            }
            
            if responseData.isSuccess == false {
                //Request fail
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message: responseData.message)
                return
            }
            
            switch responseData.messageCode {
            case 0:
                // Sai password
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message: NSLocalizedString("kSignInMessage0", comment: ""))
                break
            case 1:
                // Account bị lock do đăng nhập sai pass nhiều lần
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message: NSLocalizedString("kSignInMessage1", comment: ""))
                break
            case 2:
                // Email không tồn tại trong hệ thống.
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message: NSLocalizedString("kSignInMessage2", comment: ""))
                break
            case 3:
                // User chưa đổi password lần đầu.
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message: NSLocalizedString("kSignInMessage3", comment: ""))
                break
            default:
                self.processLoginDone()
                break
            }
        } else {
            //Request API fails
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                           message:error)
            }
        }
    }
    
    func processLoginDone() {
        
        //call api streak
        _NavController.dailyTrackingAccess(forceRefesh: true)
        
        let userProfile = _AppDataHandler.getUserProfile()
        
        if let email = emailTxt.text {
            Bugfender.setDeviceString(email, forKey: "user_Iden")
        }
        
        if (userProfile.firstName == "") || (userProfile.lastName == "") || (userProfile.dob == 0) {
            let userNameVC = VC_SubPageUpdateUser()
            self.navigationController?.pushViewController(userNameVC, animated: true)
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
    
    //MARK: - ASAuthorizationControllerDelegate
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        switch authorization.credential {
        case let appleIDCredential as ASAuthorizationAppleIDCredential:
            // Create an account in your system.
//            let userIdentifier = appleIDCredential.user
//
//            let fullName = appleIDCredential.fullName
//            if let givenName = fullName?.givenName, let familyName = fullName?.familyName {
//                if (KeychainWrapper.standard.set(givenName + familyName, forKey: kAppleUserFullName)) {
//                    print("Save Given Name ok")
//                }
//            }
//
//            if let email = appleIDCredential.email {
//                if (KeychainWrapper.standard.set(email, forKey: kAppleUserEmail)) {
//                    print("Save email ok")
//                }
//            }
            
            let appleToken = String(decoding: appleIDCredential.identityToken!, as: UTF8.self)
            
            self.processAppleLogin(tokenString: appleToken)
            
            break
        case let passwordCredential as ASPasswordCredential:
            // Sign in using an existing iCloud Keychain credential.
            let username = passwordCredential.user
            let password = passwordCredential.password
            
            print("User signed in with user: " + username)
            print("User signed in with password: " + password)
            
            break
        default:
            break
        }
    }
    
    @available(iOS 13.0, *)
    func authorizationController(controller: ASAuthorizationController, didCompleteWithError error: Error) {
        print("")
    }
    
    //MARK: - ASAuthorizationControllerPresentationContextProviding
    //    @available(iOS 13.0, *)
    //    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
    //        //
    //    }
    
    //MARK: - GIDSignInDelegate
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if let error = error {
            if (error as NSError).code == GIDSignInErrorCode.hasNoAuthInKeychain.rawValue {
                print("The user has not signed in before or they have since signed out.")
            } else {
                print("\(error.localizedDescription)")
            }
            return
        }
        
        self.processGoogleLogin(tokenString: user.authentication.idToken)
    }
}

class FacebookButton: FBLoginButton {
    
    let standardButtonHeight = 50.0
    
    override func updateConstraints() {
        // deactivate height constraints added by the facebook sdk (we'll force our own instrinsic height)
        for contraint in constraints {
            if contraint.firstAttribute == .height, contraint.constant < CGFloat(standardButtonHeight) {
                // deactivate this constraint
                contraint.isActive = false
            }
        }
        super.updateConstraints()
    }
    
    override var intrinsicContentSize: CGSize {
        return CGSize(width: Double(UIView.noIntrinsicMetric), height: standardButtonHeight)
    }
    
    override func imageRect(forContentRect contentRect: CGRect) -> CGRect {
        let logoSize: CGFloat = 24.0
        let centerY = contentRect.midY
        let y: CGFloat = centerY - (logoSize / 2.0)
        return CGRect(x: y, y: y, width: logoSize, height: logoSize)
    }
    
    override func titleRect(forContentRect contentRect: CGRect) -> CGRect {
        if isHidden || bounds.isEmpty {
            return .zero
        }
        
        let imageRect = self.imageRect(forContentRect: contentRect)
        let titleX = imageRect.maxX
        let titleRect = CGRect(x: titleX, y: 0, width: contentRect.width - titleX - titleX, height: contentRect.height)
        return titleRect
    }
    
}
