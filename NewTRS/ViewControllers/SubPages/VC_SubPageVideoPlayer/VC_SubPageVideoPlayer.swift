//
//  VC_SubPageVideoPlayer.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/18/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import Alamofire
import GoogleCast

enum LayoutViewStatus {
    case fullView
    case noEquipmentOnly
    case noCoachTipOnly
    case noAreasOnly
    case noEquipmentAndCoach
    case noEquipmentAndAreas
    case noAreasAndCoach
    case noEquipentAndCoachAndAreas
    case collapsed
}

class VC_SubPageVideoPlayer: UIViewController,
                            VideoCellDelegate, VW_VideoPlayerDelegate {
    
    let videoPlayer             : VW_VideoPlayer = {
        var frame = UIScreen.main.bounds
        frame.size.height = frame.size.width*0.5625 + 54
        
        return VW_VideoPlayer.init(frame: frame)
    }()
    let pageScroll              = UIScrollView()
        
    let videoTitleLabel         = UILabel()
    let videoDescriptionLabel   = UILabel()
    let collapseBtn             = UIButton()
    
    let requiredEquipmentLabel  = UILabel()
    let equipmentScrollView     = UIScrollView()
    let noEquipmentTitle        = UILabel()
        
    let areasLabel               = UILabel()
    let areasScrollView          = UIScrollView()
    
    let coachTipLabel           = UILabel()
    let coachTipContentView     = UIView()
    
    let referenceVideosLabel        = UILabel()
    let referenceVideoScrollView    = UIScrollView()
    
    let upsellScrollView            = UIScrollView()
    
    let loadingAnimation        = VW_LoadingAnimation()
    var loadingAnimationCount   = 0
    
    //Data
    //private var listReferenceVideo  : [VideoDataSource] = []
    //private var listReferenceUpSell : [UpSellDataSource] = []
    private var listRequest         : [Request] = []
        
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
        
        pageScroll.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.equalTo(ctaLine)
            make.left.right.bottom.width.equalToSuperview()
        }
        
        //MARK:  Video Info
        
        collapseBtn.setImage(UIImage.init(named: "collapse_btn"), for: .normal)
        collapseBtn.setImage(UIImage.init(named: "expand_btn"), for: .selected)
        collapseBtn.layer.shadowColor = UIColor.init(hexString: "192d00ff")!.cgColor
        collapseBtn.layer.shadowOffset = CGSize(width:0, height: 3)
        collapseBtn.layer.shadowOpacity = 0.5
        collapseBtn.layer.shadowRadius = 0.0
        collapseBtn.layer.masksToBounds = false
        collapseBtn.addTarget(self, action: #selector(collapseButtonTapped), for: .touchUpInside)
        self.pageScroll.addSubview(collapseBtn)
        collapseBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.height.width.equalTo(30)
            make.right.equalTo(videoPlayer).offset(-20)
        }
        
        videoTitleLabel.text = videoPlayer.getVideoData()?.videoTitle ?? ""
        videoTitleLabel.font = setFontSize(size: 18, weight: .bold)
        videoTitleLabel.textColor = UIColor.init(hexString: "333333")
        videoTitleLabel.numberOfLines = 0
        self.pageScroll.addSubview(videoTitleLabel)
        videoTitleLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(collapseBtn)
            make.left.equalToSuperview().offset(20)
            make.right.equalTo(collapseBtn.snp.left).offset(-5)
        }
        
        videoDescriptionLabel.text = self.videoPlayer.getVideoData()?.videoDescription
        videoDescriptionLabel.font =  setFontSize(size: 14, weight: .regular)
        videoDescriptionLabel.textColor = UIColor.init(hexString: "888888")
        videoDescriptionLabel.numberOfLines = 0
        self.pageScroll.addSubview(videoDescriptionLabel)
        videoDescriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(collapseBtn.snp.bottom).offset(15)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        requiredEquipmentLabel.text = NSLocalizedString("kRequiredEquipment", comment: "")
        requiredEquipmentLabel.font = setFontSize(size: 14, weight: .semibold)
        requiredEquipmentLabel.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(requiredEquipmentLabel)
        requiredEquipmentLabel.snp.makeConstraints { (make) in
            make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        noEquipmentTitle.text = NSLocalizedString("kNoEquipmentMessage", comment: "")
        noEquipmentTitle.textAlignment = .center
        noEquipmentTitle.font = setFontSize(size: 14, weight: .regular)
        noEquipmentTitle.textColor = UIColor.init(hexString: "888888")
        self.pageScroll.addSubview(noEquipmentTitle)
        noEquipmentTitle.snp.makeConstraints { (make) in
            make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(34)
        }
        
        equipmentScrollView.showsHorizontalScrollIndicator = false
        equipmentScrollView.backgroundColor = UIColor.init(hexString: "fafafa")
        self.pageScroll.addSubview(equipmentScrollView)
        equipmentScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(34)
        }
        
        self.reloadEquipmentView()
        
        //MARK: Areas
        areasLabel.text = NSLocalizedString("kUserAreaTitle", comment: "")
        areasLabel.font = setFontSize(size: 14, weight: .semibold)
        areasLabel.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(areasLabel)
        areasLabel.snp.makeConstraints { (make) in
            make.top.equalTo(equipmentScrollView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        areasScrollView.showsHorizontalScrollIndicator = false
        areasScrollView.backgroundColor = UIColor.init(hexString: "fafafa")
        self.pageScroll.addSubview(areasScrollView)
        areasScrollView.snp.makeConstraints { (make) in
            make.top.equalTo(areasLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(34)
        }
        
        self.reloadAreasView()
        
        coachTipLabel.text = NSLocalizedString("kCoachTips", comment: "")
        coachTipLabel.font = setFontSize(size: 14, weight: .semibold)
        coachTipLabel.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(coachTipLabel)
        coachTipLabel.snp.makeConstraints { (make) in
            make.top.equalTo(areasScrollView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.pageScroll.addSubview(coachTipContentView)
        coachTipContentView.snp.makeConstraints { (make) in
            make.top.equalTo(coachTipLabel.snp.bottom).offset(10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-70)
        }
        
        self.loadCoachTipView()
        
        //MARK: May As You Like
        referenceVideosLabel.text = NSLocalizedString("kMayAsYouLike", comment: "")
        referenceVideosLabel.font = setFontSize(size: 18, weight: .bold)
        referenceVideosLabel.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(referenceVideosLabel)
        referenceVideosLabel.snp.makeConstraints { (make) in
            make.top.equalTo(coachTipContentView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        let noReferenceTitle  = UILabel()
        noReferenceTitle.text = "No reference videos"
        noReferenceTitle.textAlignment = .center
        noReferenceTitle.font = setFontSize(size: 14, weight: .regular)
        noReferenceTitle.textColor = UIColor.init(hexString: "888888")
        self.pageScroll.addSubview(noReferenceTitle)
        noReferenceTitle.snp.makeConstraints { (make) in
            make.centerX.width.equalToSuperview()
            make.top.equalTo(referenceVideosLabel.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        
        self.referenceVideoScrollView.backgroundColor = UIColor.init(hexString: "fafafa")
        referenceVideoScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(referenceVideoScrollView)
        referenceVideoScrollView.snp.makeConstraints { (make) in
            make.centerX.width.equalToSuperview()
            make.top.equalTo(referenceVideosLabel.snp.bottom).offset(10)
            make.height.equalTo(140)
        }
        
        self.reloadReferenceVideos(listVideo: [])
        
        //MARK: Upsell
        let upsellTitle = UILabel()
        upsellTitle.text = NSLocalizedString("kUpsellTitle", comment: "")
        upsellTitle.font = setFontSize(size: 18, weight: .bold)
        upsellTitle.textColor = UIColor.init(hexString: "333333")
        self.pageScroll.addSubview(upsellTitle)
        upsellTitle.snp.makeConstraints { (make) in
            make.top.equalTo(referenceVideoScrollView.snp.bottom).offset(30)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(18)
        }
        
        upsellScrollView.showsHorizontalScrollIndicator = false
        self.pageScroll.addSubview(upsellScrollView)
        upsellScrollView.snp.makeConstraints { (make) in
            make.centerX.width.equalToSuperview()
            make.top.equalTo(upsellTitle.snp.bottom).offset(10)
            make.height.equalTo(155)
            make.bottom.equalToSuperview()
        }
        
        self.reloadListUpsell(listUpsell: [])
        
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: false)
        
        videoPlayer.play()
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)), name: UIDevice.orientationDidChangeNotification, object: nil)

    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.videoPlayer.pause()
        NotificationCenter.default.removeObserver(self, name: UIDevice.orientationDidChangeNotification, object: nil)
    }
    
    // MARK: - Layouts
    func reloadEquipmentView() {
        
        // Remove all old cell
        for subView in equipmentScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        self.equipmentScrollView.isHidden = true
        if self.videoPlayer.getVideoData()?.requiredEquipmentIDs.count == 0 {
            
            self.equipmentScrollView.isHidden = true
            return
        }
        
        guard let videoData = self.videoPlayer.getVideoData() else {
            self.equipmentScrollView.isHidden = true
            return
        }
                
        let listSourceEquipments = _AppCoreData.listSystemEquipments
        var listRequiredEquipments : [SystemEquipmentDataSource] = []
        
        for systemEquiment in listSourceEquipments {
            
            for id in videoData.requiredEquipmentIDs {
                if id == systemEquiment.equipmentId {
                    listRequiredEquipments.append(systemEquiment)
                }
            }
        }
        
        if listRequiredEquipments.count > 0 {
            self.equipmentScrollView.isHidden = false
        }
        
        var markedView : UIView?
        
        for equipment in listRequiredEquipments {
            let contentView = UIView()
            contentView.backgroundColor = UIColor.init(hexString: "718cfe")
            contentView.layer.cornerRadius = 17
            self.equipmentScrollView.addSubview(contentView)
            
            if markedView != nil {
                contentView.snp.makeConstraints { (make) in
                    make.left.equalTo(markedView!.snp.right).offset(10)
                    make.top.bottom.equalToSuperview()
                    make.height.equalTo(34)
                }
            } else {
                contentView.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.height.equalTo(34)
                }
            }
            
            let equipmentNameLabel = UILabel()
            equipmentNameLabel.text = equipment.equipmentTitle
            equipmentNameLabel.font = setFontSize(size: 14, weight: .semibold) 
            equipmentNameLabel.textColor = .white
            contentView.addSubview(equipmentNameLabel)
            equipmentNameLabel.snp.makeConstraints { (make) in
                make.center.height.equalToSuperview()
                make.width.equalToSuperview().offset(-24)
            }
            
            markedView = contentView
        }
        
        markedView?.snp.makeConstraints({ (make) in
            make.right.equalToSuperview()
        })
    }
    
    func reloadAreasView() {
        
        // Remove all old cell
        for subView in areasScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        self.areasScrollView.isHidden = true
        if self.videoPlayer.getVideoData()?.areasIDs.count == 0 {
            
            self.areasScrollView.isHidden = true
            return
        }
        
        guard let videoData = self.videoPlayer.getVideoData() else {
            self.areasScrollView.isHidden = true
            return
        }
                
        let listSourceAreas = _AppCoreData.listSystemFocusAreas
        var listFocusAreas : [SystemFocusAreaDataSource] = []
        
        for systemForcusAreas in listSourceAreas {
            
            for id in videoData.areasIDs {
                if id == systemForcusAreas.areaId {
                    listFocusAreas.append(systemForcusAreas)
                }
            }
        }
        
        if listFocusAreas.count > 0 {
            self.areasScrollView.isHidden = false
        }
        
        var markedView : UIView?
        
        for equipment in listFocusAreas {
            let contentView = UIView()
            contentView.backgroundColor = UIColor.init(hexString: "718cfe")
            contentView.layer.cornerRadius = 17
            self.areasScrollView.addSubview(contentView)
            
            if markedView != nil {
                contentView.snp.makeConstraints { (make) in
                    make.left.equalTo(markedView!.snp.right).offset(10)
                    make.top.bottom.equalToSuperview()
                    make.height.equalTo(34)
                }
            } else {
                contentView.snp.makeConstraints { (make) in
                    make.left.equalToSuperview()
                    make.top.bottom.equalToSuperview()
                    make.height.equalTo(34)
                }
            }
            
            let equipmentNameLabel = UILabel()
            equipmentNameLabel.text = equipment.areaTitle
            equipmentNameLabel.font = setFontSize(size: 14, weight: .semibold)
            equipmentNameLabel.textColor = .white
            contentView.addSubview(equipmentNameLabel)
            equipmentNameLabel.snp.makeConstraints { (make) in
                make.center.height.equalToSuperview()
                make.width.equalToSuperview().offset(-24)
            }
            
            markedView = contentView
        }
        
        markedView?.snp.makeConstraints({ (make) in
            make.right.equalToSuperview()
        })
    }
    
    func loadCoachTipView() {
        
        let listCoachTip = self.videoPlayer.getVideoData()?.coachTips ?? []
        
        var markedView : UIView?
        
        for view in coachTipContentView.subviews {
            view.removeFromSuperview()
        }
        
        for tip in listCoachTip {
            let dotView = UIView()
            dotView.backgroundColor = UIColor.init(hexString: "666666")
            dotView.layer.cornerRadius = 4
            coachTipContentView.addSubview(dotView)
            
            if markedView != nil {
                dotView.snp.makeConstraints { (make) in
                    make.top.equalTo(markedView!.snp.bottom).offset(13)
                    make.left.equalToSuperview()
                    make.height.width.equalTo(8)
                }
            } else {
                dotView.snp.makeConstraints { (make) in
                    make.top.left.equalToSuperview()
                    make.height.width.equalTo(8)
                }
            }
            
            let equipmentNameLabel = UILabel()
            equipmentNameLabel.text = tip
            equipmentNameLabel.font = setFontSize(size: 14, weight: .regular)
            equipmentNameLabel.textColor = UIColor.init(hexString: "888888")
            equipmentNameLabel.numberOfLines = 0
            coachTipContentView.addSubview(equipmentNameLabel)
            equipmentNameLabel.snp.makeConstraints { (make) in
                make.top.equalTo(dotView).offset(-3)
                make.left.equalTo(dotView.snp.right).offset(10)
                make.right.equalToSuperview()
            }
            
            markedView = equipmentNameLabel
        }
        
        markedView?.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview()
        })
    }
    
    func reloadReferenceVideos (listVideo: [VideoDataSource]) {
        // Remove all old cell
        for subView in referenceVideoScrollView.subviews {
            subView.removeFromSuperview()
        }
        
        
        self.referenceVideoScrollView.isHidden = false
        if listVideo.count == 0 {
            self.referenceVideoScrollView.isHidden = true
            return
        }
        
        // Reload scrollView
        let size = CGSize(width: 250, height: 140)
        var index = 0
        
        for videoData in listVideo {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_RetangleVideoViewCellViewCount.init(frame: frame)
            cell.showDownloadOption(isHidden: true)
            cell.showPrePostLabel(isHidden: true)
            cell.reloadLayout()
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                cell.showOpacityView()
            }
            referenceVideoScrollView.addSubview(cell)
            
            cell.delegate = self
            cell.setVideoDataSource(videoData: videoData)
            
            index += 1
        }
                        
        referenceVideoScrollView.contentSize = CGSize.init(width: CGFloat(listVideo.count)*(size.width + 10) + 30, height: size.height)
    }
    
    func reloadListUpsell(listUpsell: [UpSellDataSource]) {
        // Remove all old cell
        for subView in upsellScrollView.subviews {
            subView.removeFromSuperview()
        }
                
        // Reload scrollView
        let size = CGSize(width: 140, height: 155)
        var index = 0
        
        for upselData in listUpsell {
            
            let frame = CGRect.init(x: 20 + CGFloat(index)*(size.width + 10), y: 0, width: size.width, height: size.height)
            
            let cell = VW_UpsellCell.init(frame: frame)
            upsellScrollView.addSubview(cell)
            
            cell.setDataSource(upsellData: upselData)
            
            index += 1
        }
                        
        upsellScrollView.contentSize = CGSize.init(width: CGFloat(listUpsell.count)*(size.width + 10) + 30, height: size.height)
    }
    
    private func reloadContentView() {
        collapseBtn.isHidden = false
        switch self.getLayoutStatus() {
        case .fullView:
            requiredEquipmentLabel.isHidden = false
            equipmentScrollView.isHidden = false
            noEquipmentTitle.isHidden = false
            
            coachTipLabel.isHidden = false
            coachTipContentView.isHidden = false
            
            areasLabel.isHidden = false
            areasScrollView.isHidden = false
            
            requiredEquipmentLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            noEquipmentTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            equipmentScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadEquipmentView()
            
            areasLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(equipmentScrollView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }

            areasScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(areasLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadAreasView()
            
            coachTipLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(areasScrollView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            coachTipContentView.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-70)
            }
            
            self.loadCoachTipView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipContentView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            break
        case .noCoachTipOnly:
            requiredEquipmentLabel.isHidden = false
            equipmentScrollView.isHidden = false
            noEquipmentTitle.isHidden = false
            
            areasLabel.isHidden = false
            areasScrollView.isHidden = false
            
            coachTipLabel.isHidden = true
            coachTipContentView.isHidden = true
            
            requiredEquipmentLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            noEquipmentTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            equipmentScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadEquipmentView()
            
            areasLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(equipmentScrollView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }

            areasScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(areasLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadAreasView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(areasScrollView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            break
        case .noEquipmentOnly:
            requiredEquipmentLabel.isHidden = true
            equipmentScrollView.isHidden = true
            noEquipmentTitle.isHidden = true
            
            areasLabel.isHidden = false
            areasScrollView.isHidden = false
            
            coachTipLabel.isHidden = false
            coachTipContentView.isHidden = false
            
            areasLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }

            areasScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(areasLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadAreasView()
            
            coachTipLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(areasScrollView.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            coachTipContentView.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-70)
            }
            
            self.loadCoachTipView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipContentView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            break
        case .noEquipmentAndCoach:
            requiredEquipmentLabel.isHidden = true
            equipmentScrollView.isHidden = true
            noEquipmentTitle.isHidden = true
            
            coachTipLabel.isHidden = true
            coachTipContentView.isHidden = true
            
            areasLabel.isHidden = false
            areasScrollView.isHidden = false
            
            areasLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }

            areasScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadAreasView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(areasScrollView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            break
        case .noAreasOnly:
            requiredEquipmentLabel.isHidden = false
            equipmentScrollView.isHidden = false
            noEquipmentTitle.isHidden = false
            
            areasLabel.isHidden = true
            areasScrollView.isHidden = true
            
            coachTipLabel.isHidden = false
            coachTipContentView.isHidden = false
            
            requiredEquipmentLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            noEquipmentTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            equipmentScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadEquipmentView()
            
            coachTipLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            coachTipContentView.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-70)
            }
            
            self.loadCoachTipView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipContentView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            break
        case .noEquipmentAndAreas:
            requiredEquipmentLabel.isHidden = true
            equipmentScrollView.isHidden = true
            noEquipmentTitle.isHidden = true
            
            areasLabel.isHidden = true
            areasScrollView.isHidden = true
            
            coachTipLabel.isHidden = false
            coachTipContentView.isHidden = false
            
            coachTipLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            coachTipContentView.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-70)
            }
            
            self.loadCoachTipView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(coachTipContentView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            break
        case .noAreasAndCoach:
            requiredEquipmentLabel.isHidden = false
            equipmentScrollView.isHidden = false
            noEquipmentTitle.isHidden = false
            
            coachTipLabel.isHidden = true
            coachTipContentView.isHidden = true
            
            areasLabel.isHidden = true
            areasScrollView.isHidden = true
            
            requiredEquipmentLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            noEquipmentTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            equipmentScrollView.snp.remakeConstraints { (make) in
                make.top.equalTo(requiredEquipmentLabel.snp.bottom).offset(10)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
                make.height.equalTo(34)
            }
            
            self.reloadEquipmentView()
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(equipmentScrollView.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            break
        case .noEquipentAndCoachAndAreas:
            collapseBtn.isHidden = true
            
            requiredEquipmentLabel.isHidden = true
            equipmentScrollView.isHidden = true
            noEquipmentTitle.isHidden = true
            
            areasLabel.isHidden = true
            areasScrollView.isHidden = true
            
            coachTipLabel.isHidden = true
            coachTipContentView.isHidden = true
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            break
        default:
            
            requiredEquipmentLabel.isHidden = true
            equipmentScrollView.isHidden = true
            noEquipmentTitle.isHidden = true
            
            areasLabel.isHidden = true
            areasScrollView.isHidden = true
            
            coachTipLabel.isHidden = true
            coachTipContentView.isHidden = true
            
            referenceVideosLabel.snp.remakeConstraints { (make) in
                make.top.equalTo(videoDescriptionLabel.snp.bottom).offset(30)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-40)
            }
            
            UIView.animate(withDuration: 0.5) {
                self.view.layoutIfNeeded()
            }
            break
        }
    }
    
    // MARK: - Buttons
    @objc func backButtonTapped() {
        self.videoPlayer.stop()
        for request in self.listRequest {
            request.cancel()
        }
        self.listRequest = []
        
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func collapseButtonTapped() {
        self.collapseBtn.isSelected = !self.collapseBtn.isSelected
        self.reloadContentView()
    }
    
    //MARK: - Data
    func setVideoDataSource(newVideoDataSource: VideoDataSource) {
                
        self.collapseBtn.isSelected = false
        self.videoPlayer.setVideoDataSource(newVideoData: newVideoDataSource)
        
        self.videoTitleLabel.text = newVideoDataSource.videoTitle
        self.videoDescriptionLabel.text = newVideoDataSource.videoDescription
    }
    
    private func progressLoadingAnimation() {
        self.loadingAnimationCount += 1
        if loadingAnimationCount == 2 {
            self.loadingAnimation.isHidden = true
        }
    }
    
    private func reloadData() {
        self.loadingAnimation.isHidden = false
        self.loadingAnimationCount = 0
        
        guard let videoDataSource = self.videoPlayer.getVideoData() else {
            self.loadingAnimation.isHidden = true
            return
        }
        
        //Get reference video
        let request1 = _AppDataHandler.getReferenceVideo(referenceVideoID: "\(videoDataSource.videoID)")
        { (isSuccess, error, listVideo) in
            self.progressLoadingAnimation()
            if isSuccess {
                //self.listReferenceVideo = listVideo
                // Lấy 3 objects đầu tiên của mảng api trả về để hiển thị mục "You May Also Like" ở các trang.
                let limitedListVideo = listVideo.prefix(3)
                self.reloadReferenceVideos(listVideo: Array(limitedListVideo))
                self.reloadContentView()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
        
        //Get Gear related
        let request2 = _AppDataHandler.getReferenceUpSell(referenceVideoID: "\(videoDataSource.videoID)", page: 1, limit: 10)
        { (isSuccess, error, paging, listUpsell) in
            self.progressLoadingAnimation()
            if isSuccess {
                //self.listReferenceUpSell = listUpsell
                self.reloadListUpsell(listUpsell: listUpsell)
                self.reloadContentView()
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
        
        if request1 != nil {
            self.listRequest.append(request1!)
        }
        
        if request2 != nil {
            self.listRequest.append(request2!)
        }
    }
    
    private func getLayoutStatus() -> LayoutViewStatus {
        
        guard let videoData = self.videoPlayer.getVideoData() else {
            return .fullView
        }
        
        if collapseBtn.isSelected {
            return .collapsed
        } else if (videoData.requiredEquipmentIDs.count == 0) &&
                    (videoData.coachTips.count == 0) && (videoData.areasIDs.count == 0) {
            return .noEquipentAndCoachAndAreas
        } else if (videoData.requiredEquipmentIDs.count == 0) &&
                    (videoData.coachTips.count == 0) {
            return .noEquipmentAndCoach
        } else if (videoData.requiredEquipmentIDs.count == 0) &&
                    (videoData.areasIDs.count == 0) {
            return .noEquipmentAndAreas
        } else if (videoData.areasIDs.count == 0) &&
                    (videoData.coachTips.count == 0) {
            return .noAreasAndCoach
        } else if (videoData.areasIDs.count == 0) {
            return .noAreasOnly
        } else if (videoData.requiredEquipmentIDs.count == 0) {
            return .noEquipmentOnly
        } else if (videoData.coachTips.count == 0) {
            return .noCoachTipOnly
        }
        
        return .fullView
    }
    
    //MARK: - VW_VideoPlayerDelegate
    
    func didUpdateNewDataSource() {
        self.reloadEquipmentView()
        self.loadCoachTipView()
    }
    
    //MARK: - VideoCellDelegate
    func didSelectVideo(videoData: VideoDataSource) {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        self.setVideoDataSource(newVideoDataSource: videoData)
        self.reloadData() //reload lại you may also
    }
    
    func didDeleteVideo(videoData: VideoDataSource) {
        //do nothing
    }
    
    func didSelectDownloadVideo(videoData: VideoDataSource) {
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        _AppVideoManager.requestDownloadVideo(videoData: videoData)
    }
    
    @objc private func handleNotification(noti: Notification) {
        if noti.name == UIDevice.orientationDidChangeNotification {
            self.videoPlayer.fullScreen()
        }
    }
}
