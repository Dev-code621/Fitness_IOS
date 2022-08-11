//
//  VC_MainPageSearchResults.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/15/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageSearchResults: UIViewController,
                                UICollectionViewDataSource, UICollectionViewDelegate,
                                UICollectionViewDelegateFlowLayout {
    
    var collectionView      : UICollectionView?
    var nodataLabel         = UILabel()
    
    var searchKeyword       = ""
    var searchFocusAreas    : [String] = []
    
    var videoResults        : [VideoDataSource] = []
    
    let loadingAnimation    = VW_LoadingAnimation()
    
    private var currentPage         : Int = 1
    private var isLoadingList       : Bool = false
    private var paging              : PagingDataSource?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kSearchResults", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
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
        
        nodataLabel.isHidden = true
        nodataLabel.text = NSLocalizedString("kSearchResultsNoData", comment: "")
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.view.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.loadingAnimation.isHidden = false
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
     
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)

    }
    
    //MARK: - Buttons
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Data
    func reloadData() {
        _AppDataHandler.searchOldMobility(page: currentPage,
                                  limit: 10,
                                  keyword: searchKeyword,
                                  focusAreaIDs: searchFocusAreas)
        { (isSuccess, error, paging, listVideos) in
            
            self.loadingAnimation.isHidden = true
            
            if isSuccess {
                self.isLoadingList = false
                if self.paging?.currentPage != self.currentPage && self.paging?.currentPage != nil {
                    var list = self.videoResults
                    list.append(contentsOf: listVideos)
                    self.videoResults = list
                } else {
                    self.videoResults = listVideos
                }
                
                self.paging = paging
                self.collectionView?.reloadData()
                
                self.nodataLabel.isHidden = !(listVideos.count == 0)
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
            }
        }
    }
    
    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoResults.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! CC_SquareVideoCell
        
        let cellData = self.videoResults[indexPath.row]
        
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
        let cellData = self.videoResults[indexPath.row]
        
        let videoPlayerVC = VC_SubPageVideoPlayer()
        videoPlayerVC.setVideoDataSource(newVideoDataSource: cellData)
        _NavController.pushViewController(videoPlayerVC, animated: true)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingList){
            if paging!.maxPage > currentPage {
                isLoadingList = true
                currentPage += 1
                self.loadingAnimation.isHidden = false
                self.reloadData()
            }
        }
    }
}
