//
//  VC_MainPageActivity.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import Alamofire

class VC_MainPageWorkouts: UIViewController, UIScrollViewDelegate,
                           VW_WorkoutCategoryViewDelegate, VideoCellDelegate {
    
    let pageScroll          = UIScrollView()
    
    let warmUpView          = UIScrollView()
    let workoutScrollView   = UIScrollView()
    let sportScrollView     = UIScrollView()
    let archetypeScrollView = UIScrollView()
    
    let loadingAnimation    = VW_LoadingAnimation()
    var loadingDataCount    = 0
    
    private var listWorkoutsRequests: [Request] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
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
        pageScroll.delegate = self
        pageScroll.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.bottom.centerX.width.equalToSuperview()
        }
        
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kWorkouts", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        //MARK: Warm Up
        let warmUpTitle = UILabel()
        warmUpTitle.text = NSLocalizedString("kWarmUpTitle", comment: "")
        warmUpTitle.font = setFontSize(size: 18, weight: .bold)
        warmUpTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(warmUpTitle)
        warmUpTitle.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        warmUpView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(warmUpView)
        warmUpView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(warmUpTitle.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        
        self.reloadWarmUp(collections: [])
        //MARK: Workouts
        let workoutTitle = UILabel()
        workoutTitle.text = NSLocalizedString("kByWorkout", comment: "")
        workoutTitle.font = setFontSize(size: 18, weight: .bold)
        workoutTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(workoutTitle)
        workoutTitle.snp.makeConstraints { (make) in
            make.top.equalTo(warmUpView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        let workoutNextIcon = UIImageView()
        workoutNextIcon.image = UIImage.init(named: "view_all_icon")
        self.pageScroll.addSubview(workoutNextIcon)
        workoutNextIcon.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(workoutTitle)
            make.width.equalTo(12)
            make.height.equalTo(10)
        }
        
        let workoutBtn  = UIButton()
        workoutBtn.tag = 1
        workoutBtn.setTitle(NSLocalizedString("kViewAll", comment: ""), for: .normal)
        workoutBtn.setTitleColor(UIColor.init(hexString: "4a4a4a"), for: .normal)
        workoutBtn.titleLabel?.font = setFontSize(size: 16, weight: .regular) // UIFont.init(name: "HurmeGeometricSans1-Light", size: 16)
        workoutBtn.addTarget(self, action: #selector(viewAllButtonTapped(btn:)), for: .touchUpInside)
        self.pageScroll.addSubview(workoutBtn)
        workoutBtn.snp.makeConstraints { (make) in
            make.right.equalTo(workoutNextIcon.snp.left).offset(-5)
            make.centerY.equalTo(workoutTitle)
        }
        
        workoutScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(workoutScrollView)
        workoutScrollView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(workoutTitle.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        
        self.reloadWorkouts(collections: [])
        
        //MARK: Sports
        let sportTitle = UILabel()
        sportTitle.text = NSLocalizedString("kBySport", comment: "")
        sportTitle.font = setFontSize(size: 18, weight: .bold)
        sportTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(sportTitle)
        sportTitle.snp.makeConstraints { (make) in
            make.top.equalTo(workoutScrollView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        let sportNextIcon = UIImageView()
        sportNextIcon.image = UIImage.init(named: "view_all_icon")
        self.pageScroll.addSubview(sportNextIcon)
        sportNextIcon.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(sportTitle)
            make.width.equalTo(12)
            make.height.equalTo(10)
        }
        
        let sportBtn  = UIButton()
        sportBtn.tag = 2
        sportBtn.setTitle(NSLocalizedString("kViewAll", comment: ""), for: .normal)
        sportBtn.setTitleColor(UIColor.init(hexString: "4a4a4a"), for: .normal)
        sportBtn.titleLabel?.font = setFontSize(size: 16, weight: .regular) //UIFont.init(name: "HurmeGeometricSans1-Light", size: 16)
        sportBtn.addTarget(self, action: #selector(viewAllButtonTapped(btn:)), for: .touchUpInside)
        self.pageScroll.addSubview(sportBtn)
        sportBtn.snp.makeConstraints { (make) in
            make.right.equalTo(sportNextIcon.snp.left).offset(-5)
            make.centerY.equalTo(sportTitle)
        }
        
        sportScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(sportScrollView)
        sportScrollView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(sportTitle.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        
        self.reloadSports(collections: [])
        
        //MARK: Archetype
        let archetypeTitle = UILabel()
        archetypeTitle.text = NSLocalizedString("kByArchetype", comment: "")
        archetypeTitle.font = setFontSize(size: 18, weight: .bold) 
        archetypeTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(archetypeTitle)
        archetypeTitle.snp.makeConstraints { (make) in
            make.top.equalTo(sportScrollView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        let archetypeNextIcon = UIImageView()
        archetypeNextIcon.image = UIImage.init(named: "view_all_icon")
        self.pageScroll.addSubview(archetypeNextIcon)
        archetypeNextIcon.snp.makeConstraints { (make) in
            make.right.centerY.equalTo(archetypeTitle)
            make.width.equalTo(12)
            make.height.equalTo(10)
        }
        
        let archetypeBtn  = UIButton()
        archetypeBtn.tag = 3
        archetypeBtn.setTitle(NSLocalizedString("kViewAll", comment: ""), for: .normal)
        archetypeBtn.setTitleColor(UIColor.init(hexString: "4a4a4a"), for: .normal)
        archetypeBtn.titleLabel?.font = setFontSize(size: 16, weight: .regular)//UIFont.init(name: "HurmeGeometricSans1-Light", size: 16)
        archetypeBtn.addTarget(self, action: #selector(viewAllButtonTapped(btn:)), for: .touchUpInside)
        self.pageScroll.addSubview(archetypeBtn)
        archetypeBtn.snp.makeConstraints { (make) in
            make.right.equalTo(archetypeNextIcon.snp.left).offset(-5)
            make.centerY.equalTo(archetypeTitle)
        }
        
        archetypeScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(archetypeScrollView)
        archetypeScrollView.snp.makeConstraints { (make) in
            make.width.centerX.equalToSuperview()
            make.top.equalTo(archetypeTitle.snp.bottom).offset(10)
            make.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-30)
        }
        
        self.reloadArchetypes(collections: [])
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _NavController.setNavigationBarHidden(true, animated: false)
        
        for request in self.listWorkoutsRequests {
            request.cancel()
        }
        self.reloadData()
    }
    
    //MARK: - Function
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
    
    //MARK: - Button
    
    @objc func viewAllButtonTapped(btn: UIButton) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let categoryVC = VC_MainPageWorkoutCategory()
        categoryVC.collectionType = CollectionType(rawValue: btn.tag) ?? CollectionType.workout
        
        switch btn.tag {
        case 1:
            //View all workouts
            categoryVC.thumbnailImage.image = UIImage.init(named: "workout_category_thumbnail_image")
            categoryVC.workoutTitle.text = NSLocalizedString("kWorkout", comment: "")
            break
        case 2:
            //View all sport
            categoryVC.thumbnailImage.image = UIImage.init(named: "sport_category_thumbnail_image")
            categoryVC.workoutTitle.text = NSLocalizedString("kSport", comment: "")
            break
        case 3:
            //View all archetype
            categoryVC.thumbnailImage.image = UIImage.init(named: "archetype_category_thumbnail_image")
            categoryVC.workoutTitle.text = NSLocalizedString("kArchetype", comment: "")
            break
        default:
            break
        }
        
        
        _NavController.pushViewController(categoryVC, animated: true)
    }
    
    @objc func selectCategoryID(id: String) {
        
    }
    
    //MARK: - Reload Data
    
    func reloadData() {
        
        self.loadingAnimation.isHidden = false
        if let warmUpRequest = _AppDataHandler.getListWarmUp (limit: 3, page: 1, completion: {(isSucess, error, listWarmUp) in
            self.checkLoadingAnimation()
            if isSucess {
                self.reloadWarmUp(collections: listWarmUp)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        })
        {
            self.listWorkoutsRequests.append(warmUpRequest)
        }
        
        if let workoutsRequest = _AppDataHandler.getWorkoutCategories(limit: 3,
                                                                      page: 1, completion: { (isSucess, error, listCollection) in
                                                                        self.checkLoadingAnimation()
                                                                        
                                                                        if isSucess {
                                                                            self.reloadWorkouts(collections: listCollection)
                                                                        } else {
                                                                            _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                                                                        }
                                                                      })
        {
            self.listWorkoutsRequests.append(workoutsRequest)
        }
        
        if let sportsRequest = _AppDataHandler.getSportCategories(limit: 3,
                                                                  page: 1, completion: { (isSucess, error, listCollection) in
                                                                    self.checkLoadingAnimation()
                                                                    
                                                                    if isSucess {
                                                                        self.reloadSports(collections: listCollection)
                                                                    } else {
                                                                        _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                                                                    }
                                                                  })
        {
            self.listWorkoutsRequests.append(sportsRequest)
        }
        
        if let archetypeRequest = _AppDataHandler.getArchetypeCategories(limit: 3,
                                                                         page: 1, completion: { (isSucess, error, listCollection) in
                                                                            self.checkLoadingAnimation()
                                                                            
                                                                            if isSucess {
                                                                                self.reloadArchetypes(collections: listCollection)
                                                                            } else {
                                                                                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                                                                            }
                                                                         })
        {
            self.listWorkoutsRequests.append(archetypeRequest)
        }
    }
    
    func checkLoadingAnimation() {
        self.loadingDataCount += 1
        if self.loadingDataCount == 4 {
            self.loadingDataCount = 0
            self.loadingAnimation.isHidden = true
        }
    }
    
    func reloadWarmUp(collections: [VideoDataSource]) {
        // Remove all old cell
        for subView in warmUpView.subviews {
            subView.removeFromSuperview()
        }
        
        // Reload scrollView
        let size = CGSize(width: 250, height: 140)
        var index = 0
        
        for collectionData in collections {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_RetangleVideoViewCellTitleOnly.init(frame: frame)
            cell.delegate = self
            cell.reloadLayout()
//            if _AppDataHandler.getUserProfile().isFreemiumUser() {
//                cell.showOpacityView()
//            }
            cell.setVideoDataSource(videoData: collectionData)
            warmUpView.addSubview(cell)
            
            index += 1
        }
        
        warmUpView.contentSize = CGSize.init(width: CGFloat(collections.count)*(size.width + 10) + 30, height: size.height)
    }
    
    func reloadWorkouts(collections: [CategoryDataSource]) {
        // Remove all old cell
        for subView in workoutScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        // Reload scrollView
        let size = CGSize(width: 250, height: 140)
        var index = 0
        
        for collectionData in collections {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_WorkoutCategoryView.init(frame: frame)
            cell.delegate = self
            workoutScrollView.addSubview(cell)
            if !collectionData.categoryTitle.contains("Squat") {
                if _AppDataHandler.getUserProfile().isFreemiumUser() {
                    cell.showOpacityView()
                }
            }
            cell.setCollectionData(data: collectionData)
            
            index += 1
        }
        
        workoutScrollView.contentSize = CGSize.init(width: CGFloat(collections.count)*(size.width + 10) + 30, height: size.height)
    }
    
    func reloadSports(collections: [CategoryDataSource]) {
        // Remove all old cell
        for subView in sportScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        // Reload scrollView
        let size = CGSize(width: 250, height: 140)
        var index = 0
        
        for collectionData in collections {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_WorkoutCategoryView.init(frame: frame)
            cell.delegate = self
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                cell.showOpacityView()
            }
            sportScrollView.addSubview(cell)
            
            cell.setCollectionData(data: collectionData)
            
            index += 1
        }
        
        sportScrollView.contentSize = CGSize.init(width: CGFloat(collections.count)*(size.width + 10) + 30, height: size.height)
    }
    
    func reloadArchetypes(collections: [CategoryDataSource]) {
        // Remove all old cell
        for subView in archetypeScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        // Reload  scrollView
        let size = CGSize(width: 250, height: 140)
        var index = 0
        
        for collectionData in collections {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_WorkoutCategoryView.init(frame: frame)
            cell.delegate = self
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                cell.showOpacityView()
            }
            archetypeScrollView.addSubview(cell)
            
            cell.setCollectionData(data: collectionData)
            
            index += 1
        }
        
        archetypeScrollView.contentSize = CGSize.init(width: CGFloat(collections.count)*(size.width + 10) + 30, height: size.height)
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        let videoVC = VC_SubPageVideoPlayer()
        videoVC.setVideoDataSource(newVideoDataSource: videoData)
        _NavController.pushViewController(videoVC, animated: true)
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        
        //        if _AppDataHandler.getUserProfile().isFreemiumUser() {
        //            self.dismiss(animated: true, completion: nil)
        //            _NavController.presentAlertForFreemium()
        //            return
        //        }
        //
        //        _AppVideoManager.requestDownloadVideo(videoData: videoData)
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
    }
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let offSet = scrollView.contentOffset
        
        if offSet.y >= 34 {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 1.5
            fadeTextAnimation.type = .fade
            
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
        } else {
            let fadeTextAnimation = CATransition()
            fadeTextAnimation.duration = 1.5
            fadeTextAnimation.type = .fade
            
            navigationController?.navigationBar.layer.add(fadeTextAnimation, forKey: "fadeText")
            navigationItem.title = ""
        }
    }
    
    //MARK: - VW_WorkoutCategoryViewDelegate
    func didSelectCategory(selectedCategory: CategoryDataSource) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() && !(selectedCategory.categoryTitle.contains("Squat")) {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let categoryDetailVC = VC_MainPageWorkoutDetails()
        categoryDetailVC.setDataSource(newData: selectedCategory)
        _NavController.pushViewController(categoryDetailVC, animated: true)
    }
}
