//
//  VW_VideoPlayer.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import GoogleCast

@objc protocol VW_VideoPlayerDelegate {
    @objc optional func didUpdateNewDataSource()
}

class VW_VideoPlayer: UIView, AVPlayerViewControllerDelegate {
    
    var delegate                : VW_VideoPlayerDelegate?
    private let videoPlayerController   = AVPlayerViewController()
    
    private let headerPlayerView        = UIView()
    
    private let downloadBtn             = UIButton()
    private let castBtn                 = AVRoutePickerView()
    private let addWishListBtn          = UIButton()
    private let favoriteActivityIndicator       = UIActivityIndicatorView(style: .gray)
    private let downloadActivityIndicator       = UIActivityIndicatorView(style: .gray)
    
    private var videoStatusTimer        : Timer? = nil
    private var trackingWatchTimer      : Timer? = nil
    private var realWatchingTime        = 0
    
    //Data
    private var videoDataSource         : VideoDataSource?
    private let thumbnailImage          = UIImageView()
    private let loadingAnimation        = UIView()
    private var listRequest             :[Request] = []
    private var sessionManager          :  GCKSessionManager!
    private var observer                : NSKeyValueObservation?

    //MARK: - Life Cycles
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headerPlayerView.backgroundColor = .black
        self.addSubview(headerPlayerView)
        headerPlayerView.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-54)
        }
        
        thumbnailImage.image = UIImage.init(named: "default_thumbnail_image")
        self.addSubview(thumbnailImage)
        thumbnailImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom).offset(-54)
        }
                
        self.layoutIfNeeded()
        
        videoPlayerController.view.frame = headerPlayerView.bounds
        videoPlayerController.delegate = self
        videoPlayerController.videoGravity = .resizeAspect
        headerPlayerView.addSubview(videoPlayerController.view)
                
        let ctaView = UIView()
        ctaView.backgroundColor = .white
        self.addSubview(ctaView)
        ctaView.snp.makeConstraints { (make) in
            make.top.equalTo(headerPlayerView.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(54)
        }
        
        self.loadCTAView(ctaView: ctaView)
        
        loadingAnimation.isHidden = true
        loadingAnimation.backgroundColor = .black
        loadingAnimation.layer.opacity = 0.4
        self.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.bottom.equalTo(self.snp.bottom)
        }
        
        let loading = UIActivityIndicatorView()
        loading.style = .whiteLarge
        loading.startAnimating()
        loadingAnimation.addSubview(loading)
        loading.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)),
        name: kDownloadVideoDoneNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)),
        name: kDownloadVideoCancelNotification, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(noti:)),
                                               name: .AVPlayerItemDidPlayToEndTime,
                                               object: nil)
        sessionManager = GCKCastContext.sharedInstance().sessionManager
        sessionManager.add(self)
        videoPlayerController.addObserver(self, forKeyPath: #keyPath(AVPlayerViewController.videoBounds), options: [.old, .new], context: nil)

    }
    
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == #keyPath(AVPlayerViewController.videoBounds) {
            // detect only changes
            if let oldValue = change?[.oldKey] as? CGRect, oldValue != CGRect.zero, let newValue = change?[.newKey] as? CGRect {
                // no need to track the initial bounds change, and only changes
                if !oldValue.equalTo(CGRect.zero), !oldValue.equalTo(newValue) {
                    if newValue.size.height < UIScreen.main.bounds.height {
                        print("normal screen")
                        self.videoPlayerController.player?.seek(to: self.videoPlayerController.player?.currentTime() ?? CMTime.zero)
                    } else {
                        print("fullscreen")
                        self.videoPlayerController.player?.seek(to: self.videoPlayerController.player?.currentTime() ?? CMTime.zero)
                    }
                }
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
          self.videoPlayerController.player?.removeObserver(self, forKeyPath: "rate")
          self.observer = videoPlayerController.player?.observe(\.rate, options:  [.new, .old], changeHandler: { (player, change) in
               if player.rate == 1  {
                  bfprint(String(format:"removeObserver", "Playing"), tag: "AVPlayer", level: .default)
                }else{
                  bfprint(String(format:"removeObserver", "Stop"), tag: "AVPlayer", level: .default)
                }
           })

           // Later You Can Remove Observer
           self.observer?.invalidate()
           self.observer = nil
    }
    
    func getVideoData() -> VideoDataSource? {
        return videoDataSource
    }
    
    func setVideoDataSource(newVideoData: VideoDataSource) {
        
        self.pause()
        self.resetTrackingTime()
        
        self.videoDataSource = newVideoData
        
        if newVideoData.videoPlayUrl != "" {
            if let videoURL = URL(string:newVideoData.videoPlayUrl) {
                let videoPlayer = AVPlayer.init(url: videoURL)
                self.videoPlayerController.player = videoPlayer
              //  videoPlayerController.player?.automaticallyWaitsToMinimizeStalling = videoPlayerController.player?.currentItem?.isPlaybackBufferEmpty ?? false
              //  videoPlayerController.player?.currentItem?.preferredForwardBufferDuration = TimeInterval(0)
                self.play()
                videoPlayer.volume = 0.5
                
                self.videoStatusTimer = Timer.scheduledTimer(timeInterval: 0.1, target: self,
                                                             selector: #selector(videoStatusControlHasChange),
                                                             userInfo: nil, repeats: true)
                self.trackingWatchTimer = Timer.scheduledTimer(withTimeInterval: 10,
                                                               repeats: true,
                                                               block: { (timer) in
                                                                self.updateTrackingTimer()
                })
                self.loadingAnimation.isHidden = false
                
                if let imageURL = URL(string: newVideoData.imageThumnailStr) {
                    self.thumbnailImage.setImage(url: imageURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
                    self.thumbnailImage.isHidden = false
                }
                if isCastEnabled() {
                    loadItem()
                }
            }
        }
        
        if newVideoData.isFavorite {
            self.addWishListBtn.isSelected = true
        } else {
            self.addWishListBtn.isSelected = false
        }
        
        if _AppVideoManager.isVideoIsDownloading(videoID: newVideoData.videoID) {
            DispatchQueue.main.async {
                self.downloadActivityIndicator.startAnimating()
                self.downloadBtn.isHidden = true
            }
        } else {
            DispatchQueue.main.async {
                self.downloadActivityIndicator.stopAnimating()
                self.downloadBtn.isHidden = false
            }
        }
        
        let request = _AppDataHandler.getVideoInfo(videoID: newVideoData.videoID) { (isSuccess, error, newVideoData) in
            if isSuccess {
                self.videoDataSource = newVideoData
                if (self.videoDataSource?.isFavorite ?? false) {
                    self.addWishListBtn.isSelected = true
                }
            }
        }
        
        if request != nil {
            self.listRequest.append(request!)
        }
    }
    
    func setVideoURLString(videoURL: String) {
        self.videoDataSource = nil
        self.pause()
        self.resetTrackingTime()
        
        self.downloadBtn.isUserInteractionEnabled = false
        self.addWishListBtn.isUserInteractionEnabled = false
        
        if let videoURL = URL(string:videoURL) {
            let videoPlayer = AVPlayer.init(url: videoURL)
            self.videoPlayerController.player = videoPlayer
            self.play()
            
            self.videoStatusTimer = Timer.scheduledTimer(timeInterval: 0.2, target: self,
                                                         selector: #selector(videoStatusControlHasChange),
                                                         userInfo: nil, repeats: true)
            self.trackingWatchTimer = Timer.scheduledTimer(withTimeInterval: 10,
                                                           repeats: true,
                                                           block: { (timer) in
                                                            self.updateTrackingTimer()
            })
            self.loadingAnimation.isHidden = false
            if isCastEnabled() {
                loadItem()
            }
        }
    }
    
    //MARK: - UI/UX
    
    private func loadCTAView(ctaView: UIView) {
        let spaceView1 = UIView()
        ctaView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.left.equalToSuperview()
        }
        
        downloadBtn.setBackgroundImage(UIImage.init(named: "download_icon"), for: .normal)
        downloadBtn.addTarget(self, action: #selector(downloadButtonTapped), for: .touchUpInside)
        ctaView.addSubview(downloadBtn)
        downloadBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView1.snp.right)
        }
        
        downloadActivityIndicator.hidesWhenStopped = true
        ctaView.addSubview(downloadActivityIndicator)
        downloadActivityIndicator.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView1.snp.right)
        }
        
        let downloadTitle = UILabel()
        downloadTitle.text = NSLocalizedString("kDownloadBtn", comment: "")
        downloadTitle.font = setFontSize(size: 10, weight: .regular)
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
        
        castBtn.activeTintColor = UIColor.init(hexString: "b31d00ff")
        castBtn.tintColor = UIColor.gray
        ctaView.addSubview(castBtn)
        castBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView3.snp.right)
        }
        
        let castTitle = UILabel()
        castTitle.text = NSLocalizedString("kCastBtn", comment: "")
        castTitle.font = setFontSize(size: 10, weight: .regular)
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
            make.height.equalTo(18)
            make.width.equalTo(21)
            make.left.equalTo(spaceView4.snp.right)
        }
        
        favoriteActivityIndicator.hidesWhenStopped = true
        ctaView.addSubview(favoriteActivityIndicator)
        favoriteActivityIndicator.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.height.width.equalTo(18)
            make.left.equalTo(spaceView4.snp.right)
        }
        
        let addWishListTitle = UILabel()
        addWishListTitle.text = NSLocalizedString("kAddWishListBtn", comment: "")
        addWishListTitle.font = setFontSize(size: 10, weight: .regular)
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
    //MARK: - Video fullScreen
    
     func fullScreen() {
        if UIDevice.current.orientation.isLandscape {
            let selectorName: String = {
                if #available(iOS 11.3, *) {
                    return "_transitionToFullScreenAnimated:interactive:completionHandler:"
                } else  {
                    return "_transitionToFullScreenAnimated:completionHandler:"
                }
            }()
            let selectorToForceFullScreenMode = NSSelectorFromString(selectorName)
            
            videoPlayerController.performSelector(onMainThread: selectorToForceFullScreenMode, with: nil, waitUntilDone: true)
        }
    }
    
    //MARK: - Video Control Functions
    @objc private func downloadButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        if let videoData =  self.videoDataSource {
            DispatchQueue.main.async {
                self.downloadActivityIndicator.startAnimating()
                self.downloadBtn.isHidden = true
            }
            _AppVideoManager.requestDownloadVideo(videoData: videoData)
        }
    }
    
    @objc private func addWishButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        guard let videoData = self.videoDataSource else {
            return
        }
        
        if videoData.videoID == 0 {return}
        
        if self.addWishListBtn.isSelected {
            let alertVC = UIAlertController.init(title: NSLocalizedString("kRemoveFavorite", comment: ""),
                                                 message: NSLocalizedString("kRemovedSuccess", comment: ""),
                                                 preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                  style: .cancel) { (action) in
                                                    alertVC.dismiss(animated: true, completion: nil)
            }
            let okAction = UIAlertAction.init(title: "Sure!",
                                              style: .default) { (action) in
                                                self.unfavorite(videoID: videoData.videoID)
                                                alertVC.dismiss(animated: true, completion: nil)
            }
            
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            let topVC = UIApplication.shared.keyWindow?.rootViewController
            topVC?.present(alertVC, animated: true, completion: nil)
            return
            
        } else {
            
            self.favoriteActivityIndicator.startAnimating()
            self.addWishListBtn.isHidden = true
            
            _AppDataHandler.addVideoToFavorite(videoID: videoData.videoID)
            { (isSuccess, error) in
                
                self.favoriteActivityIndicator.stopAnimating()
                self.addWishListBtn.isHidden = false
                
                if isSuccess {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAddVideoFavoriteTitle", comment: ""),
                                                       message: NSLocalizedString("kAddVideoFavoriteMessage", comment: ""))
                    self.addWishListBtn.isSelected = true
                    return
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                    return
                }
            }
        }
    }
    
    func unfavorite(videoID: Int) {
        self.favoriteActivityIndicator.startAnimating()
        self.addWishListBtn.isHidden = true
        
        _AppDataHandler.removeVideoFromFavorite(videoID: videoID)
        { (isSuccess, error) in
            self.favoriteActivityIndicator.stopAnimating()
            self.addWishListBtn.isHidden = false
            if isSuccess {
                self.addWishListBtn.isSelected = false
                _NavController.presentAlertForCase(title: NSLocalizedString("kRemovedTitle", comment: ""),
                                                   message: NSLocalizedString("kRemovedMessage", comment: ""))
                return
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    //MARK: - Process
    
    func play() {
        self.videoPlayerController.player?.play()
    }
    
    func pause() {
        self.videoPlayerController.player?.pause()
      //  self.videoPlayerController.player?.seek(to: CMTime.zero)
        self.trackingWatchTimer?.invalidate()
        self.trackingWatchTimer = nil
    }
    
    func stop() {
        self.videoPlayerController.player?.pause()
        self.videoPlayerController.player = nil
        self.trackingWatchTimer?.invalidate()
        self.trackingWatchTimer = nil

        for request in self.listRequest {
            request.cancel()
        }
        
        self.listRequest = []
        
        self.removeFromSuperview()
    }
    
    //MARK: - Datas Change
 
    @objc private func handleNotification(noti: Notification) {
        
        if noti.name == kDownloadVideoDoneNotification || noti.name == kDownloadVideoCancelNotification {
            if let videoID = noti.userInfo?["video_id"] as? Int {
                if self.videoDataSource?.videoID == videoID {
                    DispatchQueue.main.async {
                        self.downloadActivityIndicator.stopAnimating()
                        self.downloadBtn.isHidden = false
                    }
                }
            }
        } else if noti.name == .AVPlayerItemDidPlayToEndTime {
            if let videoData = self.videoDataSource {
                if videoData.videoDuration == 0 {
                    return
                }
                
                if self.realWatchingTime >= videoData.videoDuration - 5 {
                    self.trackingWatchTimer?.invalidate()
                    self.trackingWatchTimer = nil
                    _AppDataHandler.trackingVideoWatch(videoData: videoData,
                                                       trackingPercent: 100.1)
                    NotificationCenter.default.post(name: kWatchVideoDoneNotification, object: nil, userInfo: ["video_id": videoData.videoID])
                    return
                }
            }
        }
    }
    
    private func didUpdateVideoDataSource() {
        if delegate != nil {
            delegate?.didUpdateNewDataSource?()
        }
    }
    
    private func updateTrackingTimer() {
        
        let userProfile = _AppDataHandler.getUserProfile()
        
        if userProfile.userPlan.contains("Trail") || userProfile.userPlan.contains("Freemium") {
            return
        }
        
        if (videoPlayerController.player?.timeControlStatus == .waitingToPlayAtSpecifiedRate) || (videoPlayerController.player?.timeControlStatus == .paused) {
            return
        }
        
        self.realWatchingTime += 10
        
        if self.realWatchingTime % 60 == 0 {
            if let videoData = self.videoDataSource {
                if videoData.videoDuration == 0 {
                    return
                }
            
                let value = (Double(self.realWatchingTime) / Double(videoData.videoDuration)) * 100
                _AppDataHandler.trackingVideoWatch(videoData: videoData,
                                                   trackingPercent: (value * 100).rounded() / 100)
            }
        }
    }
    
    private func resetTrackingTime() {
        self.realWatchingTime = 0
    }
    
    @objc private func videoStatusControlHasChange() {
                
        if self.videoPlayerController.player?.timeControlStatus == .playing {
            self.loadingAnimation.isHidden = true
            self.thumbnailImage.isHidden = true
            
            self.videoStatusTimer?.invalidate()
            self.videoStatusTimer = nil            
        }
    }
    
    //MARK: - AVPlayerViewControllerDelegate
    
    func playerViewController(_ playerViewController: AVPlayerViewController, willBeginFullScreenPresentationWithAnimationCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        self.play()
    }
    
    func isCastEnabled() -> Bool {
        switch GCKCastContext.sharedInstance().castState {
        case GCKCastState.connected:
            print("cast connected")
            hideControlVideo()
            return true
        case GCKCastState.connecting:
            hideControlVideo()
            print("cast connecting")
            return true
        case GCKCastState.notConnected:
            print("cast notConnected")
            showControlVideo()
            return false
        case GCKCastState.noDevicesAvailable:
            print("cast noDevicesAvailable")
            showControlVideo()
            return false
        }
    }
    
    func loadItem() {
        guard let video = self.videoDataSource  else { return }
        
        let metadata = GCKMediaMetadata()
        metadata.setString(video.videoTitle, forKey: kGCKMetadataKeyTitle)
        metadata.setString(video.videoDescription, forKey: kGCKMetadataKeyStudio)
        metadata.addImage(GCKImage(url: URL(string: video.imageThumnailStr)!,
                                       width: 480,
                                       height: 360))
        var mediaItems = [GCKMediaQueueItem]()
        let builder = GCKMediaQueueItemBuilder()
        let mediaInfoBuilder = GCKMediaInformationBuilder.init(contentURL: URL(string:video.videoPlayUrl)!)
            mediaInfoBuilder.streamType = GCKMediaStreamType.none;
            mediaInfoBuilder.metadata = metadata;
            let mediaInformation = mediaInfoBuilder.build()
            builder.mediaInformation = mediaInformation
            builder.autoplay = true
            builder.preloadTime = 3
            let item = builder.build
            mediaItems.append(item())

        if let remoteMediaClient = GCKCastContext.sharedInstance().sessionManager.currentCastSession?.remoteMediaClient {
            let loadOptions = GCKMediaQueueLoadOptions()
            loadOptions.repeatMode = .all
          //  loadOptions.startPosition = 0
            remoteMediaClient.queueLoad(mediaItems, with:loadOptions)
        }
    }
    
    func hideControlVideo() {
        self.videoPlayerController.contentOverlayView?.backgroundColor = .black
        self.videoPlayerController.player?.isMuted  = true
    }
    
    func showControlVideo() {
        self.videoPlayerController.contentOverlayView?.backgroundColor = .clear
        self.videoPlayerController.player?.isMuted  = false
    }
}

extension VW_VideoPlayer: GCKSessionManagerListener {
    // MARK: - GCKSessionManagerListener
    
    func sessionManager(_: GCKSessionManager, didStart session: GCKSession) {
        print("MediaViewController: sessionManager didStartSession \(session)")
        if isCastEnabled() {
            self.loadItem()
        }
    }
    
    func sessionManager(_: GCKSessionManager, didResumeSession session: GCKSession) {
        print("MediaViewController: sessionManager didResumeSession \(session)")
    }
    
    func sessionManager(_: GCKSessionManager, didEnd _: GCKSession, withError error: Error?) {
        print("session ended with error: \(String(describing: error))")
        let _ = "The Casting session has ended.\n\(String(describing: error))"
        self.showControlVideo()
    }
    
    func sessionManager(_: GCKSessionManager, didFailToStartSessionWithError error: Error?) {
    }
    
    func sessionManager(_: GCKSessionManager,
                        didFailToResumeSession _: GCKSession, withError _: Error?) {
    }
}

extension VW_VideoPlayer: GCKRequestDelegate {
    
}
