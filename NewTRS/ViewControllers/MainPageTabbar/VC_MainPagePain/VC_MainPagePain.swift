//
//  VC_MainPagePain.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPagePain: UIViewController,
                        UIScrollViewDelegate,
                        AnotomyDelegate {
        
    let segmentControl      = UISegmentedControl.init(items: ["Front", "Back"])
    let slideView           = UIScrollView()
    
    let frontView           = VW_FrontView.init(frame: .zero)
    let backView            = VW_BackView.init(frame: .zero)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        //MARK: Navigation Bar
        let userProfileBtn = UIBarButtonItem.init(image: UIImage.init(named: "user_profile_icon"),
                                                  style: .plain,
                                                  target: self,
                                                  action: #selector(userProfileButtonTapped))
        let userActitvityBtn = UIBarButtonItem.init(image: UIImage.init(named: "user_activity_icon"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(userActivityButtonTapped))
        let userFavoriteBtn = UIBarButtonItem.init(image: UIImage.init(named: "user_favorite_icon"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(userFavoriteButtonTapped))
        let homeBtn = UIBarButtonItem.init(image: UIImage.init(named: "home_icon"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(homeButtonTapped))
        self.navigationItem.leftBarButtonItem = homeBtn
        self.navigationItem.rightBarButtonItems = [userFavoriteBtn, userActitvityBtn, userProfileBtn]
        
        //MARK: Contents
        if #available(iOS 13.0, *) {
            segmentControl.selectedSegmentTintColor = UIColor.init(hexString: "718cfe")!
        } else {
            segmentControl.tintColor = UIColor.init(hexString: "718cfe")!
        }
        segmentControl.selectedSegmentIndex = 0
        let titleSelectedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                       NSAttributedString.Key.font : setFontSize(size: 14, weight: .semibold)]
        let titleNormalAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                     NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)]
        segmentControl.setTitleTextAttributes(titleNormalAttributes, for: .normal)
        segmentControl.setTitleTextAttributes(titleSelectedAttributes, for: .selected)
        segmentControl.addTarget(self, action: #selector(segmentedControlDidChangeValue), for: .valueChanged)
        self.view.addSubview(segmentControl)
        segmentControl.snp.makeConstraints { (make) in
            make.top.equalTo(self.view).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        slideView.delegate = self
        slideView.isPagingEnabled = true
        slideView.backgroundColor = .clear
        slideView.showsHorizontalScrollIndicator = false
        self.view.addSubview(slideView)
        slideView.snp.makeConstraints { (make) in
            make.top.equalTo(segmentControl.snp.bottom).offset(13.5)
            make.bottom.equalToSuperview().offset(0)
            make.left.right.equalToSuperview()
        }
        
        self.loadAnotomyViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _NavController.setNavigationBarHidden(true, animated: false)
        
        //Load view account
        frontView.loadAccountView()
        backView.loadAccountView()
        
        // ======== Tool tips =======
        
        // 1 check tools tip already apprear or not?
        let userDefault = UserDefaults.standard
        
        if let key = userDefault.object(forKey: kUserPainTooltips) as? String {
            if key != kUserPainTooltips {
                // 2 present alert
                let alertVC = UIAlertController.init(title: "",
                                                     message: NSLocalizedString("kMainPagePainBodyPart", comment: ""),
                                                     preferredStyle: .alert)
                let proceedAction = UIAlertAction.init(title: "Proceed",
                                                       style: .cancel) { (action) in
                                                        alertVC.dismiss(animated: true, completion: nil)
                }
                alertVC.addAction(proceedAction)
                self.present(alertVC, animated: true, completion: nil)
                
                userDefault.set(kUserPainTooltips, forKey: kUserPainTooltips)
            }
        } else {
            //First time
            // 2 present alert
            let alertVC = UIAlertController.init(title: "",
                                                 message: NSLocalizedString("kMainPagePainBodyPart", comment: ""),
                                                 preferredStyle: .alert)
            let proceedAction = UIAlertAction.init(title: "Proceed",
                                                   style: .cancel) { (action) in
                                                    alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(proceedAction)
            self.present(alertVC, animated: true, completion: nil)
            
            userDefault.set(kUserPainTooltips, forKey: kUserPainTooltips)
        }
    }

    //MARK: - Process Data
    @objc private func segmentedControlDidChangeValue() {
        let selectedIndex = self.segmentControl.selectedSegmentIndex
        
        var frame: CGRect = self.slideView.frame
        frame.origin.x = frame.size.width * CGFloat(selectedIndex)
        frame.origin.y = 0
        self.slideView.scrollRectToVisible(frame, animated: true)
    }
    
    //MARK: - Custom UI
    func loadAnotomyViews() {
        
        let width = self.view.frame.size.width
        
        frontView.backgroundColor = UIColor.init(hexString: "ccffffff")
        frontView.layer.cornerRadius = 20
        frontView.layer.shadowColor = UIColor.init(hexString: "222d00ff")!.cgColor
        frontView.layer.shadowOpacity = 0.5
        frontView.layer.shadowOffset = CGSize(width: 2, height: 9)
        frontView.layer.shadowRadius = 20
        frontView.delegate = self
        self.slideView.addSubview(frontView)
        frontView.snp.makeConstraints { (make) in
            make.width.equalTo(self.view).multipliedBy(0.9)
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-30)
            make.top.equalToSuperview()
        }
        
        backView.backgroundColor = UIColor.init(hexString: "ccffffff")
        backView.layer.cornerRadius = 20
        backView.layer.shadowColor = UIColor.init(hexString: "222d00ff")!.cgColor
        backView.layer.shadowOpacity = 0.5
        backView.layer.shadowOffset = CGSize(width: 2, height: 9)
        backView.layer.shadowRadius = 20
        backView.delegate = self
        self.slideView.addSubview(backView)
        backView.snp.makeConstraints { (make) in
            make.height.width.top.bottom.equalTo(frontView)
            make.left.equalTo(frontView.snp.right).offset(42)
            make.right.equalToSuperview().offset(-width*0.14)
            make.height.equalToSuperview().offset(-30)
        }
        
        frontView.loadBlurView()
        backView.loadBlurView()
    }
    
    //MARK: - Navigation Functions
    @objc func homeButtonTapped() {
        let homeNav = UINavigationController(rootViewController: VC_MainPageHome())
        _NavController.present(homeNav, animated: true, completion: nil)
    }
    
    @objc func userProfileButtonTapped() {
        let userProfileVC = VC_SubPageUserProfile()
        let userProfileNavigation = UINavigationController.init(rootViewController: userProfileVC)
        userProfileNavigation.setNavigationBarHidden(true, animated: false)
        _NavController.present(userProfileNavigation, animated: true, completion: nil)
    }
    
    @objc func userActivityButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let progressVC = VC_SubPageProgress()
        _NavController.present(progressVC, animated: true, completion: nil)
    }
    
    @objc func userFavoriteButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let favoriteVC = VC_SubPageFavorite()
        _NavController.present(favoriteVC, animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        
        let page = lroundf(Float(fractionalPage))
        self.segmentControl.selectedSegmentIndex = page
    }
    
    //MARK: - AnotomyDelegate
    func didSelectTheKey(name: String) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            if name != "head" && name != "quads" && name != "elbow" {
                //Load view account
                frontView.bringSubviewToFront(frontView.fullBodyImageView)
                backView.bringSubviewToFront(backView.fullBodyImageView)
                frontView.loadAccountView()
                backView.loadAccountView()
                _NavController.presentAlertForFreemium()
                return
            }
        }
        
        let listPainAreas = _AppCoreData.listSystemPainAreas
        
        for painData in listPainAreas {
            if painData.painAreaKey == name {
                
                let listVC = _NavController.viewControllers
                if let lastVC = listVC.last {
                    if lastVC is VC_MainPagePainDetails {
                        return
                    }
                }
                
                let painDetails = VC_MainPagePainDetails()
                painDetails.setPainData(newPainData: painData)
                frontView.mutiTouch = false // front body trở về trạng thái ban đầu
                backView.mutiTouch = false
                _NavController.pushViewController(painDetails, animated: true)
            }
        }
    }
}
