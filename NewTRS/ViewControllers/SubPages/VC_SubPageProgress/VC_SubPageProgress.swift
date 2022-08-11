//
//  VC_SubPageProgress.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import Foundation

class VC_SubPageProgress: UIViewController, UIScrollViewDelegate,
                            VW_UserHistoryViewDelegate {
    
    let pageScroll              = UIScrollView()
    
    var progressSegmentControll = UISegmentedControl(items: [
                                                            //NSLocalizedString("kUserRulesBtn", comment: ""),
                                                             NSLocalizedString("kUserStreaksBtn", comment: "")
                                                           //  NSLocalizedString("kUserLeaderboardBtn", comment: "")
                                                              ])
    
    let rulesView               = VW_UserRules()
    let streaksView             = VW_UserArchivements()
    let leaderboardView         = VW_UserLeaderboard()

    let loadingAnimation        = VW_LoadingAnimation()
    var loadingAnimationCount   = 0
    private var listUnlockedStreaks: [UserArchivementDataSource] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let closeBtn = UIButton()
        closeBtn.setBackgroundImage(UIImage.init(named: "back_black_btn"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(35)
            make.left.equalToSuperview().offset(20)
            make.height.width.equalTo(30)
        }
        
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kProgress", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalTo(closeBtn.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        if #available(iOS 13.0, *) {
            progressSegmentControll.selectedSegmentTintColor = UIColor.init(hexString: "718cfe")!
        } else {
            progressSegmentControll.tintColor = UIColor.init(hexString: "718cfe")!
        }
        progressSegmentControll.selectedSegmentIndex = 0
        let titleSelectedAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white,
                                       NSAttributedString.Key.font : setFontSize(size: 14, weight: .semibold)]
        let titleNormalAttributes = [NSAttributedString.Key.foregroundColor: UIColor.black,
                                     NSAttributedString.Key.font : setFontSize(size: 14, weight: .regular)]
        progressSegmentControll.setTitleTextAttributes(titleNormalAttributes, for: .normal)
        progressSegmentControll.setTitleTextAttributes(titleSelectedAttributes, for: .selected)
        progressSegmentControll.addTarget(self, action: #selector(segmentedControlDidChangeValue), for: .valueChanged)
        
        self.view.addSubview(progressSegmentControll)
        progressSegmentControll.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(10)
            make.height.equalTo(38)
            make.left.equalToSuperview().offset(5)
            make.right.equalToSuperview().offset(-5)
        }
        
       // pageScroll.isPagingEnabled = true
        pageScroll.showsHorizontalScrollIndicator = false
//        pageScroll.isUserInteractionEnabled = false
        pageScroll.delegate = self
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.equalTo(progressSegmentControll.snp.bottom).offset(1)
            make.left.right.bottom.equalToSuperview()
        }
        
//        rulesView.delegate = self
//        pageScroll.addSubview(rulesView)
//        rulesView.snp.makeConstraints { (make) in
//            make.left.top.height.equalToSuperview()
//            make.width.equalTo(self.view)
//        }
        
        streaksView.delegate = self
        pageScroll.addSubview(streaksView)
        streaksView.snp.makeConstraints { (make) in
          //  make.left.equalTo(rulesView.snp.right)
            make.left.top.height.equalToSuperview()
            make.width.equalTo(self.view)
        }
        //Ẩn leaderboard
