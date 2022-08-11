//
//  VC_MainPageDaily.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/28/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

enum keyView: Int {
    case home = 0
    case daily = 1
}

class VC_MainPageDaily: UIViewController, UINavigationControllerDelegate,
                        UISearchBarDelegate,
                        VideoCellDelegate, DailyAlertControllerDelegate,
                        UIScrollViewDelegate,
                        UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let pageScroll          = UIScrollView()
    
    private let mainFeatureVideo    = VW_RetangleVideoViewCellTitleOnly()
    private let filterBtn           = UIButton()
    private let listFeatureScroll   = UIScrollView()
    private var upSellCollectionView        : UICollectionView?
    
    private let loadingAnimation        = VW_LoadingAnimation()
    private var loadingAnimationCount   = 0
    private var listUpSell              : [UpSellDataSource] = []
    private var listFeature             = [VideoDataSource]()
    
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
        pageScroll.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.bottom.centerX.width.equalToSuperview()
        }
        
        //MARK: Features videos
        let dailyMaintenance = UILabel()
        dailyMaintenance.text = NSLocalizedString("kDailyMaintenance", comment: "")
        dailyMaintenance.font = setFontSize(size: 18, weight: .bold)
        dailyMaintenance.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(dailyMaintenance)
        dailyMaintenance.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-40)
            make.height.equalTo(18)
        }
        
        let attributedString = NSMutableAttributedString(string: NSLocalizedString("kDailyMaintenenceMessage", comment: ""))
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 5
        attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
        
        let dailyExplaintion = UILabel()
        dailyExplaintion.numberOfLines = 0
        dailyExplaintion.attributedText = attributedString
        dailyExplaintion.font = setFontSize(size: 16, weight: .regular)
        dailyExplaintion.textColor = UIColor.init(hexString: "888888")
        self.pageScroll.addSubview(dailyExplaintion)
        dailyExplaintion.snp.makeConstraints { (make) in
            make.top.equalTo(dailyMaintenance.snp.bottom).offset(12)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-40)
        }
        
        mainFeatureVideo.videoTitleLabel.font = setFontSize(size: 24, weight: .bold)
        mainFeatureVideo.delegate = self
        self.pageScroll.addSubview(mainFeatureVideo)
        mainFeatureVideo.snp.makeConstraints { (make) in
            make.top.equalTo(dailyExplaintion.snp.bottom).offset(10)
            make.width.equalTo(self.view)
            make.centerX.equalToSuperview()
            make.height.equalTo(mainFeatureVideo.snp.width).multipliedBy(0.5625)
        }
        
        self.view.layoutIfNeeded()
        self.mainFeatureVideo.reloadLayout()
        
        //MARK: Search by Focus Area & Time
        let filterTitle = UILabel()
        filterTitle.text = "Looking For Something Specific?"
        filterTitle.font = setFontSize(size: 18, weight: .bold)
        filterTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(filterTitle)
        filterTitle.snp.makeConstraints { (make) in
            make.top.equalTo(mainFeatureVideo.snp.bottom).offset(20)
            make.centerX.equalTo(mainFeatureVideo)
            make.width.equalTo(mainFeatureVideo).offset(-40)
        }
        
        filterBtn.setTitle(NSLocalizedString("kDailyFilter", comment: "").uppercased(), for: .normal)
        filterBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        filterBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        filterBtn.layer.cornerRadius = 20
        filterBtn.addTarget(self, action: #selector(didSelectFilterButton), for: .touchDown)
        self.pageScroll.addSubview(filterBtn)
        filterBtn.snp.makeConstraints { (make) in
            make.top.equalTo(filterTitle.snp.bottom).offset(10)
            make.centerX.equalTo(mainFeatureVideo)
            make.width.equalTo(mainFeatureVideo).offset(-40)
            make.height.equalTo(40)
        }
        
        //MARK: New Videos
        let relatedVideoTitle = UILabel()
        relatedVideoTitle.text = NSLocalizedString("kRelatedVideos", comment: "")
        relatedVideoTitle.font = setFontSize(size: 18, weight: .bold)
        relatedVideoTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(relatedVideoTitle)
        relatedVideoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(filterBtn.snp.bottom).offset(30)
            make.left.equalTo(mainFeatureVideo).offset(20)
            make.height.equalTo(18)
        }
        
        listFeatureScroll.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(listFeatureScroll)
        listFeatureScroll.snp.makeConstraints { (make) in
            make.left.right.equalTo(mainFeatureVideo)
            make.top.equalTo(relatedVideoTitle.snp.bottom).offset(10)
            make.height.equalTo(135)
        }
        
        //MARK: Upsell
        let upsellTitle = UILabel()
        upsellTitle.text = NSLocalizedString("kBestUpsellTitle", comment: "")
        upsellTitle.font = setFontSize(size: 18, weight: .bold)
        upsellTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(upsellTitle)
        upsellTitle.snp.makeConstraints { (make) in
            make.top.equalTo(listFeatureScroll.snp.bottom).offset(30)
            make.left.equalTo(mainFeatureVideo).offset(20)
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
            make.left.right.equalTo(mainFeatureVideo)
            make.top.equalTo(upsellTitle.snp.bottom).offset(10)
            make.height.equalTo(155)
            make.bottom.equalToSuperview()
        })
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        _NavController.setNavigationBarHidden(true, animated: false)
        
        //reload swap list feature
        if listFeature.count > 0 {
            listFeature.swapAt(0, 1)
            self.reloadListFeatureData(videos: listFeature)
        }
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            self.filterBtn.backgroundColor = UIColor.init(hexString: "e4e4e4")
            self.filterBtn.setTitleColor(UIColor.init(hexString: "ffffff"), for: .normal)
        }
        
        //Show What would you like to do today?
        let userDefault = UserDefaults.standard
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        let savedString = userDefault.value(forKey: kUserDailySurvey) as! String? ?? ""

        if savedString == dateFormatter.string(from: Date()) {
            return
        }
        
        if let _ = self.presentedViewController {
            return
        }
        userDefault.set(dateFormatter.string(from: Date()), forKey: kUserDailySurvey)

        let dailyVC = VC_DailyAlertController()
        dailyVC.delegate = self
        dailyVC.modalPresentationStyle = .overFullScreen
        self.present(dailyVC, animated: true, completion: nil)
    }
    
    //MARK: - Button
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
    
    @objc func didSelectFilterButton() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let filterVC = VC_MainPageAllMainternacesFilter()
        _NavController.pushViewController(filterVC, animated: true)
    }
    
    @objc func didSelectSeeMore() {
        let allMaintenanceVC = VC_MainPageAllMaintenances()
        allMaintenanceVC.setFilterData(listFocus: [],
                                       minValue: kZeroMinsFilter,
                                       maxValue: kAllMinsFilter)
        _NavController.pushViewController(allMaintenanceVC, animated: true)
    }
    
    @objc func userFreemium() {
        _NavController.presentAlertForFreemium()
    }
    
    //MARK: - Datas
    
    func reloadData() {
        
        self.loadingAnimationCount = 0
        self.loadingAnimation.isHidden = false
        
        //Feature Videos
        _AppDataHandler.getDailyPageFeatureVideos(filterBy: 0) { (isSucess, error, listVideos) in
            self.checkLoadingAnimation()
            
            if isSucess {
                self.listFeature = listVideos
                self.reloadListFeatureData(videos: listVideos)
            } else {
                self.dismiss(animated: true, completion: nil)
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
        _AppDataHandler.getBestUpSeller() { (isSuccess, error, listUpSells) in
            self.checkLoadingAnimation()
            
            if isSuccess {
                self.listUpSell = listUpSells
                self.upSellCollectionView?.reloadData()
                
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
    
    func checkLoadingAnimation() {
        self.loadingAnimationCount += 1
        if self.loadingAnimationCount == 2 {
            self.loadingAnimation.isHidden = true
        }
    }
    
    func reloadListFeatureData(videos: [VideoDataSource]) {
        
        // Remove all old cell
        for subView in listFeatureScroll.subviews {
            subView.removeFromSuperview()
        }
        
        // Reload main Video Data
        if let videoFirstData = videos.first {
            mainFeatureVideo.setVideoDataSource(videoData: videoFirstData)
        }
        
        var newVideos = videos
        if newVideos.count > 1 {
            newVideos.removeFirst()
        }
        
        // Reload feature scrollView
        let size = CGSize(width: 240, height: 135)
        var index = 0
        
        for videoData in newVideos {
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_RetangleVideoViewCellTitleOnly.init(frame: frame)
            cell.delegate = self
            cell.reloadLayout()
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                cell.showOpacityView()
            }
            cell.setVideoDataSource(videoData: videoData)
            listFeatureScroll.addSubview(cell)
            
            index += 1
        }
        
        let frame = CGRect.init(x: 20 + CGFloat(newVideos.count)*(size.width + 10), y: 0, width: size.width, height: size.height)
        let cell = UIButton.init(frame: frame)//VW_SeeMoreCell.init(frame: frame)
        cell.setTitle(NSLocalizedString("kSeeMore", comment: ""), for: .normal)
        cell.backgroundColor = UIColor.init(hexString: "718cfe")
        cell.titleLabel?.font = setFontSize(size: 12, weight: .semibold)
        cell.addTarget(self, action: #selector(didSelectSeeMore), for: .touchUpInside)
        listFeatureScroll.addSubview(cell)
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            let cellOpacity = UIView()
            cellOpacity.frame = cell.frame
            cellOpacity.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            cell.addSubview(cellOpacity)
            let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(userFreemium))
            cellOpacity.addGestureRecognizer(singleTap)
            
            listFeatureScroll.addSubview(cellOpacity)
        }
        
        listFeatureScroll.contentSize = CGSize.init(width: CGFloat(newVideos.count+1)*(size.width + 10) + 30, height: size.height)
    }
    
    
    //MARK: - UISearchBarDelegate
    func searchBarShouldBeginEditing(_ searchBar: UISearchBar) -> Bool {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            self.dismiss(animated: true, completion: nil)
            _NavController.presentAlertForFreemium()
            return false
        }
        let searchVC = VC_MainPageSearch()
        self.navigationController?.pushViewController(searchVC, animated: true)
        return false
    }
    
    //MARK: - DailyAlertControllerDelegate
    func didSelectPainOption() {
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let homeVC = viewVCs.first as! MainPageTabbar
            homeVC.selectedIndex = 1
        }
    }
    
    func didSelectWorkoutOption() {
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let homeVC = viewVCs.first as! MainPageTabbar
            homeVC.selectedIndex = 2
        }
    }
    
    func didSelectMobilityTestOption() {
        
        let viewVCs = _NavController.viewControllers
        if viewVCs.first is MainPageTabbar {
            let homeVC = viewVCs.first as! MainPageTabbar
            homeVC.selectedIndex = 3
        }
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        let videoVC = VC_SubPageVideoPlayer()
        videoVC.setVideoDataSource(newVideoDataSource: videoData)
        _NavController.pushViewController(videoVC, animated: true)
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            self.dismiss(animated: true, completion: nil)
            _NavController.presentAlertForFreemium()
            return
        }
        
        _AppVideoManager.requestDownloadVideo(videoData: videoData)
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
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
