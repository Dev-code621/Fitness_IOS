//
//  VC_SignUpIntroVideo.swift
//  NewTRS
//
//  Created by yaya on 10/19/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import Foundation
import AVKit

class VC_SignUpIntroVideo: UIViewController, AVPlayerViewControllerDelegate {
    
    let videoPlayerController   = AVPlayerViewController()
    let videoThumbnailImage     = UIImageView()
    
    let videoTitle          = UILabel()
    let watchLaterBtn       = UIButton()
    
    var videoDataSource     = VideoDataSource.init(JSONString: "{}")!
    var videoStatusTimer    : Timer? = nil
    let loadingAnimation    = VW_LoadingAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .black
        
        let videoView = UIView()
        self.view.addSubview(videoView)
        videoView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
        
        videoPlayerController.view.frame = videoView.bounds
        videoPlayerController.showsPlaybackControls = false
        videoPlayerController.delegate = self
        videoPlayerController.videoGravity = .resizeAspectFill
        videoView.addSubview(videoPlayerController.view)
        
        videoThumbnailImage.contentMode = .scaleAspectFit
        videoView.addSubview(videoThumbnailImage)
        videoThumbnailImage.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        videoTitle.text = ""
        videoTitle.font = setFontSize(size: 18, weight: .bold)
        videoTitle.textColor = .white
        self.view.addSubview(videoTitle)
        videoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(50)
            make.left.equalTo(self.view.safeAreaLayoutGuide).offset(25)
        }
        
        watchLaterBtn.setTitle(NSLocalizedString("kWatchLaterBtn", comment: "").uppercased(), for: .normal)
        watchLaterBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        watchLaterBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        watchLaterBtn.layer.cornerRadius = 20
        watchLaterBtn.addTarget(self, action: #selector(watchLaterButtonTapped), for: .touchUpInside)
        watchLaterBtn.isHidden = false
        self.view.addSubview(watchLaterBtn)
        watchLaterBtn.snp.makeConstraints { (make) in
            make.width.equalTo(120)
            make.height.equalTo(40)
            make.top.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-5)
        }
        
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(playerDidFinishPlaying),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: self.videoPlayerController.player?.currentItem)
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        videoPlayerController.player?.play()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        videoPlayerController.player?.pause()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Button
    @objc func watchLaterButtonTapped() {
        
        UserDefaults.standard.set(Int(Date().timeIntervalSince1970), forKey: kUserSignUpIntroSkip)
        
        //Sam as skip function
        self.skipButtonTapped()
    }
    
    @objc func skipButtonTapped() {
        
        self.videoPlayerController.player?.pause()
        self.videoPlayerController.player = nil
        let userNameVC = VC_SubPageUpdateUser()
        self.navigationController?.pushViewController(userNameVC, animated: true)
    }
    
    //MARK: - Data
    
    func reloadData()
    {
        _AppDataHandler.getSignUpIntroVideo { (isSuccess, error, newVideoDataSource) in
            
            if isSuccess {
                guard let newVideoDataSource = newVideoDataSource else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                    return
                }
                
                self.videoDataSource = newVideoDataSource
                
                if let thumbnailImageURL = URL(string: newVideoDataSource.imageThumnailStr) {
                    self.videoThumbnailImage.sd_setImage(with: thumbnailImageURL, placeholderImage: UIImage.init(named: "default_thumbnail_image")!)
                }
                
                if newVideoDataSource.videoPlayUrl != "" {
                    if let videoURL = URL(string:newVideoDataSource.videoPlayUrl) {
                        let videoPlayer = AVPlayer.init(url: videoURL)
                        self.videoPlayerController.player = videoPlayer
                        self.videoPlayerController.player?.volume = 0.5
                        self.videoPlayerController.player?.play()
                    }
                }
                
                //  self.videoTitle.text = newVideoDataSource.videoTitle
                
                self.videoStatusTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                             selector: #selector(self.videoStatusControlHasChange),
                                                             userInfo: nil, repeats: true)
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    @objc private func videoStatusControlHasChange() {
        if self.videoPlayerController.player?.timeControlStatus == .playing {
            self.loadingAnimation.isHidden = true
            self.videoThumbnailImage.isHidden = true
            
            self.videoStatusTimer?.invalidate()
            self.videoStatusTimer = nil
        }
    }
    
    @objc func playerDidFinishPlaying() {
        self.skipButtonTapped()
    }
}
