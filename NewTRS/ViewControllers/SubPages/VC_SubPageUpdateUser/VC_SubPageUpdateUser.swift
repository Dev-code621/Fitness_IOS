//
//  VC_SubPageUpdateUser.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/12/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_SubPageUpdateUser: UIViewController,
                       UIScrollViewDelegate,
                        VW_QuizUserNameDelegate,
                        VW_QuizUserDoBDelegate {
    
    let backBtn         = UIButton()
    let slideView       = UIScrollView()
    
    let userNameView    = VW_QuizUserName()
    let userDOBView     = VW_QuizUserDoB()
    let pageControl     = UIPageControl()
        
    let loadingAnimation  = VW_LoadingAnimation()
    var firstName         = ""
    var lastName          = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .black
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyBoard))
        self.view.addGestureRecognizer(singleTap)
        
        let backgroundImage = UIImageView()
        backgroundImage.image = UIImage.init(named: "quiz_background_image")
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }

        userNameView.delegate = self
        self.view.addSubview(userNameView)
        userNameView.snp.makeConstraints { (make) in
            make.left.width.equalTo(self.view.safeAreaLayoutGuide)
            make.centerY.equalTo(self.view.snp.bottom).offset(-250)
        }
        
        userDOBView.delegate = self
        self.view.addSubview(userDOBView)
        userDOBView.snp.makeConstraints { (make) in
            make.width.centerY.equalTo(userNameView)
            make.left.equalTo(userNameView.snp.right)
        }
        
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
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
        
    //MARK: - Functions
    
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func keyboardNotification(notification: NSNotification) {
        if notification.userInfo != nil {
            if let keyboardFrame: NSValue = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                let keyboardRectangle = keyboardFrame.cgRectValue
                let keyboardHeight = keyboardRectangle.height
                let keyboardYPos = keyboardRectangle.origin.y
                
                if keyboardYPos == UIScreen.main.bounds.size.height {
                    userNameView.snp.updateConstraints { (make) in
                        make.centerY.equalTo(self.view.snp.bottom).offset(-250)
                    }
                } else {
                    userNameView.snp.updateConstraints { (make) in
                        make.centerY.equalTo(self.view.snp.bottom).offset(-250-keyboardHeight)
                    }
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        
        let page = lroundf(Float(fractionalPage))
        self.pageControl.currentPage = page
    }
        
    //MARK: - VW_QuizUserNameDelegate
    func didEnterUserName(firstName: String, lastName: String) {
        
        if firstName == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kMessageTitle", comment: ""),
                                               message: NSLocalizedString("kQuizFailFistNameMessage", comment: ""))
            return
        }
        
        if firstName.count > 30 {
            _NavController.presentAlertForCase(title: NSLocalizedString("kMessageTitle", comment: ""),
                                               message: NSLocalizedString("kQuizFailFistName30Message", comment: ""))
            return
        }
        
        if lastName == "" {
            _NavController.presentAlertForCase(title: NSLocalizedString("kMessageTitle", comment: ""),
                                               message: NSLocalizedString("kQuizFailLastNameMessage", comment: ""))
            return
        }
        
        if lastName.count > 30 {
            _NavController.presentAlertForCase(title: NSLocalizedString("kMessageTitle", comment: ""),
                                               message: NSLocalizedString("kQuizFailLastName30Message", comment: ""))
            return
        }
                
        let userProfile = _AppDataHandler.getUserProfile()
        
        userProfile.firstName = firstName
        userProfile.lastName = lastName
        self.firstName = firstName
        self.lastName  = lastName
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.updateUserProfile(profile: userProfile) { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                print("Update user profile success!")
                
                self.userNameView.snp.remakeConstraints { (make) in
                    make.left.equalTo(self.view.safeAreaLayoutGuide).offset(-UIScreen.main.bounds.size.width)
                    make.width.equalTo(self.view.safeAreaLayoutGuide)
                    make.centerY.equalTo(self.view.snp.bottom).offset(-250)
                }
                
                UIView.animate(withDuration: 0.2) {
                    self.view.layoutIfNeeded()
                }
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    //MARK: - VW_QuizUserDoBDelegate
    func didSelectDate(unixTime: Int) {
        
        let userProfile = _AppDataHandler.getUserProfile()
        userProfile.dob = unixTime
        userProfile.firstName = self.firstName
        userProfile.lastName = self.lastName
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.updateUserProfile(profile: userProfile) { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                print("Update user profile success!")
                
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
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
}

