//
//  VC_MainPageMaintenances.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/12/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageAllMaintenances: UIViewController,
                                    UICollectionViewDataSource, UICollectionViewDelegate,
                                    UICollectionViewDelegateFlowLayout {
    
    var pageTitleText       = NSLocalizedString("kMaintenancesTitle", comment: "")
    var collectionView      : UICollectionView?
    var nodataLabel         = UILabel()
    let retryBtn            = UIButton()
    let loadingAnimation    = VW_LoadingAnimation()
    
    private var searchFocusAreas    : [String] = []
    private var searchFocusEquipment: [String] = []
    private var listEquipment: [SystemEquipmentDataSource] = _AppDataHandler.getUserProfile().userSettings.myEquipments
    private var minTime             = kZeroMinsFilter
    private var maxTime             = kAllMinsFilter
    
    private var listVideos          : [VideoDataSource] = []
    private var paging              : PagingDataSource?
    var currentPage                 : Int = 1
    var isLoadingList               : Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let pageTitle  = UILabel()
        pageTitle.text = pageTitleText
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
        nodataLabel.text = "No videos found!\nPlease try again later."
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.view.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        retryBtn.setTitle(NSLocalizedString("kRetryBtnDaily", comment: "").uppercased(), for: .normal)
        retryBtn.setTitleColor(.white, for: .normal)
        retryBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        retryBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        retryBtn.layer.cornerRadius = 20
        retryBtn.addTarget(self, action: #selector(retryButtonTapped), for: .touchUpInside)
        retryBtn.isHidden = true
        self.view.addSubview(retryBtn)
        retryBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        self.loadingAnimation.isHidden = false
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Data
    
    func setFilterData(listFocus: [String],
                       minValue: Int,
                       maxValue: Int) {
        for item in listEquipment {
            searchFocusEquipment.append(String(item.equipmentId))
        }
        
        self.searchFocusAreas = listFocus
        self.minTime = minValue
        self.maxTime = maxValue
        
        self.reloadData()
    }
    
    private func reloadData() {
        self.loadingAnimation.isHidden = false
        _AppDataHandler.dailySearch(listFocus:self.searchFocusAreas,
                                    listEquipment: self.searchFocusEquipment,
                                    minValue: self.minTime,
                                    maxValue: self.maxTime,
                                    limit: 20, page: currentPage) { (isSuccess, error, paging, listMaintenances) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.isLoadingList = false
                if self.paging?.currentPage != self.currentPage && self.paging?.currentPage != nil {
                    var list = self.listVideos
                    list.append(contentsOf: listMaintenances)
                    self.listVideos = list
                } else {
                    self.listVideos = listMaintenances
                }
                self.paging = paging
                
                self.collectionView?.reloadData()
                
                self.nodataLabel.isHidden = !(listMaintenances.count == 0)
                self.retryBtn.isHidden = !(listMaintenances.count == 0)
                
            } else {
                self.nodataLabel.isHidden = false
                self.retryBtn.isHidden = false
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    //MARK: - Buttons
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func retryButtonTapped() {
        self.reloadData()
    }
    
    //MARK: - UICollectionViewDataSource
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return listVideos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "videoCell", for: indexPath) as! CC_SquareVideoCell
        
        let cellData = self.listVideos[indexPath.row]
        
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
        let cellData = self.listVideos[indexPath.row]
        
        let videoPlayerVC = VC_SubPageVideoPlayer()
        videoPlayerVC.setVideoDataSource(newVideoDataSource: cellData)
        _NavController.pushViewController(videoPlayerVC, animated: true)
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
