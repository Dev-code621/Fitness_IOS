//
//  ViewController.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AuthenticationServices
import Alamofire

class VC_SubPageLunchSceen: UIViewController {
    
    var systemDataCount     : Int = 0
    var isCheckAppUpdate    : Bool = false
    
    var loadingAnimation    = VW_LoadingAnimation()
    
    private var listRequest     :[Request] = []
    //MARK: - Jaibroken device
    
    static var isDeviceJailbroken: Bool {

        guard TARGET_IPHONE_SIMULATOR != 1 else { return false }

        // Check 1 : existence of files that are common for jailbroken devices
        if FileManager.default.fileExists(atPath: "/Applications/Cydia.app")
        || FileManager.default.fileExists(atPath: "/Library/MobileSubstrate/MobileSubstrate.dylib")
        || FileManager.default.fileExists(atPath: "/bin/bash")
        || FileManager.default.fileExists(atPath: "/usr/sbin/sshd")
        || FileManager.default.fileExists(atPath: "/etc/apt")
        || FileManager.default.fileExists(atPath: "/private/var/lib/apt/")
        || UIApplication.shared.canOpenURL(URL(string:"cydia://package/com.example.package")!) {

            return true
        }

        // Check 2 : Reading and writing in system directories (sandbox violation)
        let stringToWrite = "Jailbreak Test"
        do {
            try stringToWrite.write(toFile:"/private/JailbreakTest.txt", atomically:true, encoding:String.Encoding.utf8)
            // Device is jailbroken
            return true
        } catch {
            return false
        }
    }

    //MARK: - ViewController Life Cycles
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.init(hexString: "#1d00ff")
        
        loadingAnimation.opacityView.backgroundColor = .blue
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        if VC_SubPageLunchSceen.isDeviceJailbroken {
            
            _NavController.presentAlertForCase(title: "Warning!!",
                                               message: "This app do not allow to run in Jail Broken device")
            return
        }
        _AppDataHandler.checkNetWork() // back luchScreen khi bấm offline mode
//        if !isAppAlreadyLaunchedOnce() {
//            self.showAlertPurchase()
//        }
        self.reloadData()
        NotificationCenter.default.addObserver(self, selector: #selector(self.onAppActive), name: UIApplication.willEnterForegroundNotification, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
            let defaults = UserDefaults.standard

            if let isAppAlreadyLaunchedOnce = defaults.string(forKey: "isAppAlreadyLaunchedOnce"){
                print("App already launched : \(isAppAlreadyLaunchedOnce)")
                return true
            }else{
                defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
                print("App launched first time")
                return false
            }
        }
    
    private func showAlertPurchase() {
        let alert = UIAlertController(title: NSLocalizedString("kNoticeTitle", comment: ""), message: NSLocalizedString("kInAppDescMessage", comment: ""), preferredStyle: UIAlertController.Style.alert)
        
        // add the actions (buttons)
        alert.addAction(UIAlertAction(title: NSLocalizedString("kInAppTermsServiceBtn", comment: ""), style: UIAlertAction.Style.default, handler: {_ in
            alert.dismiss(animated: true, completion: nil)
            let appPolicyVC = VC_AppPrivacyPolicy()
            self.navigationController?.pushViewController(appPolicyVC, animated: true)
            
        }))
        alert.addAction(UIAlertAction(title: NSLocalizedString("kOkAction", comment: ""), style: UIAlertAction.Style.cancel, handler: { _ in
            alert.dismiss(animated: true, completion: nil)
            self.reloadData()
        }))
        
        // show the alert
        self.present(alert, animated: true, completion: nil)
    }
    
    @objc func onAppActive() {
        _AppDataHandler.checkNetWork()
        self.cancelRequest()
        self.reloadData()
    }
    
    func cancelRequest() {
        for request in self.listRequest {
            request.cancel()
        }
        self.listRequest = []
    }
    
    private func reloadData() {
        
        guard let ourVersion = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String
        else {
            self.isCheckAppUpdate = true
            self.checkLoadingStatus()
            return
        }
        
        let request = _AppDataHandler.checkAppStore { (appStore) in
            //if AppStore version == nil (App has remove over Store)
            guard let appStoreVersion = appStore else {
                self.ignoredUpdate()
                return
            }
            //Check current Version with APpStore
            if ourVersion.compare(appStoreVersion, options: .numeric) == .orderedSame ||
                ourVersion.compare(appStoreVersion, options: .numeric) == .orderedDescending {
                self.ignoredUpdate()
                return
            }
            //Check Setting
            let request1 = _AppDataHandler.checkForceUpdate { (isSuccess, error, reponseData) in
                
                if isSuccess {
                    guard let iOSMinVersion = reponseData?.objectData?["minimum_version_ios"] as! String? else {
                        self.warningUpdate()
                        return
                    }
                    if ourVersion.compare(iOSMinVersion, options: .numeric) == .orderedAscending {
                        //Force update
                        self.forceUpdate(message: reponseData?.objectData?["force_update_message"] as? String ?? "")
                        return
                    }
                    else {
                        self.warningUpdate()
                        return
                    }
                }
                else {
                    self.warningUpdate()
                    return
                }
            }
            
            if request1 != nil {
                self.listRequest.append(request1!)
            }
        }
        
        if request != nil {
            listRequest.append(request!)
        }
    }
    
