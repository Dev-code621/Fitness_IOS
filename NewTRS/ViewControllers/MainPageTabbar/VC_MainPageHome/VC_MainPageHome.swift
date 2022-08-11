//
//  VC_MainPageHome.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageHome: UIViewController,
                        VideoCellDelegate,
                        HomePageBonusContentCellDelegate, WorkoutSportCellDelegate,
                        UIScrollViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let pageScroll          = UIScrollView()
    
    private let dailyMaintenanceVideo       = VW_RetangleVideoViewCellTitleOnly()
    private let mobilityView                = UIView()
    private let gotoMyMobility              = UIButton()
    private let viewMobilityPlanBtn         = UIButton()
    private var workoutScrollView           = UIScrollView()
    private let painView                    = VW_FrontView()
    private var bonusContentScrollView      = UIScrollView()
    private var upSellCollectionView        : UICollectionView?
    
    let loadingAnimation            = VW_LoadingAnimation()
    var loadingAnimationCount       = 0
    
    var currentPageUpSell       : Int = 1
    var isLoadingUpSell         : Bool = false
    private var pagingUpSell    : PagingDataSource?
    private var listUpSell      = [UpSellDataSource]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let closeBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(closeButtonTapped))
        self.navigationItem.leftBarButtonItem = closeBtn
        
        //MARK: Contents
        pageScroll.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.bottom.centerX.width.equalToSuperview()
        }
        
        //MARK: - Update title
        let dattributedString = NSMutableAttributedString(string: NSLocalizedString("kHomePageExtraTitle", comment: ""), attributes: [
            .font: setFontSize(size: 14, weight: .regular),
          .foregroundColor: UIColor.init(hexString: "333333")!,
          .kern: 0.2
        ])
        dattributedString.addAttribute(.font, value: setFontSize(size: 18, weight: .bold), range: NSRange(location: 13, length: dattributedString.length - 13))
        
        let extraTitle  = UILabel()
        extraTitle.attributedText = dattributedString
        extraTitle.textAlignment = .center
        extraTitle.numberOfLines = 0
        self.pageScroll.addSubview(extraTitle)
        extraTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-40)
        }
        
        let extraDetail = UILabel()
        extraDetail.text = NSLocalizedString("kHomePageExtraMessage", comment: "")
        extraDetail.numberOfLines = 0
        extraDetail.textAlignment = .center
        extraDetail.font = setFontSize(size: 12, weight: .regular)
        extraDetail.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(extraDetail)
        extraDetail.snp.makeConstraints { (make) in
            make.top.equalTo(extraTitle.snp.bottom).offset(10)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-40)
        }
        
        //MARK:  ========== Daily maintenence ========
        let dailyMaintenance = UILabel()
        dailyMaintenance.text = NSLocalizedString("kDailyMaintenance", comment: "")
        dailyMaintenance.font = setFontSize(size: 18, weight: .bold)
        dailyMaintenance.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(dailyMaintenance)
        dailyMaintenance.snp.makeConstraints { (make) in
            make.top.equalTo(extraDetail.snp.bottom).offset(20)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        dailyMaintenanceVideo.videoTitleLabel.font = setFontSize(size: 24, weight: .bold)
        dailyMaintenanceVideo.delegate = self
        self.pageScroll.addSubview(dailyMaintenanceVideo)
        dailyMaintenanceVideo.snp.makeConstraints { (make) in
            make.top.equalTo(dailyMaintenance.snp.bottom).offset(10)
            make.width.equalTo(self.view).offset(-40)
            make.centerX.equalToSuperview()
            make.height.equalTo(dailyMaintenanceVideo.snp.width).multipliedBy(0.5625)
        }
        
        //MARK:  ========== Workouts ========
        let prepRecoverTitle = UILabel()
        prepRecoverTitle.text = NSLocalizedString("kPrepRecoverTitle", comment: "")
        prepRecoverTitle.font = setFontSize(size: 18, weight: .bold)
        prepRecoverTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(prepRecoverTitle)
        prepRecoverTitle.snp.makeConstraints { (make) in
            make.top.equalTo(dailyMaintenanceVideo.snp.bottom).offset(30)
            make.left.equalTo(dailyMaintenanceVideo).offset(0)
            make.height.equalTo(18)
        }
        
        workoutScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(workoutScrollView)
        workoutScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(prepRecoverTitle.snp.bottom).offset(10)
            make.left.right.equalTo(dailyMaintenanceVideo)
            make.height.equalTo(140)
        }
        
        self.reloadListWorkout()
        
        //MARK: ========== Mobility ========
        let mobilityTitle = UILabel()
        mobilityTitle.text = NSLocalizedString("kMobility", comment: "")
        mobilityTitle.font = setFontSize(size: 18, weight: .bold)
        mobilityTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(mobilityTitle)
        mobilityTitle.snp.makeConstraints { (make) in
            make.top.equalTo(workoutScrollView.snp.bottom).offset(30)
            make.left.equalTo(dailyMaintenanceVideo).offset(0)
            make.height.equalTo(18)
        }
        
        self.pageScroll.addSubview(mobilityView)
        mobilityView.snp.makeConstraints { (make) in
            make.top.equalTo(mobilityTitle.snp.bottom).offset(15)
            make.width.equalTo(self.view).offset(-25)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(mobilityView.snp.width).multipliedBy(0.25)
        }
        self.reloadMobilityView(mobilityData: UserMobilityDataSource.init(JSONString: "{}")!)
        
        gotoMyMobility.backgroundColor = UIColor.init(hexString: "2d00ff")
        gotoMyMobility.setTitle(NSLocalizedString("kTakeMobilityTest", comment: "").uppercased(), for: .normal)
        gotoMyMobility.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        gotoMyMobility.layer.cornerRadius = 20
        gotoMyMobility.addTarget(self, action: #selector(myMobilityPageButtonTapped), for: .touchDown)
        self.pageScroll.addSubview(gotoMyMobility)
        gotoMyMobility.snp.makeConstraints { (make) in
            make.top.equalTo(mobilityView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-40)
        }
        
        viewMobilityPlanBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        viewMobilityPlanBtn.setTitle(NSLocalizedString("kGoToMobiliTyPlan", comment: "").uppercased(), for: .normal)
        viewMobilityPlanBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        viewMobilityPlanBtn.layer.cornerRadius = 20
        viewMobilityPlanBtn.addTarget(self, action: #selector(myMobilityPlanTapped), for: .touchDown)
        self.pageScroll.addSubview(viewMobilityPlanBtn)
        viewMobilityPlanBtn.snp.makeConstraints { (make) in
            make.top.equalTo(mobilityView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-40)
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(reloadMobilityData),
                                               name: kMobilityNeedReloadNotification,
                                               object: nil)
        
        //MARK: ========== Pain ========
        
        let painTitle = UILabel()
        painTitle.text = NSLocalizedString("kPainTitle", comment: "")
        painTitle.font = setFontSize(size: 18, weight: .bold)
        painTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(painTitle)
        painTitle.snp.makeConstraints { (make) in
            make.top.equalTo(gotoMyMobility.snp.bottom).offset(30)
            make.left.equalTo(dailyMaintenanceVideo).offset(0)
            make.height.equalTo(18)
        }
        
        self.pageScroll.addSubview(painView)
        painView.snp.makeConstraints { (make) in
            make.top.equalTo(painTitle.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(painView.snp.width).multipliedBy(1.601)
        }
        
        let handleView = UIView()
        painView.addSubview(handleView)
        handleView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let painTouch = UITapGestureRecognizer.init(target: self, action: #selector(painViewTapped))
        handleView.addGestureRecognizer(painTouch)
        
//        let searchBtn = UIButton()
//        searchBtn.backgroundColor = .white
//        searchBtn.layer.cornerRadius = 18
//        searchBtn.layer.borderWidth = 0.5
//        searchBtn.layer.borderColor = UIColor.init(hexString: "1d02ff")!.cgColor
//        searchBtn.addTarget(self, action: #selector(searchTapped), for: .touchUpInside)
//        self.pageScroll.addSubview(searchBtn)
//        searchBtn.snp.makeConstraints { (make) in
//            make.top.equalTo(painView.snp.bottom).offset(20)
//            make.centerX.equalToSuperview()
//            make.width.equalTo(self.view).offset(-40)
//            make.height.equalTo(36)
//        }
//
//        let searchLogo = UIImageView()
//        searchLogo.image = UIImage(named: "search_icon")
//        searchLogo.contentMode = .scaleAspectFit
//        searchBtn.addSubview(searchLogo)
//        searchLogo.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalToSuperview().offset(20)
//            make.width.height.equalTo(12)
//        }
//
//        let searchTitle = UILabel()
//        searchTitle.text = NSLocalizedString("kSearchTextField", comment: "")
//        searchTitle.font = setFontSize(size: 14, weight: .regular)
//        searchTitle.textColor = UIColor.init(hexString: "929292")
//        searchBtn.addSubview(searchTitle)
//        searchTitle.snp.makeConstraints { (make) in
//            make.centerY.equalToSuperview()
//            make.left.equalTo(searchLogo.snp.right).offset(6)
//        }
        
        //MARK: ========== Bonus Content ========
        let bonusContentTitle = UILabel()
        bonusContentTitle.text = NSLocalizedString("kBonusContent", comment: "")
        bonusContentTitle.font = setFontSize(size: 18, weight: .bold)
        bonusContentTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(bonusContentTitle)
        bonusContentTitle.snp.makeConstraints { (make) in
            make.top.equalTo(handleView.snp.bottom).offset(20)
            make.left.equalTo(dailyMaintenanceVideo).offset(0)
            make.height.equalTo(18)
        }
        
        bonusContentScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(bonusContentScrollView)
        bonusContentScrollView.snp.makeConstraints { (make) in
            make.left.right.equalTo(dailyMaintenanceVideo)
            make.top.equalTo(bonusContentTitle.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        
        self.reloadListBonusContent(bonusContents:[])
        
        //MARK: ========== Upsell ========
        let upsellTitle = UILabel()
        upsellTitle.text = NSLocalizedString("kUpsellTitle", comment: "")
        upsellTitle.font = setFontSize(size: 18, weight: .bold)
        upsellTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(upsellTitle)
        upsellTitle.snp.makeConstraints { (make) in
            make.top.equalTo(bonusContentScrollView.snp.bottom).offset(30)
            make.left.equalTo(dailyMaintenanceVideo).offset(0)
            make.height.equalTo(18)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 0, left: 20, bottom: 10, right: 20)
        layout.scrollDirection = .horizontal
        
        self.upSellCollectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        self.upSellCollectionView?.showsHorizontalScrollIndicator = false
        self.upSellCollectionView?.backgroundColor = .white
        self.upSellCollectionView?.register(VW_HomePageUpSellCell.self, forCellWithReuseIdentifier: "upSellCell")
        self.upSellCollectionView?.dataSource = self
        self.upSellCollectionView?.delegate = self
        pageScroll.addSubview(upSellCollectionView!)
        upSellCollectionView?.snp.makeConstraints({ (make) in
            make.left.right.equalTo(dailyMaintenanceVideo)
            make.top.equalTo(upsellTitle.snp.bottom).offset(10)
            make.height.equalTo(155)
            make.bottom.equalToSuperview().offset(-17)
        })
        
        //MARK: ========== Loading Animation ========
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _NavController.setNavigationBarHidden(true, animated: false)
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            self.gotoMyMobility.backgroundColor = UIColor.init(hexString: "e4e4e4")
            self.gotoMyMobility.setTitleColor(UIColor.init(hexString: "ffffff"), for: .normal)
        }
        
        self.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Navigation Functions
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func myMobilityPageButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let tabbarVC = viewVCs.first as! MainPageTabbar
            tabbarVC.selectedIndex = 3
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func myMobilityPlanTapped() {
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let myMobilityPlan = VC_MainPageMyMobilityPlan()
        _NavController.pushViewController(myMobilityPlan, animated: false)
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func painViewTapped() {
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let tabbarVC = viewVCs.first as! MainPageTabbar
            tabbarVC.selectedIndex = 1
        }
        
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func searchTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let searchVC = VC_MainPageSearch()
        _NavController.pushViewController(searchVC, animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - Datas
    func reloadData() {
        
        self.loadingAnimationCount = 0
        self.loadingAnimation.isHidden = false
        
        //Feature Videos
        _AppDataHandler.getDailyPageFeatureVideos(filterBy: 0) { (isSucess, error, listVideos) in
            self.checkLoadingAnimation()
            
            if isSucess {
                self.reloadListFeatureData(videos: listVideos)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
        self.reloadMobilityData()
        
        _AppDataHandler.getAllUpSells(page: currentPageUpSell, limit: 20) { (isSuccess, error, paging, listUpSells) in
            self.checkLoadingAnimation()
            
            if isSuccess {
                self.isLoadingUpSell = false
                if self.pagingUpSell?.currentPage != self.currentPageUpSell && self.pagingUpSell?.currentPage != nil {
                    var list = self.listUpSell
                    list.append(contentsOf: listUpSells)
                    self.listUpSell = list
                } else {
                    self.listUpSell = listUpSells
                }
                self.pagingUpSell = paging
                self.upSellCollectionView?.reloadData()
                
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
         let _ = _AppDataHandler.getListBonus { (isSuccess, error) in
            self.checkLoadingAnimation()
            
            if isSuccess {
                let listBonusContent = _AppCoreData.listBonusData
                self.reloadListBonusContent(bonusContents: listBonusContent)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
    
    func reloadDailyUpSell() {
        
        self.loadingAnimation.isHidden = false
        
        _AppDataHandler.getAllUpSells(page: currentPageUpSell, limit: 20) { (isSuccess, error, paging, listUpSells) in
            
            if isSuccess {
                self.loadingAnimation.isHidden = true
                self.isLoadingUpSell = false
                if self.pagingUpSell?.currentPage != self.currentPageUpSell && self.pagingUpSell?.currentPage != nil {
                    var list = self.listUpSell
                    list.append(contentsOf: listUpSells)
                    self.listUpSell = list
                } else {
                    self.listUpSell = listUpSells
                }
                self.pagingUpSell = paging
                self.upSellCollectionView?.reloadData()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }

    }
    
    func checkLoadingAnimation() {
        self.loadingAnimationCount += 1
        if self.loadingAnimationCount == 4 {
            self.loadingAnimation.isHidden = true
        }
    }
    
    func reloadListFeatureData(videos: [VideoDataSource]) {
        
        // Reload main Video Data
        if let videoFirstData = videos.first {
            dailyMaintenanceVideo.setVideoDataSource(videoData: videoFirstData)
            dailyMaintenanceVideo.reloadLayout()
        } else {
            //
        }
    }
    
    @objc func reloadMobilityData() {
        let _ = _AppDataHandler.getUserMobilityPoint { (isSucess, error, userMobilityPoint) in
            self.checkLoadingAnimation()
            
            if isSucess {
                self.reloadMobilityView(mobilityData: userMobilityPoint)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
    
    func reloadMobilityView(mobilityData: UserMobilityDataSource) {
        
        //Remove all subviews
        for view in mobilityView.subviews {
            view.removeFromSuperview()
        }
        
        let trunkCell = VW_MobilityCircle()
        trunkCell.setData(value: mobilityData.trunkPointAVG, name: "Trunk")
        mobilityView.addSubview(trunkCell)
        trunkCell.snp.makeConstraints { (make) in
            make.top.left.bottom.equalToSuperview()
            make.width.equalToSuperview().multipliedBy(0.25).offset(-15)
        }
        
        let shoulderCell = VW_MobilityCircle()
        shoulderCell.setData(value: mobilityData.shoulderPointAVG, name: "Shoulder")
        mobilityView.addSubview(shoulderCell)
        shoulderCell.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(trunkCell.snp.right).offset(15)
            make.width.equalToSuperview().multipliedBy(0.25).offset(-15)
        }
        
        let hipCell = VW_MobilityCircle()
        hipCell.setData(value: mobilityData.hipPointAVG, name: "Hip")
        mobilityView.addSubview(hipCell)
        hipCell.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(shoulderCell.snp.right).offset(15)
            make.width.equalToSuperview().multipliedBy(0.25).offset(-15)
        }
        
        let ankleCell = VW_MobilityCircle()
        ankleCell.setData(value: mobilityData.anklePointAVG, name: "Ankle")
        mobilityView.addSubview(ankleCell)
        ankleCell.snp.makeConstraints { (make) in
            make.top.bottom.equalToSuperview()
            make.left.equalTo(hipCell.snp.right).offset(15)
            make.width.equalToSuperview().multipliedBy(0.25).offset(-15)
        }
        
        if mobilityData.on_process {
            trunkCell.progressBar.progressColor = .lightGray
            trunkCell.progressBar.fontColor = .lightGray
            
            shoulderCell.progressBar.progressColor = .lightGray
            shoulderCell.progressBar.fontColor = .lightGray
            
            hipCell.progressBar.progressColor = .lightGray
            hipCell.progressBar.fontColor = .lightGray
            
            ankleCell.progressBar.progressColor = .lightGray
            ankleCell.progressBar.fontColor = .lightGray
        }
        
        let testDateUnixTime = mobilityData.testDate
        let testDate = Date.init(timeIntervalSince1970: TimeInterval(testDateUnixTime))
        let dateCounter = Date().timeIntervalSince(testDate)
        
        //        if true {
        if mobilityData.testDate == 0 {
            //User chưa làm test
            viewMobilityPlanBtn.isHidden = true
            
            if mobilityData.on_process {
                gotoMyMobility.setTitle(NSLocalizedString("kMobilityPlanContinueBtn", comment: "").uppercased(), for: .normal)
            } else {
                gotoMyMobility.setTitle(NSLocalizedString("kTakeMobilityTest", comment: "").uppercased(), for: .normal)
            }
        }
        else {
            viewMobilityPlanBtn.isHidden = false
        }
    }
    
    func reloadListWorkout() {
        // Remove all old cell
        for subView in workoutScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        // Workout Cell
        let workoutCell = VW_WorkoutSportCell.init(frame: CGRect(x: 20, y: 0, width: 250, height: 140))
        workoutCell.thumbnailImage.image = UIImage.init(named: "workout_category_thumbnail_image")
        workoutCell.categoryLabel.text = NSLocalizedString("kByWorkout", comment: "")
        workoutCell.collectionType = .workout
        workoutCell.delegate = self
        workoutScrollView.addSubview(workoutCell)
        
        // Sport Cell
        let sportCell = VW_WorkoutSportCell.init(frame: CGRect(x: 280, y: 0, width: 250, height: 140))
        sportCell.thumbnailImage.image = UIImage.init(named: "sport_category_thumbnail_image")
        sportCell.categoryLabel.text = NSLocalizedString("kBySport", comment: "")
        sportCell.collectionType = .sport
        sportCell.delegate = self
        workoutScrollView.addSubview(sportCell)
        
        // Archetype Cell
        let archetypeCell = VW_WorkoutSportCell.init(frame: CGRect(x: 540, y: 0, width: 250, height: 140))
        archetypeCell.thumbnailImage.image = UIImage.init(named: "archetype_category_thumbnail_image")
        archetypeCell.categoryLabel.text = NSLocalizedString("kByArchetype", comment: "")
        archetypeCell.collectionType = .archetype
        archetypeCell.delegate = self
        workoutScrollView.addSubview(archetypeCell)
                        
        workoutScrollView.contentSize = CGSize.init(width: CGFloat(3)*(250 + 10) + 30, height: 140)
    }
    
    func reloadListBonusContent(bonusContents:[SystemBonusDataSource]) {
        // Remove all old cell
        for subView in bonusContentScrollView.subviews {
            subView.removeFromSuperview()
        }
                
        // Reload scrollView
        let size = CGSize(width: 140, height: 140)
        var index = 0
        
        for bonusContent in bonusContents {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_HomePageBonusContentCell.init(frame: frame)
            cell.setDataSource(bonusContent)
            cell.delegate = self
            bonusContentScrollView.addSubview(cell)
            
            index += 1
        }
        
        bonusContentScrollView.contentSize = CGSize.init(width: CGFloat(bonusContents.count)*(size.width + 10) + 30, height: size.height)
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
//        let videoVC = VC_SubPageVideoPlayer()
//        videoVC.setVideoDataSource(newVideoDataSource: videoData)
//        _NavController.pushViewController(videoVC, animated: false)
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let tabbarVC = viewVCs.first as! MainPageTabbar
            tabbarVC.selectedIndex = 0
        }
        self.dismiss(animated: true, completion: nil)
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        _AppVideoManager.requestDownloadVideo(videoData: videoData)
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
    }
    
    //MARK: - HomePageBonusContentCellDelegate
    func didSelectCell(bonusData: SystemBonusDataSource) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let bonusContentVC  = VC_MainPageBonusContentDetails()
        bonusContentVC.setDataSource(newDataSource: bonusData)
        _NavController.pushViewController(bonusContentVC, animated: false)
        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - WorkoutSportCellDelegate
    func didSelectCtegories(category: CollectionType) {
        
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let tabbarVC = viewVCs.first as! MainPageTabbar
            tabbarVC.selectedIndex = 2
        }
        
        self.dismiss(animated: true, completion: nil)
        
//        let categoryVC = VC_MainPageWorkoutCategory()
//        categoryVC.collectionType = category
//
//        switch category {
//        case .workout:
//            //View all workouts
//            categoryVC.thumbnailImage.image = UIImage.init(named: "workout_category_thumbnail_image")
//            categoryVC.workoutTitle.text = NSLocalizedString("kWorkout", comment: "")
//            break
//        case .sport:
//            //View all sport
//            categoryVC.thumbnailImage.image = UIImage.init(named: "sport_category_thumbnail_image")
//            categoryVC.workoutTitle.text = NSLocalizedString("kFilterSport", comment: "")
//            break
//        case .archetype:
//            //View all archetype
//            categoryVC.thumbnailImage.image = UIImage.init(named: "archetype_category_thumbnail_image")
//            categoryVC.workoutTitle.text = NSLocalizedString("kFilterArchetype", comment: "")
//            break
//        }
//
//        _NavController.pushViewController(categoryVC, animated: false)
//        self.dismiss(animated: true, completion: nil)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView == self.upSellCollectionView {
            if (((scrollView.contentOffset.x + scrollView.frame.size.width) > scrollView.contentSize.width ) && !isLoadingUpSell){
                if pagingUpSell!.maxPage > currentPageUpSell {
                    isLoadingUpSell = true
                    currentPageUpSell += 1
                    self.reloadDailyUpSell()
                }
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource
      
      func numberOfSections(in collectionView: UICollectionView) -> Int {
          return 1
      }
      
      func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
          if collectionView == self.upSellCollectionView {
              return listUpSell.count
          }
          return 0
      }
      
      func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
          
          let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "upSellCell", for: indexPath) as! VW_HomePageUpSellCell
          
          if collectionView == self.upSellCollectionView {
              let cellData = self.listUpSell[indexPath.row]
              cell.viewUpSell.setDataSource(upsellData: cellData)
              cell.layoutSubviews()
                            
          }
          
          cell.layoutSubviews()
          return cell
      }
      
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 155, height: 155 )
    }
}



