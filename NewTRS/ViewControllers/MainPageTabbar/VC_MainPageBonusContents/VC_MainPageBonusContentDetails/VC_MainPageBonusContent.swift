//
//  VC_MainPageMiniQA.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit

class VC_MainPageBonusContentDetails: UIViewController, AVPlayerViewControllerDelegate,
                        UITableViewDataSource, UITableViewDelegate {

    let videoPlayerController   = AVPlayerViewController()
    
    let headerPlayerView        = UIView()
    let headerViewLayer         = UIView()
    var timer                   : Timer? = nil
    
    let fullScreenBtn           = UIButton()
    let downloadBtn             = UIButton()
    let castBtn                 = UIButton()
    let addWishListBtn          = UIButton()
    
    let pageTitle               = UILabel()
    let videoCountLabel         = UILabel()
    let totalDurationLabel      = UILabel()
    
    let tableView               = UITableView()
    let loadingAnimation        = VW_LoadingAnimation()
    var loadingAnimationCount   = 0
    
    var dataSource              = SystemBonusDataSource.init(JSONString: "{}")!
    var listVideo               : [VideoDataSource] = []
    
    var playingVideo            : VideoDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        headerPlayerView.backgroundColor = .black
        self.view.addSubview(headerPlayerView)
        headerPlayerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.5625)
        }
                
        self.view.layoutIfNeeded()
        
        videoPlayerController.view.frame = headerPlayerView.bounds
        videoPlayerController.showsPlaybackControls = false
        videoPlayerController.delegate = self
        headerPlayerView.addSubview(videoPlayerController.view)
        
        headerViewLayer.isHidden = true
        headerViewLayer.backgroundColor = UIColor.init(hexString: "aa000000")
        headerPlayerView.addSubview(headerViewLayer)
        headerViewLayer.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage.init(named: "back_white_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        headerViewLayer.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview().offset(20)
            make.height.width.equalTo(30)
        }
        
        let videoControlBtn     = UIButton()
        videoControlBtn.setBackgroundImage(UIImage.init(named: "playing_btn"), for: .normal)
        videoControlBtn.setBackgroundImage(UIImage.init(named: "paused_btn"), for: .selected)
        videoControlBtn.addTarget(self, action: #selector(videoControlButtonTapped(btn:)), for: .touchUpInside)
        headerViewLayer.addSubview(videoControlBtn)
        videoControlBtn.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.height.width.equalTo(30)
        }
        
        let headerTouch = UITapGestureRecognizer.init(target: self, action: #selector(headerViewTouched))
        headerPlayerView.addGestureRecognizer(headerTouch)
        
        let ctaView = UIView()
        ctaView.backgroundColor = .white
        self.view.addSubview(ctaView)
        ctaView.snp.makeConstraints { (make) in
            make.top.equalTo(headerPlayerView.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(54)
        }
        
        let ctaLine = UIView()
        ctaLine.backgroundColor = UIColor.init(hexString: "d8d8d8")
        self.view.addSubview(ctaLine)
        ctaLine.snp.makeConstraints { (make) in
            make.top.equalTo(ctaView.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        self.loadCTAView(ctaView: ctaView)
        
        pageTitle.text = NSLocalizedString("kMiniQA", comment: "")
        pageTitle.font = UIFont.init(name: "HurmeGeometricSans1-SemiBold", size: 18)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        pageTitle.textAlignment = .center
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalTo(ctaLine).offset(20)
            make.centerX.width.equalToSuperview()
        }
        
        let infoView = UIView()
        self.view.addSubview(infoView)
        infoView.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(20)
        }
        
        self.loadInfoView(infoView: infoView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(TC_VideoPracticeCell.self, forCellReuseIdentifier: "videoTableCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(infoView.snp.bottom).offset(10)
            make.left.right.bottom.equalToSuperview()
        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: false)
        
        videoPlayerController.player?.play()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayerController.player?.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Load UI
    func loadCTAView(ctaView: UIView) {
        let spaceView1 = UIView()
        ctaView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
        }
        
        fullScreenBtn.setBackgroundImage(UIImage.init(named: "fullscreen_icon"), for: .normal)
        fullScreenBtn.addTarget(self, action: #selector(fullScreenButtonTapped), for: .touchUpInside)
        ctaView.addSubview(fullScreenBtn)
        fullScreenBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView1.snp.right)
        }
        
        let fullScreenTitle = UILabel()
        fullScreenTitle.text = NSLocalizedString("kFullScreenBtn", comment: "")
        fullScreenTitle.font = UIFont.init(name: "HurmeGeometricSans1-Regular", size: 10)
        fullScreenTitle.textColor = UIColor.init(hexString: "a5a5a5")
        ctaView.addSubview(fullScreenTitle)
        fullScreenTitle.snp.makeConstraints { (make) in
            make.top.equalTo(fullScreenBtn.snp.bottom).offset(5)
            make.centerX.equalTo(fullScreenBtn)
            make.height.equalTo(10)
        }
        
        let spaceView2 = UIView()
        ctaView.addSubview(spaceView2)
        spaceView2.snp.makeConstraints { (make) in
            make.left.equalTo(fullScreenBtn.snp.right)
            make.width.equalTo(spaceView1).multipliedBy(1.4)
        }
        
        downloadBtn.setBackgroundImage(UIImage.init(named: "download_icon"), for: .normal)
        downloadBtn.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        ctaView.addSubview(downloadBtn)
        downloadBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView2.snp.right)
        }
        
        let downloadTitle = UILabel()
        downloadTitle.text = NSLocalizedString("kDownloadBtn", comment: "")
        downloadTitle.font = UIFont.init(name: "HurmeGeometricSans1-Regular", size: 10)
        downloadTitle.textColor = UIColor.init(hexString: "a5a5a5")
        ctaView.addSubview(downloadTitle)
        downloadTitle.snp.makeConstraints { (make) in
            make.top.equalTo(downloadBtn.snp.bottom).offset(5)
            make.centerX.equalTo(downloadBtn)
            make.height.equalTo(10)
        }
        
        let spaceView3 = UIView()
        ctaView.addSubview(spaceView3)
        spaceView3.snp.makeConstraints { (make) in
            make.left.equalTo(downloadBtn.snp.right)
            make.width.equalTo(spaceView1).multipliedBy(1.4)
        }
        
        castBtn.setBackgroundImage(UIImage.init(named: "cast_icon"), for: .normal)
        castBtn.addTarget(self, action: #selector(castButtonTapped), for: .touchUpInside)
        ctaView.addSubview(castBtn)
        castBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView3.snp.right)
        }
        
        let castTitle = UILabel()
        castTitle.text = NSLocalizedString("kCastBtn", comment: "")
        castTitle.font = UIFont.init(name: "HurmeGeometricSans1-Regular", size: 10)
        castTitle.textColor = UIColor.init(hexString: "a5a5a5")
        ctaView.addSubview(castTitle)
        castTitle.snp.makeConstraints { (make) in
            make.top.equalTo(castBtn.snp.bottom).offset(5)
            make.centerX.equalTo(castBtn)
            make.height.equalTo(10)
        }
        
        let spaceView4 = UIView()
        ctaView.addSubview(spaceView4)
        spaceView4.snp.makeConstraints { (make) in
            make.left.equalTo(castBtn.snp.right)
            make.width.equalTo(spaceView1).multipliedBy(1.4)
        }
        
        addWishListBtn.setBackgroundImage(UIImage.init(named: "add_wish_list_icon"), for: .normal)
        addWishListBtn.setBackgroundImage(UIImage.init(named: "add_wish_list_icon_selected"), for: .selected)
        addWishListBtn.addTarget(self, action: #selector(addWishButtonTapped), for: .touchUpInside)
        ctaView.addSubview(addWishListBtn)
        addWishListBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView4.snp.right)
        }
        
        let addWishListTitle = UILabel()
        addWishListTitle.text = NSLocalizedString("kAddWishListBtn", comment: "")
        addWishListTitle.font = UIFont.init(name: "HurmeGeometricSans1-Regular", size: 10)
        addWishListTitle.textColor = UIColor.init(hexString: "a5a5a5")
        ctaView.addSubview(addWishListTitle)
        addWishListTitle.snp.makeConstraints { (make) in
            make.top.equalTo(addWishListBtn.snp.bottom).offset(5)
            make.centerX.equalTo(addWishListBtn)
            make.height.equalTo(10)
        }
        
        let spaceView5 = UIView()
        ctaView.addSubview(spaceView5)
        spaceView5.snp.makeConstraints { (make) in
            make.left.equalTo(addWishListBtn.snp.right)
            make.right.equalToSuperview()
            make.width.equalTo(spaceView1)
        }
    }
    
    func loadInfoView(infoView: UIView) {
        
        let spaceView1 = UIView()
        infoView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(infoView)
        }
        
        videoCountLabel.text = "23 videos"
        infoView.addSubview(videoCountLabel)
        videoCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(5)
            make.left.equalTo(spaceView1.snp.right)
        }
        
        let spaceView = UIView()
        spaceView.backgroundColor = UIColor.init(hexString: "888888")
        spaceView.layer.cornerRadius = 2
        infoView.addSubview(spaceView)
        spaceView.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(videoCountLabel.snp.right).offset(6)
            make.width.height.equalTo(4)
        }
        
        totalDurationLabel.text = "2:33"
        infoView.addSubview(totalDurationLabel)
        totalDurationLabel.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview().offset(5)
            make.left.equalTo(spaceView.snp.right).offset(6)
        }
        
        let spaceView2 = UIView()
        infoView.addSubview(spaceView2)
        spaceView2.snp.makeConstraints { (make) in
            make.left.equalTo(totalDurationLabel.snp.right)
            make.right.equalToSuperview()
            make.width.equalTo(spaceView1)
        }
    }
    
    //MARK: - Reload Data
    
    func setDataSource(newDataSource: SystemBonusDataSource) {
        self.dataSource = newDataSource
        self.reloadData()
    }
    
    private func setVideoDataSource(newVideoDataSource: VideoDataSource) {
        self.playingVideo = newVideoDataSource
        
        if let videooURL = URL(string: newVideoDataSource.videoPlayUrl) {
            let videoPlayer = AVPlayer.init(url:videooURL)
            self.videoPlayerController.player = videoPlayer
            self.videoPlayerController.player?.play()
        }
                
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getVideoInfo(videoID: "\(newVideoDataSource.videoID)")
        { (isSuccess, error, updatedVideoDataSource) in
            self.loadingAnimation.isHidden = true
            if isSuccess {
                if updatedVideoDataSource != nil {
                    self.playingVideo = updatedVideoDataSource!
                    self.addWishListBtn.isSelected = true
                }
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    func reloadData() {
        
        if self.dataSource.bonusId == 0 {return}
        
        self.pageTitle.text = self.dataSource.bonusTitle
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getListBonusVideo(bonusID: self.dataSource.bonusId)
        { (isSuccess, error, listVideo) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.listVideo = listVideo
                
                //Play first video
                if let firstVideo = self.listVideo.first {
                    self.setVideoDataSource(newVideoDataSource: firstVideo)
                }
               
                var totalDuration = 0
                for videoData in self.listVideo {
                    totalDuration += videoData.videoDuration
                }
                
                // 23 videos, total 3 hours
                let videoAttributedStr = NSMutableAttributedString(string: String(format: "%ld videos", self.listVideo.count))
                videoAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: UIColor.init(hexString: "a5a5a5")!,
                                                  range: NSMakeRange(0, videoAttributedStr.length))
                videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                                value: UIFont.init(name: "HurmeGeometricSans1-Regular", size: 11)!,
                                                range: NSMakeRange(0, videoAttributedStr.length))
                videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                                  value: UIFont.init(name: "HurmeGeometricSans1-SemiBold", size: 11)!,
                                                  range: NSMakeRange(0, 2))
                self.videoCountLabel.attributedText = videoAttributedStr
                
                let durationAttributedStr = NSMutableAttributedString(string: String(format: "%ld min", totalDuration/60))
                durationAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: UIColor.init(hexString: "a5a5a5")!,
                                                  range: NSMakeRange(0, durationAttributedStr.length))
                durationAttributedStr.addAttribute(NSAttributedString.Key.font,
                                                value: UIFont.init(name: "HurmeGeometricSans1-Regular", size: 11)!,
                                                range: NSMakeRange(0, durationAttributedStr.length))
                durationAttributedStr.addAttribute(NSAttributedString.Key.font,
                                                  value: UIFont.init(name: "HurmeGeometricSans1-SemiBold", size: 11)!,
                                                  range: NSMakeRange(0, 2))
                self.totalDurationLabel.attributedText = durationAttributedStr
                
                self.tableView.reloadData()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    func processLoadingAnimation() {
        self.loadingAnimationCount += 1
        if loadingAnimationCount == 2 {
            self.loadingAnimation.isHidden = true
        }
    }
    
    // MARK: - Buttons
    @objc func backButtonTapped() {
        self.videoPlayerController.player?.pause()
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func videoControlButtonTapped(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        
        if btn.isSelected {
            videoPlayerController.player?.pause()
        } else {
            videoPlayerController.player?.play()
        }
    }
    
    @objc func headerViewTouched() {
        UIView.animate(withDuration: 0.2) {
            self.headerViewLayer.isHidden = false
        }
        
        if self.timer != nil {
            self.timer?.invalidate()
        }
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 4, repeats: false) { (timmer) in
            self.headerViewLayer.isHidden = true
            timmer.invalidate()
        }
    }
    
    @objc func fullScreenButtonTapped() {
        //        self.videoPlayerController.modalPresentationStyle = .overFullScreen;
        self.videoPlayerController.showsPlaybackControls = true
        //        self.present(videoPlayerController, animated: true, completion: nil)
        
        let selectorName: String = {
            if #available(iOS 11.3, *) {
                return "_transitionToFullScreenAnimated:interactive:completionHandler:"
            } else if #available(iOS 11, *) {
                return "_transitionToFullScreenAnimated:completionHandler:"
            } else {
                return "_transitionToFullScreenViewControllerAnimated:completionHandler:"
            }
        }()
        let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)
        
        videoPlayerController.performSelector(onMainThread: selectorToForceFullScreenMode, with: nil, waitUntilDone: true)
        
    }
    
    @objc func downloadButtonTapped() {
        if self.playingVideo != nil {
            _AppDataHandler.downloadVideo(videoData: self.playingVideo!)
        }
    }
    
    @objc func castButtonTapped() {
        
    }
    
    @objc func addWishButtonTapped() {
        
        guard let videoData = self.playingVideo else {return}
        if videoData.videoID == 0 {return}
        if videoData.isFavorite {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFavorite", comment: ""),
                                                   message: NSLocalizedString("kVideoAlreadyAddedFavorite", comment: ""))
                return
            }
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.addVideoToFavorite(videoID: videoData.videoID)
        { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                _NavController.presentAlertForCase(title: NSLocalizedString("kFavoriteAlertTitle", comment: ""),
                                                   message: NSLocalizedString("kAddedSuccess", comment: ""))
                self.addWishListBtn.isSelected = true
                return
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return listVideo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 107
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoTableCell", for: indexPath) as! TC_VideoPracticeCell
        
        cell.videoViewCountLabel.isHidden = false
        
        let cellData = self.listVideo[indexPath.row]
        cell.setDataSource(videoData: cellData)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let videoData = self.listVideo[indexPath.row]
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        //Play video
        if let videooURL = URL(string: videoData.videoPlayUrl) {
            
            self.playingVideo = videoData
            let videoPlayer = AVPlayer.init(url:videooURL)
            self.videoPlayerController.player = videoPlayer
            self.videoPlayerController.player?.play()
        }
        
        //mark cell as playing
        let cell = tableView.cellForRow(at: indexPath) as! TC_VideoPracticeCell
        cell.setCellIsPlaying(isPlaying: true)
    }
}
