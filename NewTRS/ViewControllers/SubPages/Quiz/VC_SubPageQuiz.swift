//
//  VC_SubPageQuiz.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/6/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_SubPageQuiz: UIViewController,
                        UIScrollViewDelegate,
                        VW_QuizContentDelegate,
                        VW_QuizSelectMyEquipmentDelegate {
    
    let backBtn         = UIButton()
    let skipBtn         = UIButton()
    let slideView       = UIScrollView()
    let pageControl     = UIPageControl()
    let backgroundImage = UIImageView()
    
    var isDoInitialQuiz = false
    var initialQuiz     = UserQuizResults.init(JSONString: "{}")!
    
    let loadingAnimation  = VW_LoadingAnimation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .black
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyBoard))
        self.view.addGestureRecognizer(singleTap)
        
        slideView.delegate = self
        slideView.isPagingEnabled = true
        slideView.isScrollEnabled = true
        self.view.addSubview(slideView)
        slideView.snp.makeConstraints { (make) in
            make.width.centerX.equalTo(self.view)
            make.centerY.equalTo(self.view.snp.bottom).offset(-250)
            make.height.equalTo(500)
        }
        
        backgroundImage.contentMode = .scaleAspectFit
        backgroundImage.layer.masksToBounds = true
        backgroundImage.image = UIImage.init(named: "Male_or_Female")
        self.view.addSubview(backgroundImage)
        backgroundImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(slideView.snp.top)
        }
        
        self.loadContent()
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 5
        pageControl.pageIndicatorTintColor = UIColor.init(hexString: "5c5c5c")
        pageControl.currentPageIndicatorTintColor = UIColor.init(hexString: "f0f0f0")
        self.view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(slideView).offset(-10)
            make.centerX.equalTo(slideView)
        }
        
        //Ẩn button skip
