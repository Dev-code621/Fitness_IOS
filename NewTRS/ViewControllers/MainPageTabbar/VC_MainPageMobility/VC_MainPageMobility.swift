//
//  VC_MainPageMobility.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import Alamofire

class VC_MainPageMobility: UIViewController {
    
    let bannerImage         = UIImageView()
    
    let userAvatar          = UIImageView()
    let userName            = UILabel()
    let statusContent       = UILabel()
    
    let reTestBtn           = UIButton()
    let startTestBtn        = UIButton()
    let mobilityPlanBtn     = UIButton()
    
    let trunkMoblity        = VW_MobilityCircle()
    let shoulderMobility    = VW_MobilityCircle()
    let hipMobility         = VW_MobilityCircle()
    let ankleMobility       = VW_MobilityCircle()
    let mobilityScrollView  = UIScrollView()

    var userResult          = UserMobilityDataSource.init(JSONString: "{}")!
    
    var loadingAnimation    = VW_LoadingAnimation()
    
    private var userMobilityRequest : Request?
    
    override func viewDidLoad() {
        super.viewDidLoad()
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
        self.navigationController?.navigationBar.tintColor = .white
        
        self.navigationController?.navigationBar.barStyle = .blackTranslucent
        self.navigationController?.navigationBar.isTranslucent = true
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
        //MARK: Contents
        bannerImage.image = UIImage.init(named: "head_banner")
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.layer.cornerRadius = 30
        bannerImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.equalTo(self.view)
            make.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.432)
        }
        
        // MARK: - User Info
        userAvatar.image = UIImage.init(named: "default_avatar")
        userAvatar.contentMode = .scaleAspectFill
        userAvatar.layer.cornerRadius = 10
        userAvatar.layer.borderWidth = 0.5
        userAvatar.layer.borderColor = UIColor.white.cgColor
        userAvatar.layer.masksToBounds = true
        self.view.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(12)
            make.centerX.equalToSuperview()
            make.height.width.equalTo(120)
        }
        
        userName.text = "Example User"
        userName.font = setFontSize(size: 24, weight: .bold) //HurmeGeometricSans2
        userName.textColor = UIColor.init(hexString: "333333")
        userName.textAlignment = .center
        self.view.addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.top.equalTo(userAvatar.snp.bottom).offset(10)
            make.left.equalToSuperview().offset(20)
            make.right.equalToSuperview().offset(-20)
            make.height.equalTo(24)
        }
        
        statusContent.text = ""
        statusContent.font = setFontSize(size: 14, weight: .regular)
        statusContent.textColor = UIColor.init(hexString: "666666")
        statusContent.textAlignment = .center
        statusContent.numberOfLines = 0
        self.view.addSubview(statusContent)
        statusContent.snp.makeConstraints { (make) in
            make.top.equalTo(userName.snp.bottom).offset(10)
            make.width.equalToSuperview().offset(-40)
            make.centerX.equalToSuperview()
        }
        
        startTestBtn.setTitle(NSLocalizedString("kTakeMobilityTest", comment: "").uppercased(), for: .normal)
        startTestBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        startTestBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        startTestBtn.layer.cornerRadius = 20
        startTestBtn.addTarget(self, action: #selector(startMobilityTestButtonTapped), for: .touchUpInside)
        startTestBtn.isHidden = false
        self.view.addSubview(startTestBtn)
        startTestBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                  NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "1d00ff")!,
                                  NSAttributedString.Key.font : setFontSize(size: 14, weight: .semibold)] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: NSLocalizedString("kReTestBtn", comment: ""), attributes: underlineAttribute)
        
        reTestBtn.isHidden = true
        reTestBtn.setAttributedTitle(underlineAttributedString, for: .normal)
        reTestBtn.addTarget(self, action: #selector(reTestButtonTapped), for: .touchUpInside)
        self.view.addSubview(reTestBtn)
        reTestBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-10)
            make.centerX.equalToSuperview()
            make.height.equalTo(15)
        }
        
        mobilityPlanBtn.setTitle(NSLocalizedString("kGoToMobiliTyPlan", comment: "").uppercased(), for: .normal)
        mobilityPlanBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        mobilityPlanBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        mobilityPlanBtn.layer.cornerRadius = 20
        mobilityPlanBtn.addTarget(self, action: #selector(myMobilityPlanButtonTapped), for: .touchUpInside)
        mobilityPlanBtn.isHidden = true
        self.view.addSubview(mobilityPlanBtn)
        mobilityPlanBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(reTestBtn.snp.top).offset(-8)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }
        
        
        mobilityScrollView.showsHorizontalScrollIndicator = false
        self.view.addSubview(mobilityScrollView)
        mobilityScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(statusContent.snp.bottom).offset(10)
            make.bottom.equalTo(mobilityPlanBtn.snp.top)
            make.centerX.width.equalToSuperview()
        }
        
        trunkMoblity.setData(value: 0, name: "Trunk")
        trunkMoblity.tag = 1
        mobilityScrollView.addSubview(trunkMoblity)
        trunkMoblity.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview().offset(-90)
            make.height.equalTo(120)
            make.width.equalTo(86)
        }
        //  let painTouch = UITapGestureRecognizer.init(target: self, action: #selector(viewTapped))
        //   trunkMoblity.addGestureRecognizer(painTouch)
        
        shoulderMobility.setData(value: 0, name: "Shoulder")
        shoulderMobility.tag = 2
        mobilityScrollView.addSubview(shoulderMobility)
        shoulderMobility.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview().offset(90)
            make.height.equalTo(120)
            make.width.equalTo(86)
        }
        //   let shoulderTouch = UITapGestureRecognizer.init(target: self, action: #selector(viewTapped))
        //   shoulderMobility.addGestureRecognizer(shoulderTouch)
        
        hipMobility.setData(value: 0, name: "Hip")
        hipMobility.tag = 3
        mobilityScrollView.addSubview(hipMobility)
        hipMobility.snp.makeConstraints { (make) in
            make.top.equalTo(trunkMoblity.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(-90)
            make.height.equalTo(120)
            make.width.equalTo(86)
        }
        //  let hipTouch = UITapGestureRecognizer.init(target: self, action: #selector(viewTapped))
        //  hipMobility.addGestureRecognizer(hipTouch)
        
        ankleMobility.setData(value: 0, name: "Ankle")
        ankleMobility.tag = 4
        mobilityScrollView.addSubview(ankleMobility)
        ankleMobility.snp.makeConstraints { (make) in
            make.top.equalTo(trunkMoblity.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(90)
            make.height.equalTo(120)
            make.width.equalTo(86)
            make.bottom.equalToSuperview().offset(-10)
        }
        //   let ankleTouch = UITapGestureRecognizer.init(target: self, action: #selector(viewTapped))
        //   ankleMobility.addGestureRecognizer(ankleTouch)
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData),
                                               name: kMobilityNeedReloadNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadData),
                                               name: kUserProfileHasChangeNotification,
                                               object: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _NavController.setNavigationBarHidden(true, animated: false)
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            
            let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                      NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "e4e4e4")!,
                                      NSAttributedString.Key.font : setFontSize(size: 14, weight: .semibold)] as [NSAttributedString.Key : Any]
            let underlineAttributedString = NSAttributedString(string: NSLocalizedString("kReTestBtn", comment: ""), attributes: underlineAttribute)
            self.reTestBtn.setAttributedTitle(underlineAttributedString, for: .normal)
            
            self.startTestBtn.backgroundColor = UIColor.init(hexString: "e4e4e4")
            self.startTestBtn.setTitleColor(UIColor.init(hexString: "ffffff"), for: .normal)
            
            self.mobilityPlanBtn.backgroundColor = UIColor.init(hexString: "e4e4e4")
            self.mobilityPlanBtn.setTitleColor(UIColor.init(hexString: "ffffff"), for: .normal)
        }
        
        self.userMobilityRequest?.cancel()
        self.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    func clearDataView(view: TagView, clearData: Bool) {
        switch view {
        case .truck:
            if clearData {
                for item in _AppCoreData.listTrunkVideo {
                    item.selectedResult = 0
                }
            }
            
            if let mobilityVideo = _AppCoreData.listTrunkVideo.first {
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = 1
                mobilityVideoTest.tagView = .truck
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
            }
            break
        case .shoulder:
            if clearData {
                for item in _AppCoreData.listShouderVideo {
                    item.selectedResult = 0
                }
            }
            
            if let mobilityVideo = _AppCoreData.listShouderVideo.first {
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = 1
                mobilityVideoTest.tagView = .shoulder
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
            }
            break
        case .hip:
            if clearData {
                for item in _AppCoreData.listHipVideo {
                    item.selectedResult = 0
                }
            }
            
            if let mobilityVideo = _AppCoreData.listHipVideo.first {
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = 1
                mobilityVideoTest.tagView = .hip
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
            }
            break
        case .ankle:
            if clearData {
                for item in _AppCoreData.listAnkleVideo {
                    item.selectedResult = 0
                }
            }
            if let mobilityVideo = _AppCoreData.listAnkleVideo.first {
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = 1
                mobilityVideoTest.tagView = .ankle
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
            }
            break
        default:
            break
        }
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
    
    //MARK: - Buttons
    @objc func viewTapped(_ gestureRecognizer: UITapGestureRecognizer) {
        let tag = gestureRecognizer.view?.tag
        startMobilityTestViewTapped(view: tag!)
    }
    
    @objc func startMobilityTestButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        guard let userWatchLaterOption = UserDefaults.standard.value(forKey: kUserMobilityIntroSkip) as? Int else {
            let introVideos = VC_MobilityIntroVideo()
            _NavController.pushViewController(introVideos, animated: true)
            return
        }
        
        let currentDateInt = Int(Date().timeIntervalSince1970)
        
        if (currentDateInt - userWatchLaterOption) >= 86400 { // 1 days
            let introVideos = VC_MobilityIntroVideo()
            introVideos.clearData = true
            _NavController.pushViewController(introVideos, animated: true)
        } else {
            //Clean old test results
            for videoDataSource in _AppCoreData.listTrunkVideo {
                videoDataSource.selectedResult = 0
            }
            
            for videoDataSource in _AppCoreData.listShouderVideo {
                videoDataSource.selectedResult = 0
            }
            
            for videoDataSource in _AppCoreData.listHipVideo {
                videoDataSource.selectedResult = 0
            }
            
            for videoDataSource in _AppCoreData.listAnkleVideo {
                videoDataSource.selectedResult = 0
            }
            
            // Start progress
            _AppCoreData.returnVideo = nil
            if let mobilityVideo = _AppCoreData.getNextMobilityTestVideo() {
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = 1
                let totalPage               = _AppCoreData.getDataHip().count + _AppCoreData.getDataAnkle().count + _AppCoreData.getDataTruck().count + _AppCoreData.getDataShoulder().count
                mobilityVideoTest.totalPage = totalPage
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
            }
        }
    }
    
    @objc func startMobilityTestData() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        guard let userWatchLaterOption = UserDefaults.standard.value(forKey: kUserMobilityIntroSkip) as? Int else {
            let introVideos = VC_MobilityIntroVideo()
            if userResult.trunkPointAVG != 0 {
                for select in _AppCoreData.listTrunkVideo {
                    select.selectedResult = 1
                }
            }
            
            
            if userResult.shoulderPointAVG != 0 {
                for select in _AppCoreData.listShouderVideo {
                    select.selectedResult = 1
                }
            }
            
            
            if userResult.hipPointAVG != 0 {
                for select in _AppCoreData.listHipVideo {
                    select.selectedResult = 1
                }
            }
            
            
            if userResult.anklePointAVG != 0 {
                for select in _AppCoreData.listAnkleVideo {
                    select.selectedResult = 1
                }
            }
            _NavController.pushViewController(introVideos, animated: true)
            return
        }
        
        let currentDateInt = Int(Date().timeIntervalSince1970)
        
        if (currentDateInt - userWatchLaterOption) >= 86400 { // 1 days
            let introVideos = VC_MobilityIntroVideo()
            if userResult.trunkPointAVG != 0 {
                for select in _AppCoreData.listTrunkVideo {
                    select.selectedResult = 1
                }
            }
            
            
            if userResult.shoulderPointAVG != 0 {
                for select in _AppCoreData.listShouderVideo {
                    select.selectedResult = 1
                }
            }
            
            
            if userResult.hipPointAVG != 0 {
                for select in _AppCoreData.listHipVideo {
                    select.selectedResult = 1
                }
            }
            
            
            if userResult.anklePointAVG != 0 {
                for select in _AppCoreData.listAnkleVideo {
                    select.selectedResult = 1
                }
            }
            _NavController.pushViewController(introVideos, animated: true)
        } else {
            
            // Start progress
            _AppCoreData.returnVideo = nil
            if let mobilityVideo = _AppCoreData.getNextMobilityTestVideo() {
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = 1
                var totalPage               = _AppCoreData.getDataHip().count + _AppCoreData.getDataAnkle().count + _AppCoreData.getDataTruck().count + _AppCoreData.getDataShoulder().count
                if userResult.trunkPointAVG != 0 {
                    totalPage = totalPage - _AppCoreData.getDataTruck().count
                    for select in _AppCoreData.listTrunkVideo {
                        select.selectedResult = 1
                    }
                }
                
                
                if userResult.shoulderPointAVG != 0 {
                    totalPage = totalPage - _AppCoreData.getDataShoulder().count
                    for select in _AppCoreData.listShouderVideo {
                        select.selectedResult = 1
                    }
                }
                
                
                if userResult.hipPointAVG != 0 {
                    totalPage = totalPage - _AppCoreData.getDataHip().count
                    for select in _AppCoreData.listHipVideo {
                        select.selectedResult = 1
                    }
                }
                
                
                if userResult.anklePointAVG != 0 {
                    totalPage = totalPage - _AppCoreData.getDataAnkle().count
                    for select in _AppCoreData.listAnkleVideo {
                        select.selectedResult = 1
                    }
                }
                
                mobilityVideoTest.totalPage = totalPage
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
            }
        }
    }
    
    @objc func startMobilityTestViewTapped(view: Int) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        // Start progress
        switch view {
        case 1:
            if _AppCoreData.listTrunkVideo.count == 0 {
                return
            }
            
            if _AppCoreData.listTrunkVideo.first?.selectedResult == 1 {
                let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipInAppTitle", comment: ""),
                                                     message: NSLocalizedString("kRetestMobilityTestMessage", comment: ""),
                                                     preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                      style: .cancel) { (action) in
                    self.clearDataView(view: .truck, clearData: false)
                }
                let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                  style: .default) { (action) in
                    self.clearDataView(view: .truck, clearData: true)
                }
                
                alertVC.addAction(cancelAction)
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
            } else {
                self.clearDataView(view: .truck, clearData: false)
            }
            break
        case 2:
            if _AppCoreData.listShouderVideo.count == 0 {
                return
            }
            
            if _AppCoreData.listShouderVideo.first?.selectedResult == 1 {
                let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipInAppTitle", comment: ""),
                                                     message: NSLocalizedString("kRetestMobilityTestMessage", comment: ""),
                                                     preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                      style: .cancel) { (action) in
                    self.clearDataView(view: .shoulder, clearData: false)
                }
                let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                  style: .default) { (action) in
                    self.clearDataView(view: .shoulder, clearData: true)
                }
                
                alertVC.addAction(cancelAction)
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
            } else {
                self.clearDataView(view: .shoulder, clearData: false)
            }
            break
        case 3:
            if _AppCoreData.listHipVideo.count == 0 {
                return
            }
            if _AppCoreData.listHipVideo.first?.selectedResult == 1 {
                let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipInAppTitle", comment: ""),
                                                     message: NSLocalizedString("kRetestMobilityTestMessage", comment: ""),
                                                     preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                      style: .cancel) { (action) in
                    self.clearDataView(view: .hip, clearData: false)
                }
                let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                  style: .default) { (action) in
                    self.clearDataView(view: .hip, clearData: true)
                }
                
                alertVC.addAction(cancelAction)
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
            } else {
                self.clearDataView(view: .hip, clearData: false)
            }
            break
        case 4:
            if _AppCoreData.listAnkleVideo.count == 0 {
                return
            }
            
            if _AppCoreData.listAnkleVideo.first?.selectedResult == 1 {
                let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipInAppTitle", comment: ""),
                                                     message: NSLocalizedString("kRetestMobilityTestMessage", comment: ""),
                                                     preferredStyle: .alert)
                let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                      style: .cancel) { (action) in
                    self.clearDataView(view: .ankle, clearData: false)
                }
                let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                                  style: .default) { (action) in
                    self.clearDataView(view: .ankle, clearData: true)
                }
                
                alertVC.addAction(cancelAction)
                alertVC.addAction(okAction)
                
                self.present(alertVC, animated: true, completion: nil)
            } else {
                self.clearDataView(view: .ankle, clearData: false)
            }
            break
        default:
            break
        }
        
    }
    @objc func reTestButtonTapped() {
        //Same folow as new test
        
        self.startMobilityTestButtonTapped()
        
        //        let attributedStringTitle = NSAttributedString(string: NSLocalizedString("kHeyTitle", comment: ""), attributes: [
        //                                                    NSAttributedString.Key.font : setFontSize(size: 20, weight: .regular)])
        //
        //        let attributedStringMessage = NSAttributedString(string: NSLocalizedString("kMobilityRetestMessage", comment: ""), attributes: [
        //                                                    NSAttributedString.Key.font : setFontSize(size: 18, weight: .regular)])
        //        let alertVC = UIAlertController.init(title: "",
        //                                             message: "",
        //                                             preferredStyle: .alert)
        //        alertVC.setValue(attributedStringTitle, forKey: "attributedTitle")
        //        alertVC.setValue(attributedStringMessage, forKey: "attributedMessage")
        //        alertVC.addAction(UIAlertAction.init(title: NSLocalizedString("kMobilityRetestBeginingBtn", comment: ""),
        //                                             style: .default,
        //                                             handler: { (_) in
        //                                                alertVC.dismiss(animated: true, completion: nil)
        //                                                self.startMobilityTestData()
        //                                             }))
        //
        //        alertVC.addAction(UIAlertAction.init(title: NSLocalizedString("kMobilityRetestContinousBtn", comment: ""),
        //                                             style: .default,
        //                                             handler: { (_) in
        //                                                alertVC.dismiss(animated: true, completion: nil)
        //                                                self.startMobilityTestButtonTapped()
        //                                             }))
        //
        //        alertVC.addAction(UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
        //                                             style: .default,
        //                                             handler: { (_) in
        //                                                alertVC.dismiss(animated: true, completion: nil)
        //                                             }))
        //        UILabel.appearance(whenContainedInInstancesOf:
        //        [UIAlertController.self]).numberOfLines = 0
        //
        //        UILabel.appearance(whenContainedInInstancesOf:
        //        [UIAlertController.self]).lineBreakMode = .byWordWrapping
        //
        //        let newWidth = UIScreen.main.bounds.width * 0.90 - 270
        //
        //        // update width constraint value for main view
        //        if let viewWidthConstraint = alertVC.view.constraints.filter({ return $0.firstAttribute == .width }).first{
        //            viewWidthConstraint.constant = newWidth
        //        }
        //
        //        // update width constraint value for container view
        //        if let containerViewWidthConstraint = alertVC.view.subviews.first?.constraints.filter({ return $0.firstAttribute == .width }).first {
        //            containerViewWidthConstraint.constant = newWidth
        //        }
        //
        //        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func myMobilityPlanButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        if userResult.trunkPointAVG != 0 && userResult.shoulderPointAVG != 0 && userResult.hipPointAVG != 0 && userResult.anklePointAVG != 0  {
            let myMobilityPlan = VC_MainPageMyMobilityPlan()
            _NavController.pushViewController(myMobilityPlan, animated: true)
        } else {
            self.startMobilityTestData()
        }
    }
    
    //MARK: - Data
    
    @objc func reloadData() {
        
        // get user data
        let userProfile = _AppDataHandler.getUserProfile()
        if let userAvatarURL = URL(string: userProfile.userAvatar) {
            self.userAvatar.sd_setImage(with: userAvatarURL,
                                        placeholderImage: UIImage.init(named: "default_avatar"),
                                        options: [], context: nil)
        }
        
        self.userName.text = userProfile.firstName + " " + userProfile.lastName
        
        // get user mobility point
        self.loadingAnimation.isHidden = false
        self.userMobilityRequest = _AppDataHandler.getUserMobilityPoint { (isSuccess, error, userMobilityPoint) in
            
            
            if isSuccess {
                self.userResult.trunkPointAVG = userMobilityPoint.trunkPointAVG
                self.userResult.shoulderPointAVG = userMobilityPoint.shoulderPointAVG
                self.userResult.anklePointAVG = userMobilityPoint.anklePointAVG
                self.userResult.hipPointAVG = userMobilityPoint.hipPointAVG
                self.userResult.testDate = userMobilityPoint.testDate
                
                self.trunkMoblity.setData(value: userMobilityPoint.trunkPointAVG, name: "Trunk")
                self.shoulderMobility.setData(value: userMobilityPoint.shoulderPointAVG, name: "Shoulder")
                self.hipMobility.setData(value: userMobilityPoint.hipPointAVG, name: "Hip")
                self.ankleMobility.setData(value: userMobilityPoint.anklePointAVG, name: "Ankle")
                
                let testDateUnixTime = userMobilityPoint.testDate
                
                let testDate = Date.init(timeIntervalSince1970: TimeInterval(testDateUnixTime))
                let dateCounter = Date().timeIntervalSince(testDate)
                
                //                if true {//userMobilityPoint.testDate == 0 {
                if userMobilityPoint.testDate == 0 {
                    //User chưa làm test
                    self.startTestBtn.isHidden = false
                    self.mobilityPlanBtn.isHidden = true
                    self.reTestBtn.isHidden = true
                    
                    self.statusContent.text = NSLocalizedString("kTimelineNotTestingLabel", comment: "")
                    
                    self.reloadUI(trunkPointAVG: userMobilityPoint.trunkPointAVG, shoulderPointAVG: userMobilityPoint.shoulderPointAVG, hipPointAVG: userMobilityPoint.hipPointAVG, anklePointAVG: userMobilityPoint.anklePointAVG, on_process: userMobilityPoint.on_process)
                    if userMobilityPoint.on_process {
                        self.startTestBtn.isHidden = true
                        self.mobilityPlanBtn.isHidden = false
                        self.reTestBtn.isHidden = true
                    }
                    
                } else if dateCounter >= 1209600 { // 14 days
                    
                    self.statusContent.text = NSLocalizedString("kTimelineOver14DaysTestingLabel", comment: "")
                    
                    self.startTestBtn.isHidden = true
                    self.mobilityPlanBtn.isHidden = false
                    self.reTestBtn.isHidden = false
                    self.reloadUI(trunkPointAVG: userMobilityPoint.trunkPointAVG, shoulderPointAVG: userMobilityPoint.shoulderPointAVG, hipPointAVG: userMobilityPoint.hipPointAVG, anklePointAVG: userMobilityPoint.anklePointAVG, on_process: userMobilityPoint.on_process)
                    self.mobilityPlanBtn.setTitle(NSLocalizedString("kGoToMobiliTyPlan", comment: "").uppercased(), for: .normal)
                } else {
                    if userMobilityPoint.trunkPointAVG != 0 &&
                        userMobilityPoint.shoulderPointAVG != 0 &&
                        userMobilityPoint.hipPointAVG != 0 &&
                        userMobilityPoint.anklePointAVG != 0 {
                        var date = 14 - (dateCounter / 86400) //(1 days)
                        if date == 0 {
                            date = 1
                        }
                        let string = String(format: NSLocalizedString("kTimelineTestingLabel", comment: ""), date)
                        self.statusContent.text = string
                        
                        self.startTestBtn.isHidden = true
                        self.mobilityPlanBtn.isHidden = false
                        self.reTestBtn.isHidden = true
                        self.mobilityPlanBtn.setTitle(NSLocalizedString("kGoToMobiliTyPlan", comment: "").uppercased(), for: .normal)
                    } else {
                        self.startTestBtn.isHidden = true
                        self.mobilityPlanBtn.isHidden = false
                        self.reTestBtn.isHidden = true
                    }
                    self.reloadUI(trunkPointAVG: userMobilityPoint.trunkPointAVG, shoulderPointAVG: userMobilityPoint.shoulderPointAVG, hipPointAVG: userMobilityPoint.hipPointAVG, anklePointAVG: userMobilityPoint.anklePointAVG, on_process: userMobilityPoint.on_process)

                    if dateCounter >= 1209600 {
                        self.mobilityPlanBtn.setTitle(NSLocalizedString("kGoToMobiliTyPlan", comment: "").uppercased(), for: .normal)
                    }
                }
                self.loadingAnimation.isHidden = true //update xong text mới tắt spinner
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
        
        //Get list mobility video
        _AppDataHandler.getListMobilityVideoSource { (isSucces, error) in
            print(error)
        }
    }
    //MARK: - Update UI
    func reloadUI(trunkPointAVG: Double, shoulderPointAVG: Double, hipPointAVG: Double, anklePointAVG: Double, on_process: Bool) {
        for subView in mobilityScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        let truck = VW_MobilityCircle()
        mobilityScrollView.addSubview(truck)
        truck.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview().offset(-90)
            make.height.equalTo(120)
            make.width.equalTo(86)
        }
        
        let shoulder = VW_MobilityCircle()
        mobilityScrollView.addSubview(shoulder)
        shoulder.snp.remakeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview().offset(90)
            make.height.equalTo(120)
            make.width.equalTo(86)
        }
        
        let hip = VW_MobilityCircle()
        mobilityScrollView.addSubview(hip)
        hip.snp.remakeConstraints { (make) in
            make.top.equalTo(truck.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(-90)
            make.height.equalTo(120)
            make.width.equalTo(86)
        }
        
        let ankle = VW_MobilityCircle()
        mobilityScrollView.addSubview(ankle)
        ankle.snp.remakeConstraints { (make) in
            make.top.equalTo(truck.snp.bottom).offset(20)
            make.centerX.equalToSuperview().offset(90)
            make.height.equalTo(120)
            make.width.equalTo(86)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        truck.setData(value: trunkPointAVG, name: "Trunk")
        shoulder.setData(value: shoulderPointAVG, name: "Shoulder")
        hip.setData(value: hipPointAVG, name: "Hip")
        ankle.setData(value: anklePointAVG, name: "Ankle")
        
        if on_process {
            self.mobilityPlanBtn.setTitle(NSLocalizedString("kMobilityPlanContinueBtn", comment: "").uppercased(), for: .normal)
            
            truck.progressBar.progressColor = .lightGray
            truck.progressBar.fontColor = .lightGray
            
            shoulder.progressBar.progressColor = .lightGray
            shoulder.progressBar.fontColor = .lightGray
            
            hip.progressBar.progressColor = .lightGray
            hip.progressBar.fontColor = .lightGray
            
            ankle.progressBar.progressColor = .lightGray
            ankle.progressBar.fontColor = .lightGray
            
            if trunkPointAVG == 0 {
                truck.mobilityName.text = "Trunk \n" + NSLocalizedString("kMobilityTestIncomplete", comment: "")
                for videoDataSource in _AppCoreData.listTrunkVideo {
                    videoDataSource.selectedResult = 0
                }
            }
            if shoulderPointAVG == 0 {
                shoulder.mobilityName.text = "Shoulder \n" + NSLocalizedString("kMobilityTestIncomplete", comment: "")
                for videoDataSource in _AppCoreData.listShouderVideo {
                    videoDataSource.selectedResult = 0
                }
            }
            
            if hipPointAVG == 0 {
                hip.mobilityName.text = "Hip \n" + NSLocalizedString("kMobilityTestIncomplete", comment: "")
                for videoDataSource in _AppCoreData.listHipVideo {
                    videoDataSource.selectedResult = 0
                }
            }
            
            if anklePointAVG == 0 {
                ankle.mobilityName.text = "Ankle \n" + NSLocalizedString("kMobilityTestIncomplete", comment: "")
                for videoDataSource in _AppCoreData.listAnkleVideo {
                    videoDataSource.selectedResult = 0
                }
            }
        }
    }
}
