//
//  VC_MainPageMiniQA.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import GoogleCast

class VC_MainPageBonusContentDetails: UIViewController,
                                    VW_VideoPlayerDelegate,
                                    UITableViewDataSource, UITableViewDelegate {
    
    let videoPlayer             : VW_VideoPlayer = {
        var frame = UIScreen.main.bounds
        frame.size.height = frame.size.width*0.5625 + 54
        
        return VW_VideoPlayer.init(frame: frame)
    }()
    
    let pageTitle               = UILabel()
    let videoCountLabel         = UILabel()
    let totalDurationLabel      = UILabel()
    let tableView               = UITableView()
    let nodataLabel             = UILabel()
    
    let loadingAnimation        = VW_LoadingAnimation()
    var loadingAnimationCount   = 0
    var currentPage             : Int = 1
    var isLoadingList           : Bool = false
    
    private var dataSource      = SystemBonusDataSource.init(JSONString: "{}")!
    private var listVideo       : [VideoDataSource] = []
    private var listRequest     : [Request] = []
    private var paging          : PagingDataSource?
        
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
                
        pageTitle.text = NSLocalizedString("kMiniQA", comment: "")
        pageTitle.font = setFontSize(size: 18, weight: .semibold)
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
        
        nodataLabel.isHidden = true
        nodataLabel.text = NSLocalizedString("kBonusContenNoData", comment: "")
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.view.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.top.equalTo(videoPlayer.snp.bottom)
            make.centerX.bottom.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleWatchVideoDoneNotification(noti:)),
                                               name: kWatchVideoDoneNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        videoPlayer.play()
        NotificationCenter.default.addObserver(self, selector: #selector(handleWatchVideoDoneNotification(noti:)), name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayer.pause()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Load UI
    
    func loadInfoView(infoView: UIView) {
        
        // 23 videos, total 3 hours
        let videoAttributedStr = NSMutableAttributedString(string: String(format: "%ld videos", 0))
        videoAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: UIColor.init(hexString: "a5a5a5")!,
                                          range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .regular),
                                        range: NSMakeRange(0, videoAttributedStr.length))
        videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                          value: setFontSize(size: 11, weight: .semibold),
                                          range: NSMakeRange(0, 2))
        self.videoCountLabel.attributedText = videoAttributedStr
        
        let durationAttributedStr = NSMutableAttributedString(string: String(format: "%ld min", 0))
        durationAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: UIColor.init(hexString: "a5a5a5")!,
                                          range: NSMakeRange(0, durationAttributedStr.length))
        durationAttributedStr.addAttribute(NSAttributedString.Key.font,
                                        value: setFontSize(size: 11, weight: .regular),
                                        range: NSMakeRange(0, durationAttributedStr.length))
        durationAttributedStr.addAttribute(NSAttributedString.Key.font,
                                          value: setFontSize(size: 11, weight: .semibold),
                                          range: NSMakeRange(0, 2))
        self.totalDurationLabel.attributedText = durationAttributedStr
        
        let spaceView1 = UIView()
        infoView.addSubview(spaceView1)
        spaceView1.snp.makeConstraints { (make) in
            make.centerY.equalToSuperview()
            make.left.equalTo(infoView)
        }
        
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
            make.centerY.equalTo(videoCountLabel)
            make.left.equalTo(videoCountLabel.snp.right).offset(6)
            make.width.height.equalTo(4)
        }
        
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
    
    //MARK: - Buttons
    @objc func backButtonTapped() {
        self.videoPlayer.stop()
        for request in self.listRequest {
            request.cancel()
        }
        self.listRequest = []
        
        self.navigationController?.popViewController(animated: true)
    }

    //MARK: - Reload Data
    func setDataSource(newDataSource: SystemBonusDataSource) {
        self.dataSource = newDataSource
        self.reloadData()
    }
    
    func reloadData() {
        
        if self.dataSource.bonusId == 0 {return}
        
        self.pageTitle.text = self.dataSource.bonusTitle
        
        self.loadingAnimation.isHidden = false
        let request = _AppDataHandler.getListBonusVideo(bonusID: self.dataSource.bonusId,
                                                        page: currentPage,
                                                        limit: 20)
        { (isSuccess, error, paging, listVideo) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.isLoadingList = false
                if self.paging?.currentPage != self.currentPage && self.paging?.currentPage != nil {
                    var list = self.listVideo
                    list.append(contentsOf: listVideo)
                    self.listVideo = list
                } else {
                    self.listVideo = listVideo
                }
                self.paging = paging
                self.nodataLabel.isHidden = !(self.listVideo.count == 0)
                
                //Play first video
                if let firstVideo = self.listVideo.first {
                    self.videoPlayer.setVideoDataSource(newVideoData: firstVideo)
                }
               
                var totalDuration = 0
                for videoData in self.listVideo {
                    totalDuration += videoData.videoDuration
                }
                
                // 23 videos, total 3 hours
                var videoCountStr = "videos"
                if self.listVideo.count == 1 { videoCountStr = "video" }
                let numberStr = String(format: "%ld", self.listVideo.count)
                let videoAttributedStr = NSMutableAttributedString(string: String(format: "%ld \(videoCountStr)", self.listVideo.count))
                videoAttributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                                value: UIColor.init(hexString: "a5a5a5")!,
                                                  range: NSMakeRange(0, videoAttributedStr.length))
                videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                                value: setFontSize(size: 11, weight: .regular),
                                                range: NSMakeRange(0, videoAttributedStr.length))
                videoAttributedStr.addAttribute(NSAttributedString.Key.font,
                                                  value: setFontSize(size: 11, weight: .semibold),
                                                  range: NSMakeRange(0, numberStr.count))
                self.videoCountLabel.attributedText = videoAttributedStr
                
                let durationAttributedStr = _AppDataHandler.timeAttributedString(seconds: totalDuration,
                                                                                 color: UIColor.init(hexString: "a5a5a5")!,
                                                                                 fontActive: setFontSize(size: 11, weight: .semibold),
                                                                                 fontInactive: setFontSize(size: 11, weight: .regular))
                self.totalDurationLabel.attributedText = durationAttributedStr
                
                self.tableView.reloadData()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
        
        if request != nil {
            self.listRequest.append(request!)
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
        
        let cellData = self.listVideo[indexPath.row]
        cell.setDataSource(videoData: cellData)
        
        if self.videoPlayer.getVideoData()?.videoID == cellData.videoID {
            cell.setCellIsPlaying(isPlaying: true)
        } else {
            cell.setCellIsPlaying(isPlaying: false)
        }
        
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
        
        self.videoPlayer.setVideoDataSource(newVideoData: videoData)
        
        //mark cell as playing
        tableView.reloadData()
    }
    
    //MARK: - Listen Notification
    @objc private func handleWatchVideoDoneNotification(noti: Notification) {
        if noti.name.rawValue == kWatchVideoDoneNotification.rawValue {
            NotificationCenter.default.removeObserver(kWatchVideoDoneNotification)
            if let videoID = noti.userInfo?["video_id"] as? Int {
                if var index = listVideo.firstIndex(where: {$0.videoID == videoID}) {
                    index += 1
                    if (index == listVideo.count) {
                        _NavController.presentAlertForCase(title: NSLocalizedString("kCongratulationTitle", comment: ""), message: NSLocalizedString("kFinishedVideoMessage", comment: ""))
                    } else if index < listVideo.count {
                        
                         _NavController.presentAlertForCase(title: NSLocalizedString("kCongratulationTitle", comment: ""), message: NSLocalizedString("kFinishedVideoMessage", comment: "")) //kOnePointMessage
        
                        let videoData = self.listVideo[index]
                        self.videoPlayer.setVideoDataSource(newVideoData: videoData)
                        tableView.reloadData()
                    }
                }
            }
        }
        else if noti.name == UIDevice.orientationDidChangeNotification {
            self.videoPlayer.fullScreen()
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            if paging!.maxPage > currentPage {
                isLoadingList = true
                currentPage += 1
                self.reloadData()
            }
        }
    }
}