//        let skipBGView = UIView()
//        skipBGView.backgroundColor = UIColor.white
//        skipBGView.layer.cornerRadius = 15
//        skipBGView.layer.opacity = 0.85
//        self.view.addSubview(skipBGView)
//        skipBGView.snp.makeConstraints { (make) in
//            make.bottom.equalTo(pageControl.snp.top).offset(0)
//            make.centerX.equalToSuperview()
//            make.height.equalTo(30)
//            make.width.equalToSuperview().offset(-40)
//        }
//
//        skipBtn.setTitle("Skip", for: .normal)
//        skipBtn.titleLabel?.font = setFontSize(size: 14, weight: .regular)
//        skipBtn.setTitleColor(UIColor.init(hexString: "333333"), for: .normal)
//        skipBtn.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
//        skipBGView.addSubview(skipBtn)
//        skipBtn.snp.makeConstraints { (make) in
//            make.height.equalToSuperview()
//            make.width.equalToSuperview()
//            make.center.equalToSuperview()
//        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.loadingAnimation.isHidden = false
       let _ = _AppDataHandler.getInitialQuizStatus { (isSucess, error, isDoneQuiz) in
            self.loadingAnimation.isHidden = true
            
            if isSucess {
                self.isDoInitialQuiz = isDoneQuiz
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - DataSource
    
    func listQuestion() -> [[String:Any]] {
        return [
        ["title":"What is your activity level?","answers":["I haven’t started yet? But I have plans","I exercise/train a few times a week","Training is LIFE"]],
        ["title":"Why are you here?","answers":["I’m an athlete\n trying to get better at my sport or workouts","I’m in pain","I want to be more\n flexible and improve my range of motion"]],
        ["title":"How often do you currently stretch / do mobility exercises?","answers":["Newbie\n (0 - 1 days a week)","Intermediate","Expert\n (Every day)"]]]
    }
    
    func loadContent() {
        
        slideView.delegate = self
        var markView : UIView? = nil
        
        // ===== Get Gender Quiz ====
        let userGenderSlideView = UIView()
        slideView.addSubview(userGenderSlideView)
        userGenderSlideView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-50)
            make.height.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.left.equalToSuperview()
        }
        markView = userGenderSlideView
        
        let userGenderView = VW_QuizUserGender()
        userGenderView.delegate = self
        userGenderSlideView.addSubview(userGenderView)
        userGenderView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        let listQuestion = self.listQuestion()
        for quizData in listQuestion {

            let slideScreenView = UIView()
            slideView.addSubview(slideScreenView)
            if (markView != nil) {
                slideScreenView.snp.makeConstraints { (make) in
                    make.centerY.equalToSuperview().offset(-50)
                    make.height.equalToSuperview()
                    make.width.equalTo(UIScreen.main.bounds.size.width)
                    make.left.equalTo(markView!.snp.right)
                }
            }
            else {
                
                slideScreenView.snp.makeConstraints { (make) in
                    make.centerY.height.equalToSuperview()
                    make.width.equalTo(UIScreen.main.bounds.size.width)
                    make.left.equalToSuperview()
                }
            }
            markView = slideScreenView
            
            
            let quizView = VW_QuizSingSelectionContent()
            quizView.delegate = self
            quizView.setData(data: quizData)
            slideScreenView.addSubview(quizView)
            quizView.snp.makeConstraints { (make) in
                make.center.equalToSuperview()
                make.width.equalToSuperview()
            }
        }
        
        // ===== Get User's Equipment ====
        let userEquipmentSlideView = UIView()
        slideView.addSubview(userEquipmentSlideView)
        userEquipmentSlideView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(-50)
            make.height.equalToSuperview()
            make.width.equalTo(UIScreen.main.bounds.size.width)
            make.left.equalTo(markView!.snp.right)
        }
        markView = userEquipmentSlideView
        
        let userEquipmentView = VW_QuizSelectMyEquipments()
        userEquipmentView.delegate = self
        userEquipmentSlideView.addSubview(userEquipmentView)
        userEquipmentView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview()
        }
        
        if markView != nil {
            markView!.snp.makeConstraints { (make) in
                make.right.equalToSuperview()
            }
        }
        slideView.layoutIfNeeded()
    }
    
    //MARK: - Functions
    
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func skipButtonTapped() {
        
        let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipTitle", comment: ""),
                                             message: NSLocalizedString("kSkipWarningMessage", comment: ""),
                                             preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                          style: .default) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
                                            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                                                let inAppReviewVC = VC_InAppReviews()
                                                self.navigationController?.pushViewController(inAppReviewVC, animated: true)
                                            } else {
                                                _NavController.setViewControllers([MainPageTabbar()], animated: true)
                                            }
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        
        let page = lroundf(Float(fractionalPage))
        self.pageControl.currentPage = page
        switch page {
        case 0:
            backgroundImage.image = UIImage.init(named: "Male_or_Female")
            break
        case 1:
            backgroundImage.image = UIImage.init(named: "Activity_Level_App")
            break
        case 2:
            backgroundImage.image = UIImage.init(named: "Why_are_you_here_App")
            break
        case 3:
            backgroundImage.image = UIImage.init(named: "How_Often_Do_You")
            break
        case 4:
            backgroundImage.image = UIImage.init(named: "What_equipment_do_you_have")
            break
        default:
            backgroundImage.image = UIImage.init(named: "Male_or_Female")
            break
        }
    }
    
    //MARK: - VW_QuizContentDelegate
    func didSelectAnswer(title: String, index: Int) {
                
        if title.contains("Gender") {
            //Gender
            self.initialQuiz.gender = index
        } else if title.contains("What is your activity level") {
            self.initialQuiz.activityLevel = index
        } else if title.contains("Why are you here") {
            self.initialQuiz.reasonToJoin = index
        } else if title.contains("How often do you currently stretch / do mobility exercises?") {
            self.showAlertEquipment()
            self.initialQuiz.experienceMobilizing = index
        }
        var currentOffset = slideView.contentOffset
        currentOffset.x += UIScreen.main.bounds.size.width
        slideView.setContentOffset(currentOffset, animated: true)
    }
    
    private func showAlertEquipment() {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kMessageTitle", comment: ""),
                                             message: NSLocalizedString("kEquipmentQuizPopupMessage", comment: ""),
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                          style: .cancel) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: - VW_QuizSelectMyEquipmentDelegate
    func doneButtonTapped(selectedEquipmentIDs: [String]) {
        
        self.initialQuiz.myEquipmentIds = selectedEquipmentIDs
        
        // Check answer all questions
        if self.initialQuiz.gender == -1 ||
            self.initialQuiz.activityLevel == -1 ||
            self.initialQuiz.experienceMobilizing == -1 ||
            self.initialQuiz.reasonToJoin == -1 ||
            self.initialQuiz.myEquipmentIds.count == 0
        {
            _NavController.presentAlertForCase(title: NSLocalizedString("kQuizFailTitle", comment: ""),
                                               message: NSLocalizedString("kQuizFailAnswerAllQuestion", comment: ""))
            return
        }
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.sendInitialQuiz(quizData: self.initialQuiz) { (isSuccess, error, isUpdated) in
            
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                
                if isUpdated {
                    _NavController.presentAlertForCase(title: "Update User Profile", message: error)
                    return
                }
                
                // Check user thanh toan roi hay chưa?
                if _AppDataHandler.getUserProfile().isFreemiumUser() {
                    let inAppReviewVC = VC_InAppReviews()
                    self.navigationController?.pushViewController(inAppReviewVC, animated: true)
                }
                else {
                    _NavController.setViewControllers([MainPageTabbar()], animated: true)
                    return
                }
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
}
