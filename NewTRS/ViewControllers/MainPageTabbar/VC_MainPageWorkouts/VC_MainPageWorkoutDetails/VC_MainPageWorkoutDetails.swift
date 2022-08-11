//
//  VC_MainPageWorkoutDetails.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/22/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageWorkoutDetails: UIViewController,
                                UITableViewDataSource, UITableViewDelegate,
                                VideoCellDelegate {

    private let movementIconBtn    = UIButton()
    private var pageTableView      = UITableView()

    let listSectionTitle: [String] = [NSLocalizedString("kSuggestion", comment: ""),
                                      NSLocalizedString("kPostVideosTitle", comment: ""),
                                      NSLocalizedString("kRelatedVideos", comment: "")]
    let loadingAnimation        = VW_LoadingAnimation()
    let viewEmpty               = UIView()

    //MARK: Data
    private var dataSource      : CategoryDataSource?
    var listPreVideos           : [VideoDataSource] = []
    var listPostVideos          : [VideoDataSource] = []
    var listRelatedVideos       : [VideoDataSource] = []
    var currentPageRelated      : Int = 1
    var isLoadingRelated        : Bool = false

    var movementGuideVideo      : VideoDataSource?
    var loadingAnimationCount   = 0
    private var pagingRelated   : PagingDataSource?

    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "ffffff")

        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "333333")!,
             NSAttributedString.Key.font: setFontSize(size: 17, weight: .bold)]
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backBtn
        
        //Button Movement Guide
        movementIconBtn.setBackgroundImage(UIImage.init(named: "movermentIcon"), for: .normal)
        movementIconBtn.addTarget(self, action: #selector(movementTapped), for: .touchUpInside)
        self.view.addSubview(movementIconBtn)
        movementIconBtn.snp.makeConstraints { (make) in
            make.width.equalTo(26)
            make.height.equalTo(0)
            make.right.equalToSuperview().offset(-20)
            make.top.equalToSuperview().offset(12)
        }
            
        pageTableView = UITableView(frame: .zero, style: .plain)
        pageTableView.separatorStyle = .none
        pageTableView.register(TC_PreWorkoutCell.self, forCellReuseIdentifier: "preVideoCell")
        pageTableView.register(TC_PostWorkoutCell.self, forCellReuseIdentifier: "postVideoCell")
        pageTableView.register(TC_VideoPracticeCell.self, forCellReuseIdentifier: "relatedVideoCell")
        pageTableView.dataSource = self
        pageTableView.delegate = self
        self.view.addSubview(pageTableView)
        pageTableView.snp.makeConstraints({ (make) in
            make.top.equalTo(movementIconBtn.snp.bottom)
            make.left.bottom.right.equalToSuperview()
        })

        viewEmpty.backgroundColor = UIColor.init(hexString: "fafafa")
        viewEmpty.isHidden = true
        self.view.addSubview(viewEmpty)
        viewEmpty.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }

        let titleResult = UILabel()
        titleResult.font = setFontSize(size: 18, weight: .bold)
        titleResult.textColor = UIColor.init(hexString: "333333")
        titleResult.text = NSLocalizedString("kNoResult", comment: "")
        viewEmpty.addSubview(titleResult)
        titleResult.snp.makeConstraints{(make) in
            make.center.equalToSuperview()
        }

        let imageView = UIImageView()
        imageView.image = UIImage(named: "default_empty")
        viewEmpty.addSubview(imageView)
        imageView.snp.makeConstraints{(make) in
            make.width.height.equalTo(85)
            make.centerX.equalToSuperview()
            make.bottom.equalTo(titleResult.snp.top).offset(-25)
        }

        let detailResult = UILabel()
        detailResult.font = setFontSize(size: 14, weight: .regular)
        detailResult.textColor = UIColor.init(hexString: "666666")
        detailResult.text = NSLocalizedString("kNoMatchingProductsFound", comment: "")
        viewEmpty.addSubview(detailResult)
        detailResult.snp.makeConstraints{(make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(titleResult.snp.bottom).offset(5)
        }
        
        self.loadingAnimation.isHidden = true
        self.loadingAnimation.opacityView.backgroundColor = .white
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        self.reloadData()
    }
    
    //MARK: - UI Actions
    @objc private func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func movementTapped() {
        if movementGuideVideo != nil {
            self.reloadMovementGuide(videoData: movementGuideVideo!)
        }
    }
    
    //MARK: - Reload Data
    
    func setDataSource(newData: CategoryDataSource) {
        self.dataSource = newData
        self.title = newData.categoryTitle
    }
    
    private func reloadData() {
        
        self.loadingAnimation.isHidden = false
        self.loadingAnimationCount = 0
        
        guard let dataSource = self.dataSource else {
            self.loadingAnimation.isHidden = true
            _NavController.presentAlertForCase(title: "Request Fail", message: "Empty Category Data source")
            return
        }
        
        _AppDataHandler.getVideoImovementGuide(categoryID: dataSource.categoryID)
        { (isSuccess, error, movementVideo) in
            
            self.updateLoadingAnimation()
            if isSuccess {
                if movementVideo != nil {
                    self.movementGuideVideo = movementVideo!
                    self.reloadUIMovementGuide()
                }
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
        
        _AppDataHandler.getListSuggestionVideoByCategory(categoryID: dataSource.categoryID,
                                                         listEquipments: [],
                                                         listFocusArea: [],
                                                         minDuration: kZeroMinsFilter,
                                                         maxDuration: kAllMinsFilter,
                                                         prePostFilter: 1,
                                                         collectionSlug: dataSource.collectionSlug)
        { (isSuccess, error, listVideo) in
            
            if isSuccess {
                self.listPreVideos = listVideo
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
            self.updateLoadingAnimation()
        }
        
        _AppDataHandler.getListSuggestionVideoByCategory(categoryID: dataSource.categoryID,
                                                         listEquipments: [],
                                                         listFocusArea: [],
                                                         minDuration: kZeroMinsFilter,
                                                         maxDuration: kAllMinsFilter,
                                                         prePostFilter: 2,
                                                         collectionSlug: dataSource.collectionSlug)
        { (isSuccess, error, listVideo) in
            
            if isSuccess {
                self.listPostVideos = listVideo
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
            self.updateLoadingAnimation()
        }
        
        _AppDataHandler.getListRelatedVideoByCategory(categoryID: dataSource.categoryID,
                                                      listEquipments: [],
                                                      listFocusArea: [],
                                                      minDuration: kZeroMinsFilter,
                                                      maxDuration: kAllMinsFilter,
                                                      prePostFilter: 0,
                                                      collectionSlug: dataSource.collectionSlug,
                                                      limit: 10, page: currentPageRelated)
        { (isSuccess, error, paging, listVideo) in
            
            if isSuccess {
                self.isLoadingRelated = false
                if self.pagingRelated?.currentPage != self.currentPageRelated && self.pagingRelated?.currentPage != nil {
                    var list = self.listRelatedVideos
                    list.append(contentsOf: listVideo)
                    self.listRelatedVideos = list
                } else {
                    if self.currentPageRelated == 1 {
                        self.listRelatedVideos = listVideo
                    }
                }
                self.pagingRelated = paging
                self.pageTableView.reloadData()
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }

            self.updateLoadingAnimation()
            if self.listPreVideos.isEmpty && self.listPostVideos.isEmpty && self.listRelatedVideos.isEmpty {
                self.viewEmpty.isHidden = false
            }
        }
    }

    private func updateLoadingAnimation() {
            self.loadingAnimationCount += 1
            if loadingAnimationCount == 4 {
                self.loadingAnimation.isHidden = true
                self.loadingAnimationCount = 0
               
                let listPre = Array(listPreVideos.prefix(1))
                let listPost = Array(listPostVideos.prefix(3))
                let listRelated = listRelatedVideos.filter {
                    element in
                    return !listPre.contains(element)
                }
                listRelatedVideos = listRelated.filter {
                    element in
                    return !listPost.contains(element)
                }
                self.pageTableView.reloadData()
            }
        }

    private func reloadMovementGuide(videoData: VideoDataSource) {
        let videoVC = VC_SubPageVideoPlayer()
        videoVC.setVideoDataSource(newVideoDataSource: videoData)
        _NavController.pushViewController(videoVC, animated: true)
    }
    
    private func reloadUIMovementGuide() {
        
        if self.movementGuideVideo?.videoID != 0 {
            movementIconBtn.snp.remakeConstraints({ (remake) in
                remake.width.equalTo(26)
                remake.height.equalTo(20)
                remake.right.equalToSuperview().offset(-20)
                remake.top.equalToSuperview().offset(12)
            })
            
            let movementBtn = UIButton()
            movementBtn.setTitle(NSLocalizedString("kMovemomentGuideBtn", comment: ""), for: .normal)
            movementBtn.setTitleColor(UIColor.init(hexString: "888888"), for: .normal)
            movementBtn.titleLabel?.font = setFontSize(size: 14, weight: .regular)
            movementBtn.layer.cornerRadius = 15
            movementBtn.addTarget(self, action: #selector(movementTapped), for: .touchUpInside)
            self.view.addSubview(movementBtn)
            movementBtn.snp.makeConstraints { (make) in
                make.height.equalTo(15)
                make.right.equalTo(movementIconBtn.snp.left).offset(-10)
                make.centerY.equalTo(movementIconBtn)
            }
            self.view.setNeedsLayout()
        }
    }

    //MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {

        let headerView = UIView()
        headerView.backgroundColor = .white
        let sectionTitle = UILabel()
        sectionTitle.text = listSectionTitle[section]
        sectionTitle.textColor = UIColor.init(hexString: "333333")
        sectionTitle.font = setFontSize(size: 18, weight: .bold)

        headerView.addSubview(sectionTitle)
        sectionTitle.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-5)
            make.top.equalToSuperview().offset(30)
            make.right.equalToSuperview().offset(-20)
        }

        return headerView
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            if !self.listPreVideos.isEmpty {
                return 53
            } else { return 0 }
        case 1:
            if !self.listPostVideos.isEmpty {
                return 53
            } else { return 0 }
        case 2:
            if !self.listRelatedVideos.isEmpty {
                return 53
            } else { return 0 }
        default:
            return 0
        }
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.listPreVideos.isEmpty { return 0 } else { return 1 }
        case 2:
            return self.listRelatedVideos.count
        default:
            return 1
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = pageTableView.dequeueReusableCell(withIdentifier: "preVideoCell") as! TC_PreWorkoutCell
            cell.delegate = self
            if !listPreVideos.isEmpty {
                cell.setData(videoData: listPreVideos[0])
            }
            cell.contentView.isUserInteractionEnabled = false
            return cell
        case 1:
            let cell = pageTableView.dequeueReusableCell(withIdentifier: "postVideoCell") as! TC_PostWorkoutCell
            cell.delegate = self
            cell.reloadListPostData(listVideoData: listPostVideos)
            cell.contentView.isUserInteractionEnabled = false
            return cell
        case 2:
            let cell = pageTableView.dequeueReusableCell(withIdentifier: "relatedVideoCell", for: indexPath) as! TC_VideoPracticeCell
            cell.showPrePostLabel(isHidden: false)
            if !listRelatedVideos.isEmpty {
                cell.setDataSource(videoData: listRelatedVideos[indexPath.row])
                if _AppDataHandler.getUserProfile().isFreemiumUser() {
                    cell.showOpacityView()
                }
            }
            return cell
        default:
            return UITableViewCell()
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            if !self.listPreVideos.isEmpty {
                return UIScreen.main.bounds.size.width * 0.56
            } else { return 0 }
        case 1:
            if !self.listPostVideos.isEmpty {
                return 140
            } else { return 0 }
        case 2:
            if !self.listRelatedVideos.isEmpty {
                return 101
            } else { return 0 }
        default:
            return 0
        }
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let videoVC = VC_SubPageVideoPlayer()
        let videoData: VideoDataSource?
        switch indexPath.section {
        case 2:
            videoData = listRelatedVideos[indexPath.row]
            tableView.deselectRow(at: indexPath, animated: true)
            break
        default:
            tableView.deselectRow(at: indexPath, animated: true)
            return
        }
        videoVC.setVideoDataSource(newVideoDataSource: videoData!)
        _NavController.pushViewController(videoVC, animated: true)
    }

    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView == self.pageTableView {
            if (((scrollView.contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height ) && !isLoadingRelated){
                if pagingRelated!.maxPage > currentPageRelated {
                    isLoadingRelated = true
                    currentPageRelated += 1
                    self.reloadData()
                }
            }
        }
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        // Video Pre
        if videoData.videoID == self.listPreVideos.first?.videoID {
            NotificationCenter.default.post(name: kWatchPreVideoNotification, object: nil)
        }
        
        // Video Post
        let videoVC = VC_SubPageVideoPlayer()
        videoVC.setVideoDataSource(newVideoDataSource: videoData)
        _NavController.pushViewController(videoVC, animated: true)
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        //
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //
    }
}