//        leaderboardView.delegate = self
//        pageScroll.addSubview(leaderboardView)
//        leaderboardView.snp.makeConstraints { (make) in
//            make.left.equalTo(streaksView.snp.right)
//            make.right.top.height.equalToSuperview()
//            make.width.equalTo(self.view)
//        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(noti:)),
                                               name: kUserProfileHasChangeNotification,
                                               object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(noti:)),
                                               name: kNetwordHasChangeNotification,
                                               object: nil)
        
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK:- Button
    
    @objc func closeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func segmentedControlDidChangeValue() {

        let selectedIndex = self.progressSegmentControll.selectedSegmentIndex
        
        var frame: CGRect = self.pageScroll.frame
        frame.origin.x = frame.size.width * CGFloat(selectedIndex)
        frame.origin.y = 0
        self.pageScroll.setContentOffset(frame.origin, animated: true)
    }
    
    //MARK: - Data
    
    func reloadData() {
        
        self.loadingAnimation.isHidden = false
//        _AppDataHandler.getUserHistoriesVideo (page: 1, limit: 10) { (isSucess, error, paging, listHistoriesVideo) in
//
//            self.progressLoadingAnimation()
//            if isSucess {
//                self.historyView.setListVideo(newListVideo: listHistoriesVideo)
//                self.historyView.paging = paging
//            } else {
//                self.historyView.setListVideo(newListVideo: [])
//                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
//                return
//            }
//        }
        
        _AppDataHandler.getUserArchivermentBagde { (isSuccess, error, listArchivement, userPoint)  in
            
            if isSuccess {
                                
                // Get number days to reach next achievement
                var nextRank: UserArchivementDataSource?
                for achievement in listArchivement {
                    // Get unlocked Streaks
                    if achievement.achievementIsActive {
                        self.listUnlockedStreaks.append(achievement)
                    } else {
                        nextRank = achievement
                        break
                    }
                }
                var maxValue: Int? = 7
                var nextStreakImage: String? = ""
                if let rank = nextRank {
                    maxValue = rank.achievementMilestone
                    nextStreakImage = rank.achievementActiveImage
                }
                
                var gotUnlocked: Bool = false
                gotUnlocked = self.listUnlockedStreaks.isEmpty ? false : true
                self.streaksView.setDataSource(userArchevement: listArchivement, gotUnlocked: gotUnlocked, point: userPoint, nextRankImageURL: nextStreakImage!, nextRankPoint: maxValue!)
            } else {
                self.streaksView.setDataSource(userArchevement: [], gotUnlocked: false, point: 0, nextRankImageURL: "", nextRankPoint: 0)
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
            self.progressLoadingAnimation()
        }
        
        _AppDataHandler.getGlobalLeaderboard { (isSuccess, error, currentUserRank, listTopRank) in
            
            self.progressLoadingAnimation()
            if isSuccess {
               // self.leaderboardView.set(userRank: currentUserRank!, leaderboard: listTopRank)
            } else {
                self.leaderboardView.set(userRank: nil, leaderboard: [])
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    func progressLoadingAnimation() {
        
        self.loadingAnimationCount += 1
        if self.loadingAnimationCount == 2 {
            self.loadingAnimationCount = 0
            self.loadingAnimation.isHidden = true
            
            if listUnlockedStreaks.count > 0 {
                if UserDefaults.standard.object(forKey: kUserStreaksData) != nil {
                    let placeData = UserDefaults.standard.object(forKey: kUserStreaksData)
                    let list = try! JSONDecoder().decode([UserArchivementDataSource].self, from: placeData as! Data)
                    if list.count != listUnlockedStreaks.count {
                        
                        let data = try! JSONEncoder().encode(listUnlockedStreaks)
                        UserDefaults.standard.set(data, forKey: kUserStreaksData)
                        
                        let vc_StreaksCongralutation = VC_StreaksCongratulations()
                        vc_StreaksCongralutation.modalPresentationStyle = .fullScreen
                        vc_StreaksCongralutation.reloadData(data: listUnlockedStreaks)
                        self.present(vc_StreaksCongralutation, animated: true, completion: nil)
                    }
                } else {
                    let data = try! JSONEncoder().encode(listUnlockedStreaks)
                    UserDefaults.standard.set(data, forKey: kUserStreaksData)
                    
                    let vc_StreaksCongralutation = VC_StreaksCongratulations()
                    vc_StreaksCongralutation.modalPresentationStyle = .fullScreen
                    vc_StreaksCongralutation.reloadData(data: listUnlockedStreaks)
                    self.present(vc_StreaksCongralutation, animated: true, completion: nil)
                }
            }
        }
    }
    
    @objc private func handleNotification(noti: Notification) {
        
        if noti.name == kUserProfileHasChangeNotification {
            
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                self.dismiss(animated: true, completion: nil)
            }
        } else if noti.name == kNetwordHasChangeNotification {
            self.reloadData()
        }
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let pageWidth = scrollView.frame.size.width
        let fractionalPage = scrollView.contentOffset.x / pageWidth
        
        let page = lroundf(Float(fractionalPage))
        self.progressSegmentControll.selectedSegmentIndex = page
    }
    
    //MARK: - VW_UserHistoryViewDelegate
    
    func didSelectVideoData(videoData: VideoDataSource) {
        let videoVC = VC_SubPageVideoPlayer()
        videoVC.setVideoDataSource(newVideoDataSource: videoData)
        _NavController.pushViewController(videoVC, animated: true)
        
        self.dismiss(animated: true, completion: nil)
    }
}
