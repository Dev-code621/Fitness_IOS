//
//  VC_AppTutorial.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_AppTutorial: UIViewController,
                        UIScrollViewDelegate {
    
    let backBtn         = UIButton()
    let slideView       = UIScrollView()
    let pageControl     = UIPageControl()
    let joinBtn         = UIButton()
    
    var listVideo       : [VideoDataSource] = []
    var listScreen      : [VW_AppTutorialScreen] = []
    var playingScreen   : VW_AppTutorialScreen?
    
    private let videoThumbnailImage     = UIImageView()
    private var videoStatusTimer        : Timer? = nil
    private let loadingAnimation        = VW_LoadingAnimation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .black
        
        slideView.delegate = self
        slideView.isPagingEnabled = true
        self.view.addSubview(slideView)
        slideView.snp.makeConstraints { (make) in
            make.center.size.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        self.reloadContent()
        
        backBtn.setBackgroundImage(UIImage.init(named: "back_white_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(35)
            make.height.width.equalTo(30)
        }
        
        joinBtn.setTitle(NSLocalizedString("kTutorialJoinUsBtn", comment: "").uppercased(), for: .normal)
        joinBtn.setTitleColor(.white, for: .normal)
        joinBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        joinBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        joinBtn.layer.cornerRadius = 20
        joinBtn.isHidden = true
        joinBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.addSubview(joinBtn)
        joinBtn.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-5)
        }
        
        pageControl.currentPage = 0
        pageControl.addTarget(self, action: #selector(pageControlSelectionAction(_:)), for: .touchUpInside)
        self.view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(joinBtn.snp.top).offset(-10)
            make.centerX.equalToSuperview()
        }
        
        videoThumbnailImage.image = UIImage.init(named: "default_thumbnail_image")
        videoThumbnailImage.contentMode = .scaleAspectFit
        self.view.addSubview(videoThumbnailImage)
        videoThumbnailImage.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.playingScreen?.avPlayerViewController.player?.currentItem)
        
        self.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        self.playingScreen?.avPlayerViewController.player?.pause()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

    //MARK: - DataSource
    func reloadContent() {
        
        for subView in slideView.subviews {
            subView.removeFromSuperview()
        }
        
        self.listScreen = []
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 0
        
        var markView : UIView? = nil
        var index = 0
        
        let list = Array(self.listVideo.prefix(1))
        for videoData in list {

            let introView = VW_AppTutorialScreen()
            introView.setVideoData(newVideoData: videoData)
            self.listScreen.append(introView)
            
            slideView.addSubview(introView)
            if (markView != nil) {
                introView.snp.makeConstraints { (make) in
                    make.centerY.height.equalToSuperview()
                    make.width.equalTo(UIScreen.main.bounds.size.width)
                    make.left.equalTo(markView!.snp.right)
                }
            }
            else {
                introView.snp.makeConstraints { (make) in
                    make.centerY.height.equalToSuperview()
                    make.width.equalTo(UIScreen.main.bounds.size.width)
                    make.left.equalToSuperview()
                }
            }
            
            introView.layoutIfNeeded()
            if markView == nil {
                introView.avPlayerViewController.player?.play()
                introView.avPlayerViewController.player?.volume = 0.5
                self.playingScreen = introView
            }
                        
            markView = introView
            index += 1
        }
        
        markView?.snp.makeConstraints { (make) in
            make.right.equalToSuperview()
        }
        
        slideView.layoutIfNeeded()
        joinBtn.isHidden = false
    }
    
    //MARK: - Data
    func reloadData() {
        
        _AppDataHandler.getAppIntroVideos { (isSuccess, error, newListVideos) in
            if isSuccess {
                self.listVideo = newListVideos
                self.videoStatusTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                             selector: #selector(self.videoStatusControlHasChange),
                                                             userInfo: nil, repeats: true)
                self.reloadContent()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    //MARK: - Functions
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func pageControlSelectionAction(_ sender: UIPageControl) {
        //move page to wanted page
        let page = (CGFloat)(sender.currentPage)
        self.slideView.setContentOffset(CGPoint(x: page*UIScreen.main.bounds.size.width, y: 0), animated: true)
    }
    
    // MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageIndex = round(scrollView.contentOffset.x/view.frame.width)
        pageControl.currentPage = Int(pageIndex)
        
        //pause playing video
        self.playingScreen?.avPlayerViewController.player?.pause()
        
        if Int(pageIndex) <= self.listScreen.count - 1  {
            let screenAvailable = self.listScreen[Int(pageIndex)]
            screenAvailable.avPlayerViewController.player?.play()
            
            self.playingScreen = screenAvailable
        }
        
        if Int(pageIndex) == self.listVideo.count - 1 {
            joinBtn.isHidden = false
        } else {
            joinBtn.isHidden = true
        }
    }
    
    @objc func playerDidFinishPlaying() {
        
//        if pageControl.currentPage == (self.listVideo.count - 1) {
//            //last page
//            return
//        }
//
//        var point = slideView.frame.origin
//        point.x = slideView.frame.size.width * CGFloat((pageControl.currentPage + 1));
//        point.y = 0;
//        slideView.setContentOffset(point, animated: true)
         self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func videoStatusControlHasChange() {
        if self.playingScreen?.avPlayerViewController.player?.timeControlStatus == .playing {
               self.loadingAnimation.isHidden = true
               self.videoThumbnailImage.isHidden = true
               self.videoStatusTimer?.invalidate()
               self.videoStatusTimer = nil
           }
       }
}
