//
//  VC_UserDownloadedVideos.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import Alamofire

class VC_UserDownloadedVideos: UIViewController,
                            UITableViewDataSource, UITableViewDelegate,
                            TC_DownloadedVideoCellDelegate, ApplicationVideoManagerDelegate {
    
    let videoController         = AVPlayerViewController()
    
    let tableView               = UITableView()
    var listDownloadedVideo     : [VideoDownloadedDataSource] = _AppVideoManager.getListDownloadedVideo()
    
    let nodataLabel             = UILabel()
    
    let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    override func viewDidLoad() {
       super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backBtn
        
        videoController.entersFullScreenWhenPlaybackBegins = true
        videoController.exitsFullScreenWhenPlaybackEnds = true
        
        let focusTitle = UILabel()
        focusTitle.text = NSLocalizedString("kDownloaded", comment: "")
        focusTitle.font = setFontSize(size: 24, weight: .bold)
        focusTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(focusTitle)
        focusTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(30)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(TC_DownloadedVideoCell.self, forCellReuseIdentifier: "downloadedVideo")
        tableView.separatorStyle = .none
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(focusTitle.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        nodataLabel.isHidden = true
        nodataLabel.text = NSLocalizedString("kDownloadedNoData", comment: "")
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.view.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.nodataLabel.isHidden = !(self.listDownloadedVideo.count == 0)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: kDownloadVideoDeletedNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: kDownloadVideoDoneNotification, object: nil)
        
        _AppVideoManager.delegate = self
        self.checkNetwork()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Check network
    func checkNetwork() {
        self.networkReachabilityManager?.listener = { status in
            
            switch status {
            case .notReachable:
                //Show error here (no internet connection)
                if _AppVideoManager.getListDownloadedVideo().count > 0 {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kMessageTitle", comment: ""), message: NSLocalizedString("kMyDownloadVideoOfflineHaveVideo", comment: ""))
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kMessageTitle", comment: ""), message: NSLocalizedString("kMyDownloadVideoOfflineNoVideo", comment: ""))
                }
                break
            case .reachable(_):
                
                break
            case .unknown: break
            //Hide error here
            }
        }
        self.networkReachabilityManager?.startListening()
    }
    
    
    //MARK: - Button
    @objc func backButtonTapped() {
        
        let listViewController = _NavController.viewControllers
        if listViewController.first is VC_UserDownloadedVideos {
            let alertVC = UIAlertController.init(title: "Back to Live Mode?",
                                                 message: "Are your sure to back Live Mode?",
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: "Sure!",
                                              style: .default) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                _NavController.setViewControllers([VC_SubPageLunchSceen()], animated: true)
            }
            let cancelAction = UIAlertAction.init(title: "Cancel",
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
            }
            
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            
            self.present(alertVC, animated: true, completion: nil)
            return
        }
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func handleNotification(noti: Notification) {        
        
        if noti.name == kDownloadVideoDeletedNotification {
            self.listDownloadedVideo = _AppVideoManager.getListDownloadedVideo()
            self.tableView.reloadData()
        } else if noti.name == kDownloadVideoDoneNotification {
            DispatchQueue.main.async {
                self.listDownloadedVideo = _AppVideoManager.getListDownloadedVideo()
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listDownloadedVideo.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let screenWdith = UIScreen.main.bounds.size.width
        return screenWdith * 0.533
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "downloadedVideo", for: indexPath) as! TC_DownloadedVideoCell
        cell.delegate = self
        let cellData = self.listDownloadedVideo[indexPath.row]
        cell.setVideoData(newVideoData: cellData)
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellData = self.listDownloadedVideo[indexPath.row]
        
        if cellData.videoDownloadPercent < 1 {
            let alertVC = UIAlertController.init(title: NSLocalizedString("kSorryTitle", comment: ""), message: NSLocalizedString("kDownloadingMessage", comment: ""), preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kDownloadingContinuousBtn", comment: ""), style: .default)
            { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            
            let stopAction = UIAlertAction.init(title: NSLocalizedString("kDownloadingStopBtn", comment: ""),
                                                style: .cancel) { (action) in
                                                    _AppVideoManager.deleteVideo(videoData: cellData)
                                                    
            }
            
            alertVC.addAction(okAction)
            alertVC.addAction(stopAction)
            if let presentedVC = _NavController.presentedViewController {
                
                if presentedVC is UIAlertController {
                    return
                }
                
                presentedVC.present(alertVC, animated: true, completion: nil)
                return
            } else {
                _NavController.present(alertVC, animated: true, completion: nil)
            }
            
            return
        }
        
        var videoURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        videoURL = videoURL.appendingPathComponent(String(format: "Downloaded/%ld.mp4", cellData.videoID))
        
        let player = AVPlayer(url: videoURL)
        self.videoController.player = player
        
        self.present(self.videoController, animated: true, completion: nil)
        self.videoController.entersFullScreenWhenPlaybackBegins = true
        self.videoController.exitsFullScreenWhenPlaybackEnds = true
        player.play()
    }
    
    //MARK: - TC_DownloadedVideoCellDelegate
    func didDeleteVideo(videoData: VideoDownloadedDataSource) {
        
        let alertVC = UIAlertController.init(title: NSLocalizedString("kDeleteVideoTitle", comment: ""),
                                             message: NSLocalizedString("kDeleteVideoMessage", comment: ""),
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kDeleteVideoSureBtn", comment: ""),
                                          style: .default) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
                                            _AppVideoManager.deleteVideo(videoData: videoData)
                                            self.listDownloadedVideo = _AppVideoManager.getListDownloadedVideo()
                                            self.tableView.reloadData()
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                          style: .cancel) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    //MARK: - Delegate download
    func didUpdateDownloadProgess(video: VideoDownloadedDataSource, progress: Double) {
        DispatchQueue.main.async {
            if let index = self.listDownloadedVideo.firstIndex(of: video) {
                let videoDownloadedData = self.listDownloadedVideo[index]
                videoDownloadedData.videoDownloadPercent = Double(progress)
                self.listDownloadedVideo[index] = videoDownloadedData
                if let downloadVideoCell =
                    self.tableView.cellForRow(at: IndexPath(row: index,
                                                            section: 0)) as? TC_DownloadedVideoCell {
                    downloadVideoCell.progressDownload.progress = Float(progress)
                }
            }
            
            if progress == 1.0 {
                _NavController.presentAlertForCase(title: NSLocalizedString("kDownloadTitle", comment: ""),
                                                   message: "Video \"\(video.videoTitle)\" finished downloading.")
            }
        }
    }
}
