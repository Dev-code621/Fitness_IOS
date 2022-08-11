//
//  VC_SubPageFavorite.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_SubPageFavorite: UIViewController, VideoCellDelegate,
                        UICollectionViewDataSource, UICollectionViewDelegate,
                        UICollectionViewDelegateFlowLayout  {
    
    var collectionView      : UICollectionView?
    var listFavoriteVideos  : [VideoDataSource] = []
    let loadingAnimation    = VW_LoadingAnimation()
    
    let nodataLabel         = UILabel()
    
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
        pageTitle.text = NSLocalizedString("kFavorite", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalTo(closeBtn.snp.bottom).offset(15)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 20, bottom: 10, right: 20)
        
        self.collectionView = UICollectionView.init(frame: .zero, collectionViewLayout: layout)
        self.collectionView?.register(CC_SquareVideoCell.self, forCellWithReuseIdentifier: "videoCell")
        self.collectionView?.dataSource = self
        self.collectionView?.delegate = self
        self.collectionView?.backgroundColor = .white
        self.view.addSubview(collectionView!)
        collectionView?.snp.makeConstraints({ (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(16)
            make.centerX.width.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
        })
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        nodataLabel.isHidden = true
        nodataLabel.text = NSLocalizedString("kFavoriteNoDataMeaage", comment: "")
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.view.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }

        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(noti:)),
                                               name: kUserProfileHasChangeNotification,
                                               object: nil)
        
        self.reloadData()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - Data
    func reloadData() {
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getListFavoriteVideo { (isSuccess, error, listVideo) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.listFavoriteVideos = listVideo
                self.collectionView?.reloadData()
                self.nodataLabel.isHidden = !(listVideo.count == 0)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
    
    @objc private func handleNotification(noti: Notification) {
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - Buttons
    
    @objc func backButtonTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func closeButtonTapped() {
        if self.navigationController != nil {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return self.listFavoriteVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! CC_SquareVideoCell
        cell.deleteBtn.isHidden = false
        cell.delegate = self
        
        let cellData = self.listFavoriteVideos[indexPath.row]
        cell.updateVideoData(videoData: cellData)
        
        return cell
    }
    
    //MARK: - UICollectionViewDelegateFlowLayout
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (UIScreen.main.bounds.size.width - 50)/2
        return CGSize(width: width, height: width + 56)
    }
    
    //MARK: - UICollectionViewDelegate
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        self.dismiss(animated: true, completion: nil)
        
        let cellData = self.listFavoriteVideos[indexPath.row]
        let videoPlayerVC = VC_SubPageVideoPlayer()
        videoPlayerVC.setVideoDataSource(newVideoDataSource: cellData)
        _NavController.pushViewController(videoPlayerVC, animated: true)
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        
        self.dismiss(animated: true, completion: nil)
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            let iapVC = VC_InAppPurchase()
            self.navigationController?.pushViewController(iapVC, animated: true)
            return
        }
        
        let videoPlayerVC = VC_SubPageVideoPlayer()
        videoPlayerVC.setVideoDataSource(newVideoDataSource: videoData)
        _NavController.pushViewController(videoPlayerVC, animated: true)
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        _AppVideoManager.requestDownloadVideo(videoData: videoData)
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        
        let alertVC = UIAlertController.init(title: NSLocalizedString("kRemoveFavorite", comment: ""),
                                             message: NSLocalizedString("kRemovedSuccess", comment: ""),
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "Sure!",
                                          style: .default) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
                                            
                                            self.loadingAnimation.isHidden = false
                                            _AppDataHandler.removeVideoFromFavorite(videoID: videoData.videoID)
                                            { (isSuccess, error) in
                                                
                                                self.loadingAnimation.isHidden = true
                                                if isSuccess {
                                                    self.reloadData()
                                                    _NavController.presentAlertForCase(title: NSLocalizedString("kRemovedTitle", comment: ""),
                                                                                       message: NSLocalizedString("kRemovedMessage", comment: ""))
                                                } else {
                                                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
                                                                                       message: error)
                                                    return
                                                }
                                            }
        }
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                          style: .cancel) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(okAction)
        alertVC.addAction(cancelAction)
        
        self.present(alertVC, animated: true, completion: nil)
    }
}
