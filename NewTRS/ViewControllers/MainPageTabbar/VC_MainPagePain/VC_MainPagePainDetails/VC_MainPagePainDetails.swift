//
//  VC_MainPagePainDetails.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import GoogleCast

class VC_MainPagePainDetails: UIViewController,
                                VideoCellDelegate, VW_VideoPlayerDelegate {
    
    let videoPlayer             : VW_VideoPlayer = {
        var frame = UIScreen.main.bounds
        frame.size.height = frame.size.width*0.5625 + 54
        
        return VW_VideoPlayer.init(frame: frame)
    }()
    let pageScrollView          = UIScrollView()
    
    let videoTitleLabel         = UILabel()
    //let videoDescriptionLabel = UILabel()
    let videoDurationLabel      = UILabel()
    let videoTagLabel           = UILabel()
    
    let painAreaTitle           = UILabel()
    
    let understandDurationLabel = UILabel()
    let understandCountLabel    = UILabel()
    let understandScrollView    = UIScrollView()
    
    let mobilityDurationLabel   = UILabel()
    let mobilityCountLabel      = UILabel()
    let mobilityScrollView      = UIScrollView()
    
    let advancedDurationLabel   = UILabel()
    let advancedCountLabel      = UILabel()
    let advancedScrollView      = UIScrollView()
    
    let loadingAnimation        = VW_LoadingAnimation()
    var loadingAnimationCount   = 0
    
    //Datas
    private var painData                = SystemPainAreaDataSource.init(JSONString: "{}")!
    private var listUnderstandingPain   : [VideoDataSource] = []
    private var listMobilityRX          : [VideoDataSource] = []
    private var listAdvancedPain        : [VideoDataSource] = []
    private var listGettingStart        : [VideoDataSource] = []
    private var listRequest             : [Request] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let castButton = GCKUICastButton(frame: CGRect(x: 0, y: 0, width: 24, height: 24))
        castButton.tintColor = kBlueBackgroundColor
        let castBarButtonItem = UIBarButtonItem(customView: castButton)
        self.navigationItem.rightBarButtonItem = castBarButtonItem
        
        videoPlayer.delegate = self
        self.view.addSubview(videoPlayer)
        
        let ctaLine = UIView()
        ctaLine.backgroundColor = UIColor.init(hexString: "d8d8d8")
        self.view.addSubview(ctaLine)
        ctaLine.snp.makeConstraints { (make) in
            make.top.equalTo(videoPlayer.snp.bottom)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(1)
        }
        
        pageScrollView.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScrollView)
        pageScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(ctaLine)
            make.left.right.bottom.equalToSuperview()
        }
        
        self.loadVideoInfoView(ctaLine: ctaLine)
        
        painAreaTitle.font = setFontSize(size: 24, weight: .regular)
        painAreaTitle.textColor = UIColor.init(hexString: "333333")
        painAreaTitle.textAlignment = .center
        painAreaTitle.numberOfLines = 0
        self.pageScrollView.addSubview(painAreaTitle)
        painAreaTitle.snp.makeConstraints { (make) in
            make.top.equalTo(videoTagLabel.snp.bottom).offset(60)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        let understandingTitle = UILabel()
        understandingTitle.text = NSLocalizedString("kUnderstandingPain", comment: "")
        understandingTitle.font = setFontSize(size: 18, weight: .semibold)
        understandingTitle.textColor = UIColor.init(hexString: "333333")
        understandingTitle.textAlignment = .center
        self.pageScrollView.addSubview(understandingTitle)
        understandingTitle.snp.makeConstraints { (make) in
            make.top.equalTo(painAreaTitle.snp.bottom).offset(10)
            make.height.equalTo(18)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.loadUderstandingInfoView(infoTitle: understandingTitle)
        
        understandScrollView.showsHorizontalScrollIndicator = false
        self.pageScrollView.addSubview(understandScrollView)
        understandScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(understandingTitle.snp.bottom).offset(33)
            make.left.right.width.equalToSuperview()
            make.height.equalTo(140)
        }
        
        let mobilityRXTitle = UILabel()
        mobilityRXTitle.text = NSLocalizedString("kMobilityRX", comment: "")
        mobilityRXTitle.font = setFontSize(size: 18, weight: .semibold)
        mobilityRXTitle.textColor = UIColor.init(hexString: "333333")
        mobilityRXTitle.textAlignment = .center
        mobilityRXTitle.numberOfLines = 0
        self.pageScrollView.addSubview(mobilityRXTitle)
        mobilityRXTitle.snp.makeConstraints { (make) in
            make.top.equalTo(understandScrollView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.loadMobilityInfoView(infoTitle: mobilityRXTitle)
        
        mobilityScrollView.showsHorizontalScrollIndicator = false
        self.pageScrollView.addSubview(mobilityScrollView)
        mobilityScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(mobilityRXTitle.snp.bottom).offset(33)
            make.left.right.width.equalToSuperview()
            make.height.equalTo(140)
        }
        
        let advancedPainTitle = UILabel()
        advancedPainTitle.text = NSLocalizedString("kAdvancedPain", comment: "")
        advancedPainTitle.font = setFontSize(size: 18, weight: .semibold)
        advancedPainTitle.textColor = UIColor.init(hexString: "333333")
        advancedPainTitle.textAlignment = .center
        self.pageScrollView.addSubview(advancedPainTitle)
        advancedPainTitle.snp.makeConstraints { (make) in
            make.top.equalTo(mobilityScrollView.snp.bottom).offset(30)
            make.height.equalTo(18)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.loadAdvancedInfoView(infoTitle: advancedPainTitle)
        
        advancedScrollView.showsHorizontalScrollIndicator = false
        self.pageScrollView.addSubview(advancedScrollView)
        advancedScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(advancedPainTitle.snp.bottom).offset(33)
            make.left.right.width.equalToSuperview()
            make.height.equalTo(140)
            make.bottom.equalToSuperview().offset(-50)
        }
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        videoPlayer.play()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayer.pause()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Layouts
    
    func loadVideoInfoView(ctaLine: UIView) {
        //Video title
        videoTitleLabel.text = ""
        videoTitleLabel.font = setFontSize(size: 18, weight: .semibold)
        videoTitleLabel.textColor = UIColor.init(hexString: "333333")
        videoTitleLabel.numberOfLines = 0
        videoTitleLabel.textAlignment = .center
        self.pageScrollView.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
//        videoDescriptionLabel.text = "Get the most out of your Prescriptions"
//        videoDescriptionLabel.font = setFontSize(size: 14, weight: .regular)
//        videoDescriptionLabel.textColor = UIColor.init(hexString: "333333")
//        videoDescriptionLabel.textAlignment = .center
//        self.view.addSubview(videoDescriptionLabel)
//        videoDescriptionLabel.snp.makeConstraints { (make) in
//            make.top.equalTo(videoTitleLabel.snp.bottom).offset(6)
//            make.centerX.width.equalToSuperview()
//            make.height.equalTo(20)
//        }
        
        let spaceView1 = UIView()
        self.view.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(6)
            make.left.equalTo(videoTitleLabel.snp.left)
            make.height.equalTo(11)
        }
        
        videoDurationLabel.text = "6:49"
        videoDurationLabel.font = setFontSize(size: 11, weight: .semibold)
        videoDurationLabel.textColor = UIColor.init(hexString: "333333")
        self.pageScrollView.addSubview(videoDurationLabel)
        videoDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(6)
            make.left.equalTo(spaceView1.snp.right)
            make.height.equalTo(11)
        }
        
        let spaceView = UIView()
        self.pageScrollView.addSubview(spaceView)
        spaceView.snp.makeConstraints { (make) in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(6)
            make.left.equalTo(videoDurationLabel.snp.right)
            make.width.height.equalTo(11)
        }
        
        videoTagLabel.text = "Video & Audio"
        videoTagLabel.font = setFontSize(size: 11, weight: .regular)
        videoTagLabel.textColor = UIColor.init(hexString: "a5a5a5")
        self.pageScrollView.addSubview(videoTagLabel)
        videoTagLabel.snp.makeConstraints { (make) in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(6)
            make.left.equalTo(spaceView.snp.right)
            make.height.equalTo(11)
        }
        
        let spaceView2 = UIView()
        self.pageScrollView.addSubview(spaceView2)
        spaceView2.snp.makeConstraints { (make) in
            make.top.equalTo(videoTitleLabel.snp.bottom).offset(6)
            make.left.equalTo(videoTagLabel.snp.right)
            make.right.equalTo(videoTitleLabel)
            make.width.equalTo(spaceView1)
            make.height.equalTo(11)
        }
        
        let videoInfoLine = UIView()
        videoInfoLine.backgroundColor = UIColor.init(hexString: "d8d8d8")
        self.pageScrollView.addSubview(videoInfoLine)
        videoInfoLine.snp.makeConstraints { (make) in
            make.top.equalTo(videoTagLabel.snp.bottom).offset(30)
            make.centerX.width.equalToSuperview()
            make.height.equalTo(1)
        }
    }
    
    func loadUderstandingInfoView(infoTitle: UIView) {
        
        let spaceView1 = UIView()
        self.pageScrollView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(infoTitle)
            make.height.equalTo(11)
        }
        
        self.pageScrollView.addSubview(understandDurationLabel)
        understandDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(spaceView1.snp.right)
            make.height.equalTo(11)
        }
        
        let spaceView = UIView()
        spaceView.backgroundColor = UIColor.init(hexString: "888888")
        spaceView.layer.cornerRadius = 2
        self.pageScrollView.addSubview(spaceView)
        spaceView.snp.makeConstraints { (make) in
            make.centerY.equalTo(understandDurationLabel)
            make.left.equalTo(understandDurationLabel.snp.right).offset(6)
            make.width.height.equalTo(4)
        }
        
        self.pageScrollView.addSubview(understandCountLabel)
        understandCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(spaceView.snp.right).offset(6)
            make.height.equalTo(11)
        }
        
        let spaceView2 = UIView()
        self.pageScrollView.addSubview(spaceView2)
        spaceView2.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(understandCountLabel.snp.right)
            make.right.equalTo(infoTitle)
            make.width.equalTo(spaceView1)
            make.height.equalTo(11)
        }
    }
    
    func loadMobilityInfoView(infoTitle: UIView) {
        
        let spaceView1 = UIView()
        self.pageScrollView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(infoTitle)
            make.height.equalTo(11)
        }
        
        self.pageScrollView.addSubview(mobilityDurationLabel)
        mobilityDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(spaceView1.snp.right)
            make.height.equalTo(11)
        }
        
        let spaceView = UIView()
        spaceView.backgroundColor = UIColor.init(hexString: "888888")
        spaceView.layer.cornerRadius = 2
        self.pageScrollView.addSubview(spaceView)
        spaceView.snp.makeConstraints { (make) in
            make.centerY.equalTo(mobilityDurationLabel)
            make.left.equalTo(mobilityDurationLabel.snp.right).offset(6)
            make.width.height.equalTo(4)
        }
        
        self.pageScrollView.addSubview(mobilityCountLabel)
        mobilityCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(spaceView.snp.right).offset(6)
            make.height.equalTo(11)
        }
        
        let spaceView2 = UIView()
        self.pageScrollView.addSubview(spaceView2)
        spaceView2.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(mobilityCountLabel.snp.right)
            make.right.equalTo(infoTitle)
            make.width.equalTo(spaceView1)
            make.height.equalTo(11)
        }
    }
    
    func loadAdvancedInfoView(infoTitle: UIView) {
        
        let spaceView1 = UIView()
        self.pageScrollView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(infoTitle)
            make.height.equalTo(11)
        }
        
        self.pageScrollView.addSubview(advancedDurationLabel)
        advancedDurationLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(spaceView1.snp.right)
            make.height.equalTo(11)
        }
        
        let spaceView = UIView()
        spaceView.backgroundColor = UIColor.init(hexString: "888888")
        spaceView.layer.cornerRadius = 2
        self.pageScrollView.addSubview(spaceView)
        spaceView.snp.makeConstraints { (make) in
            make.centerY.equalTo(advancedDurationLabel)
            make.left.equalTo(advancedDurationLabel.snp.right).offset(6)
            make.width.height.equalTo(4)
        }
        
        self.pageScrollView.addSubview(advancedCountLabel)
        advancedCountLabel.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(spaceView.snp.right).offset(6)
            make.height.equalTo(11)
        }
        
        let spaceView2 = UIView()
        self.pageScrollView.addSubview(spaceView2)
        spaceView2.snp.makeConstraints { (make) in
            make.top.equalTo(infoTitle.snp.bottom).offset(6)
            make.left.equalTo(advancedCountLabel.snp.right)
            make.right.equalTo(infoTitle)
            make.width.equalTo(spaceView1)
            make.height.equalTo(11)
        }
    }
    
    //MARK: - Button
    
    @objc func backButtonTapped() {
        self.videoPlayer.stop()
        for request in self.listRequest {
            request.cancel()
        }
        self.listRequest = []
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func toolTip() {
        _NavController.presentAlertForFreemium()
    }
    
    @objc private func handleNotification(noti: Notification) {
        if noti.name == UIDevice.orientationDidChangeNotification {
            self.videoPlayer.fullScreen()
        }
    }
    // MARK: - Datas
    
    func setPainData(newPainData: SystemPainAreaDataSource) {
        self.painData = newPainData
        self.reloadData()
    }
    
    private func setVideoDataSource(newVideoDataSource: VideoDataSource) {
        
        self.videoPlayer.setVideoDataSource(newVideoData: newVideoDataSource)
        self.videoTitleLabel.text = newVideoDataSource.videoTitle
        let durationAttributedString = _AppDataHandler.timeAttributedString(seconds: newVideoDataSource.videoDuration, color: UIColor.init(hexString: "333333")!, fontActive: setFontSize(size: 11, weight: .semibold), fontInactive: setFontSize(size: 11, weight: .regular))
        self.videoDurationLabel.attributedText = durationAttributedString
    }
    
    func reloadData() {
        
        self.painAreaTitle.text = self.painData.painAreaTitle
        
        self.loadingAnimation.isHidden = false
        
        let request = _AppDataHandler.getGettingStartedPainVideos(painID: "\(self.painData.painAreaId)")
        { (isSuccess, error, gettingStartedVideo) in
            self.checkLoadingAnimation()
            if isSuccess {
                
                self.setVideoDataSource(newVideoDataSource: gettingStartedVideo!)
                self.listGettingStart = [gettingStartedVideo!]
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
        let request1 = _AppDataHandler.getUnderstandingPainVideos(painID: "\(self.painData.painAreaId)") { (isSuccess, error, listUnderstandingVideos) in
            
            self.checkLoadingAnimation()
            
            if isSuccess {
                var list = listUnderstandingVideos
                if self.listGettingStart.count > 0 {
                    list.insert(self.listGettingStart.first!, at: 0)
                }
                self.listUnderstandingPain = list
                self.reloadUnderstandingInfo()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
        let request2 = _AppDataHandler.getMobilityRXVideos(painID: "\(self.painData.painAreaId)") { (isSuccess, error, listMobilityRXVideos) in
            
            self.checkLoadingAnimation()
            
            if isSuccess {
                self.listMobilityRX = listMobilityRXVideos
                self.reloadMobilityInfo()
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
        let request3 = _AppDataHandler.getAdvancedPainVideos(painID: "\(self.painData.painAreaId)") { (isSuccess, error, listAdvancedPainVideos) in
            
            self.checkLoadingAnimation()
            
            if isSuccess {
                self.listAdvancedPain = listAdvancedPainVideos
                self.reloadAdvancedInfo()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
        
        if request != nil {
            self.listRequest.append(request!)
        }
        
        if request1 != nil {
            self.listRequest.append(request1!)
        }
        
        if request2 != nil {
            self.listRequest.append(request2!)
        }
        
        if request3 != nil {
            self.listRequest.append(request3!)
        }
    }
    
    func checkLoadingAnimation() {
        self.loadingAnimationCount += 1
        if self.loadingAnimationCount == 4 {
            self.loadingAnimation.isHidden = true
        }
    }
    
    func reloadUnderstandingInfo() {
        
        var totalDuration = 0
        for videoData in listUnderstandingPain {
            totalDuration += videoData.videoDuration
        }
        
        var videoCountStr = "videos"
        if listUnderstandingPain.count == 1 { videoCountStr = "video" }
        let numberStr = String(format: "%ld", listUnderstandingPain.count)
        let videoAttributedStr = NSMutableAttributedString(string: String(format: "%ld \(videoCountStr)", listUnderstandingPain.count))
        videoAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: UIColor.init(hexString: "a5a5a5")!,
                                          range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .regular),
                                        range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .semibold),
                                          range: NSMakeRange(0, numberStr.count))
        understandDurationLabel.attributedText = videoAttributedStr
        
        let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: totalDuration,
                                                                         color: UIColor.init(hexString: "a5a5a5")!,
                                                                         fontActive: setFontSize(size: 11, weight: .semibold),
                                                                         fontInactive: setFontSize(size: 11, weight: .regular))
        understandCountLabel.attributedText = durationAttributedStr
        
        self.reloadUnderstaningScrollView()
    }
    
    func reloadUnderstaningScrollView() {
        
        for subview in self.understandScrollView.subviews {
            subview.removeFromSuperview()
        }
                
        var frame = CGRect.init(x: 0, y: 0, width: 250, height: 140)
        var index = 0
        
        for videoData in self.listUnderstandingPain {
            
            frame.origin.x = CGFloat(20 + index*(250 + 10))
            
            let videoCell = VW_RetangleVideoViewCellTagging.init(frame: frame)
            videoCell.showPrePostLabel(isHidden: true)
            videoCell.reloadLayout()
            videoCell.delegate = self
            self.understandScrollView.addSubview(videoCell)
            
            videoCell.setVideoDataSource(newVideoData: videoData)
            
            if self.videoPlayer.getVideoData()?.videoID == videoData.videoID {
                videoCell.setCellIsPlaying(isPlaying: true)
            } else {
                videoCell.setCellIsPlaying(isPlaying: false)
            }
            
            index += 1
        }
        
        self.understandScrollView.contentSize = CGSize(width: CGFloat(30 + index*(250 + 10)), height: 140)
    }
    
    func reloadMobilityInfo() {
        
        var totalDuration = 0
        for videoData in listMobilityRX {
            totalDuration += videoData.videoDuration
        }
        
        var videoCountStr = "videos"
        if listMobilityRX.count == 1 { videoCountStr = "video" }
        let numberStr = String(format: "%ld", listMobilityRX.count)
        let videoAttributedStr = NSMutableAttributedString(string: String(format: "%ld \(videoCountStr)", listMobilityRX.count))
        videoAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: UIColor.init(hexString: "a5a5a5")!,
                                          range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .regular),
                                        range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .semibold),
                                          range: NSMakeRange(0, numberStr.count))
        mobilityDurationLabel.attributedText = videoAttributedStr
        
        let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: totalDuration,
                                                                         color: UIColor.init(hexString: "a5a5a5")!,
                                                                         fontActive: setFontSize(size: 11, weight: .semibold),
                                                                         fontInactive: setFontSize(size: 11, weight: .regular))
        mobilityCountLabel.attributedText = durationAttributedStr
        
        self.reloadMobilityScrollView()
        
    }
    
    func reloadMobilityScrollView() {
        
        for subview in self.mobilityScrollView.subviews {
            subview.removeFromSuperview()
        }
        
        var frame = CGRect.init(x: 0, y: 0, width: 250, height: 140)
        var index = 0
        
        for videoData in listMobilityRX {
            
            frame.origin.x = CGFloat(20 + index*(250 + 10))
            
            let videoCell = VW_RetangleVideoViewCellTagging.init(frame: frame)
            videoCell.showPrePostLabel(isHidden: true)
            videoCell.reloadLayout()
            videoCell.delegate = self
            self.mobilityScrollView.addSubview(videoCell)
            
            videoCell.setVideoDataSource(newVideoData: videoData)
            
            if self.videoPlayer.getVideoData()?.videoID == videoData.videoID {
                videoCell.setCellIsPlaying(isPlaying: true)
            } else {
                videoCell.setCellIsPlaying(isPlaying: false)
            }
            
            index += 1
        }
        
        self.mobilityScrollView.contentSize = CGSize(width: CGFloat(30 + index*(250 + 10)), height: 140)
    }
    
    func reloadAdvancedInfo() {
        
        var totalDuration = 0
        for videoData in listAdvancedPain {
            totalDuration += videoData.videoDuration
        }
        
        var videoCountStr = "videos"
        if listAdvancedPain.count == 1 { videoCountStr = "video" }
        let numberStr = String(format: "%ld", listAdvancedPain.count)
        let videoAttributedStr = NSMutableAttributedString(string: String(format: "%ld \(videoCountStr)", listAdvancedPain.count))
        videoAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: UIColor.init(hexString: "a5a5a5")!,
                                          range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .regular),
                                        range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value:setFontSize(size: 11, weight: .semibold),
                                          range: NSMakeRange(0, numberStr.count))
        advancedDurationLabel.attributedText = videoAttributedStr
        
        let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: totalDuration,
                                                                         color: UIColor.init(hexString: "a5a5a5")!,
                                                                         fontActive: setFontSize(size: 11, weight: .semibold),
                                                                         fontInactive: setFontSize(size: 11, weight: .regular))
        advancedCountLabel.attributedText = durationAttributedStr
        
        self.reloadAdvancedScrollView()
    }
    
    func reloadAdvancedScrollView() {
        
        for subview in self.advancedScrollView.subviews {
            subview.removeFromSuperview()
        }
                
        var frame = CGRect.init(x: 0, y: 0, width: 250, height: 140)
        var index = 0
        
        for videoData in self.listAdvancedPain {
            
            frame.origin.x = CGFloat(20 + index*(250 + 10))
            
            let videoCell = VW_RetangleVideoViewCellTagging.init(frame: frame)
            videoCell.showPrePostLabel(isHidden: true)
            videoCell.reloadLayout()
            videoCell.delegate = self
            self.advancedScrollView.addSubview(videoCell)
            
            videoCell.setVideoDataSource(newVideoData: videoData)
            
            if self.videoPlayer.getVideoData()?.videoID == videoData.videoID {
                videoCell.setCellIsPlaying(isPlaying: true)
            } else {
                videoCell.setCellIsPlaying(isPlaying: false)
            }
            
            index += 1
        }
        
        self.advancedScrollView.contentSize = CGSize(width: CGFloat(30 + index*(250 + 10)), height: 140)
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        
        self.setVideoDataSource(newVideoDataSource: videoData)
        self.reloadUnderstaningScrollView()
        self.reloadMobilityScrollView()
        self.reloadAdvancedScrollView()
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            NotificationCenter.default.post(name: kDownloadVideoCancelNotification, object: nil, userInfo: ["video_id": videoData.videoID])
            return
        }
        
        _AppVideoManager.requestDownloadVideo(videoData: videoData)
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
    }
}