    private func warningUpdate() {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kUpdateTitle", comment: ""),
                                             message: NSLocalizedString("kUpdateWarningMessage", comment: ""),
                                             preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kUpdateAppleStoreLaterTitle", comment: ""),
                                              style: .cancel,
                                              handler: { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                self.isCheckAppUpdate = true
                                                self.checkLoadingStatus()
                                              })
        let okAction = UIAlertAction.init(title: NSLocalizedString("kUpdateAppleStoreTitle", comment: ""),
                                          style: .default,
                                          handler: { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
                                            if let url = URL(string:kAppStoreReleaseURL),
                                               UIApplication.shared.canOpenURL(url){
                                                UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                            }
                                          })
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func forceUpdate(message: String) {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kUpdateTitle", comment: ""),
                                             message: message,//data.objectData?["force_update_message"] as? String ,
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kUpdateAppleStoreTitle", comment: ""),
                                          style: .default,
                                          handler: { (action) in
                                            self.isCheckAppUpdate = true
                                            self.checkLoadingStatus()
                                          })
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    private func ignoredUpdate() {
        self.isCheckAppUpdate = true
        self.checkLoadingStatus()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        if isAppAlreadyLaunchedOnce() {
//            self.reloadData()
//        }
        _NavController.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: -
    func checkLoadingStatus() {
        if self.isCheckAppUpdate {
            self.checkUserLogged()
        }
    }
    
    func checkUserLogged() {
        guard let userSessionToken = _AppDataHandler.getSessionDataSource() else {
             //No logged in
            _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
            return
        }
        
        let curentTime = Int(NSDate().timeIntervalSince1970)
        let expriedTime = userSessionToken.expirationTime + 120  // 120 seconds is time to get new token
        
        if curentTime >= expriedTime {
            let request = _AppDataHandler.renewToken(oldRefreshToken: userSessionToken.refreshToken) { (isSuccess, error) in
                if isSuccess {
                    self.authenticationSuccess()
                    
                } else {
                    self.authenticationFail()
                }
            }
            
            if request != nil {
                listRequest.append(request!)
            }
        } else {
            
            let request = _AppDataHandler.getUserProfile { (isSuccess, error, newUserProfile) in
                if isSuccess {
                    self.authenticationSuccess()
                } else {
                    self.authenticationSuccess()
                }
            }
            
            if request != nil {
                listRequest.append(request!)
            }
        }
    }
    
    func authenticationFail () {
        _AppDataHandler.signout()
        _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
    }
    
    func authenticationSuccess () {
        let userProfile = _AppDataHandler.getUserProfile()
        
        if (userProfile.firstName == "") || (userProfile.lastName == "") || (userProfile.dob == 0) {
            self.doNotUpdateUserName()
        } else {
            self.didUpdateUserName()
        }
    }
    
    func didUpdateUserName() {
        let statusQuiz = _AppDataHandler.getStatusQuiz()
        let request = _AppDataHandler.getInitialQuizStatus { (isSuccess, error, didMakeSurvey) in
            if isSuccess && didMakeSurvey {
                self.didInitialQuiz()
            } else {
                if statusQuiz {
                     self.didInitialQuiz()
                } else {
                    self.doNotMakeInitialQuiz()
                }
            }
        }
        
        if request != nil {
            listRequest.append(request!)
        }
    }
    
    func doNotUpdateUserName() {
        let userNameVC = VC_SubPageUpdateUser()
        self.navigationController?.pushViewController(userNameVC, animated: true)
    }
    
    func didInitialQuiz() {
        let userProfile = _AppDataHandler.getUserProfile()
        if userProfile.isFreemiumUser() {
            self.userStayInFree()
        } else {
            self.userDidSubscribe()
        }
    }
    
    func doNotMakeInitialQuiz() {
        let quizVC = VC_SubPageQuiz()
        self.navigationController?.pushViewController(quizVC, animated: true)
    }
    
    func userDidSubscribe() {
        _NavController.setViewControllers([MainPageTabbar()], animated: true)
    }
    
    func userStayInFree() {
        let iAPReviewVC = VC_InAppReviews()
        _NavController.pushViewController(iAPReviewVC, animated: true)
    }
}

