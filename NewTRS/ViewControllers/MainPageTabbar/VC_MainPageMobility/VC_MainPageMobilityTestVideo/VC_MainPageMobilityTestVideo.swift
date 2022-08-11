//
//  VC_MainPageMobilityTestVideo.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/23/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVKit
import GoogleCast

enum TagView: Int {
    case all = 0
    case truck = 1
    case shoulder = 2
    case hip = 3
    case ankle = 4
}

class VC_MainPageMobilityTestVideo: UIViewController,
                                    VW_VideoPlayerDelegate {

    let videoPlayer             : VW_VideoPlayer = {
        var frame = UIScreen.main.bounds
        frame.size.height = frame.size.width*0.5625 + 54
        
        return VW_VideoPlayer.init(frame: frame)
    }()
    let pageScroll              = UIScrollView()
    
    let videoTitle              = UILabel()
    let enterScoreBtn           = UIButton()
    
    let instructionView         = UIView()
    let compensationView        = UIView()
    
    //Data
    var dataSource              : MobilityTestVideo?
    var paging                  = 0
    var tagView                 :TagView = .all
    var totalPage               = 0 //_AppCoreData.getDataHip().count + _AppCoreData.getDataAnkle().count + _AppCoreData.getDataTruck().count + _AppCoreData.getDataShoulder().count
    var userResult          = UserMobilityDataSource.init(JSONString: "{}")!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        self.navigationController?.navigationBar.titleTextAttributes =
            [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "333333")!,
             NSAttributedString.Key.font: setFontSize(size: 17, weight: .bold)]
        
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
        
        videoTitle.text = "Example Video Title"
        videoTitle.numberOfLines = 0
        videoTitle.font = setFontSize(size: 18, weight: .bold)
        videoTitle.textColor = UIColor.init(hexString: "333333")
        videoTitle.textAlignment = .center
        self.view.addSubview(videoTitle)
        videoTitle.snp.makeConstraints { (make) in
            make.top.equalTo(ctaLine).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        enterScoreBtn.setTitle(NSLocalizedString("kEnterMyScoreBtn", comment: "").uppercased(), for: .normal)
        enterScoreBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        enterScoreBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        enterScoreBtn.layer.cornerRadius = 20
        enterScoreBtn.addTarget(self, action: #selector(enterScoreButtonTapped), for: .touchUpInside)
        self.view.addSubview(enterScoreBtn)
        enterScoreBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
        }

        
        pageScroll.showsVerticalScrollIndicator = false
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.equalTo(videoTitle.snp.bottom).offset(10)
            make.bottom.equalTo(enterScoreBtn.snp.top).offset(-10)
            make.left.equalToSuperview().offset(10)
            make.right.equalToSuperview().offset(-10)
        }
        
        instructionView.backgroundColor = .white
        instructionView.layer.cornerRadius = 50
        instructionView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
//        instructionView.layer.shadowColor = UIColor.init(hexString: "192d00ff")!.cgColor
//        instructionView.layer.shadowOpacity = 1
//        instructionView.layer.shadowOffset = CGSize(width: 2, height: 9)
//        instructionView.layer.shadowRadius = 20
        self.pageScroll.addSubview(instructionView)
        instructionView.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-20)
        }
        
        compensationView.backgroundColor = .white
//        compensationView.layer.cornerRadius = 50
//        compensationView.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
//        compensationView.layer.shadowColor = UIColor.init(hexString: "192d00ff")!.cgColor
//        compensationView.layer.shadowOpacity = 1
//        compensationView.layer.shadowOffset = CGSize(width: 2, height: 9)
//        compensationView.layer.shadowRadius = 20
        self.pageScroll.addSubview(compensationView)
        compensationView.snp.makeConstraints { (make) in
            make.top.equalTo(instructionView.snp.bottom)
            make.centerX.equalTo(self.view)
            make.width.equalTo(self.view).offset(-20)
            make.bottom.equalToSuperview().offset(-10)
        }
        
        let _ = Timer.scheduledTimer(timeInterval: 0.9, target: self, selector: #selector(runTimedCode), userInfo: nil, repeats: true)
        
        switch tagView {
        case .truck:
            totalPage               = _AppCoreData.getDataTruck().count
            break
        case .shoulder:
            totalPage               =  _AppCoreData.getDataShoulder().count
            break
        case .hip:
            totalPage               = _AppCoreData.getDataHip().count
            break
        case .ankle:
            totalPage               = _AppCoreData.getDataAnkle().count
            break
        default:
            break
        }
        self.reloadData()
        self.title = "\(paging)" + " " + NSLocalizedString("kOutOf", comment: "") + " " + "\(totalPage)"
       
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        videoPlayer.play()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Remove introVideo
        if let navigationController = self.navigationController {
            var listViewController = navigationController.viewControllers
            for viewController in listViewController {
                if let kellyIntroVC = viewController as? VC_MobilityIntroVideo {
                    listViewController.remove(at: listViewController.firstIndex(of: kellyIntroVC)!)
                    self.navigationController?.setViewControllers(listViewController, animated: false)
                    return
                }
            }
        }
        
//        if let navigationController = self.navigationController {
//            if navigationController.viewControllers.count > 2 { // Tabbar and current viewcontroller = 2
//
//                //stop oldViewController
//                for viewController in navigationController.viewControllers {
//                    if let testVC = viewController as? VC_MainPageMobilityTestVideo {
//                        testVC.videoPlayer.stop()
//                        break
//                    }
//                }
//
//                if let firstViewController = navigationController.viewControllers.first {
//                    let newViewControllers = [firstViewController, self]
//                    self.navigationController?.setViewControllers(newViewControllers, animated: false)
//                }
//            }
//        }
    }
    
    // MARK: - Buttons
    
    @objc func enterScoreButtonTapped() {
        if let dataSource = self.dataSource {
            videoPlayer.pause()
            let enterScoreVC = VC_MainPageMobilityTestSelection()
            enterScoreVC.setDataSource(newDataSource: dataSource)
            enterScoreVC.pagingSelection = paging
            enterScoreVC.totalPageSelection = totalPage
            enterScoreVC.tagView = tagView
            enterScoreVC.userResult = userResult
            self.navigationController?.pushViewController(enterScoreVC, animated: true)
        }
    }
    
    //MARK: - Buttons
    @objc func backButtonTapped() {
        
        self.videoPlayer.stop()
        if let video = self.dataSource {
            let _ = _AppCoreData.getPreviousMobilityTestVideo(video: video)
        }
        self.navigationController?.popViewController(animated: true)
        
        //Ẩn message hỏi
//        let alertVC = UIAlertController.init(title: NSLocalizedString("kHeyTitle", comment: ""),
//                                             message: NSLocalizedString("kBackTestScoreMessage", comment: ""),
//                                             preferredStyle: .alert)
//        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kContinueBtn", comment: ""),
//                                              style: .cancel) { (action) in
//                                                alertVC.dismiss(animated: true, completion: nil)
//        }
//        let okAction = UIAlertAction.init(title: NSLocalizedString("kSureBtn", comment: ""),
//                                          style: .default) { (action) in
//                                            alertVC.dismiss(animated: true, completion: nil)
//                                            self.videoPlayer.stop()
//                                            self.navigationController?.popViewController(animated: true)
//        }
//
//        alertVC.addAction(cancelAction)
//        alertVC.addAction(okAction)
//        self.present(alertVC, animated: true, completion: nil)
                    
//        guard let mobilityVideo = _AppCoreData.getPreviousMobilityTestVideo() else {
//
//            self.navigationController?.popToRootViewController(animated: true)
//            return
//        }
//
//        if mobilityVideo.videoID == self.dataSource?.videoID {
//            self.navigationController?.popToRootViewController(animated: true)
//            return
//        }
//
//        if let navigationController = self.navigationController {
//
//            let mobilityVideoTest = VC_MainPageMobilityTestVideo()
//            mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
//
//            if let firstViewController = navigationController.viewControllers.first {
//                let newViewControllers = [firstViewController, mobilityVideoTest, self]
//                self.navigationController?.setViewControllers(newViewControllers, animated: false)
//                self.navigationController?.popViewController(animated: true)
//            }
//        }
    }
    
    // MARK: - Layouts
    func loadInstrctionView(listInstruction: [String]) {
        
        for subView in instructionView.subviews {
            subView.removeFromSuperview()
        }
        
        let instructionLabel = UILabel()
        instructionLabel.text = NSLocalizedString("kInstructionLabel", comment: "")
        instructionLabel.font = setFontSize(size: 14, weight: .semibold)
        instructionLabel.textColor = UIColor.init(hexString: "666666")
        instructionView.addSubview(instructionLabel)
        instructionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview()
            make.height.equalTo(14)
        }
        
        var markView = instructionLabel
        
        for instructionText in listInstruction {
            
            let icon = UIImageView()
            icon.image = UIImage.init(named: "instruction_icon")
            instructionView.addSubview(icon)
            icon.snp.makeConstraints { (make) in
                make.top.equalTo(markView.snp.bottom).offset(15)
                make.left.equalToSuperview().offset(35)
                make.height.width.equalTo(18)
            }
            
            let attributedString = NSMutableAttributedString(string: instructionText)
            let paragraphStyle = NSMutableParagraphStyle()
            paragraphStyle.lineSpacing = 8
            attributedString.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, attributedString.length))
            
            let instructionLabel = UILabel()
            instructionLabel.numberOfLines = 0
            instructionLabel.attributedText = attributedString
            instructionLabel.font = setFontSize(size: 14, weight: .regular)
            instructionLabel.textColor = UIColor.init(hexString: "888888")
            instructionView.addSubview(instructionLabel)
            instructionLabel.snp.makeConstraints { (make) in
                make.left.equalTo(icon.snp.right).offset(16)
                make.top.equalTo(icon)
                make.right.equalTo(markView).offset(-10)
            }
            
            markView = instructionLabel
            
        }
        
        markView.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview().offset(-20)
        })
    }
    
    func loadCompensationView(listCompensations: [String]) {
        
        for subView in compensationView.subviews {
            subView.removeFromSuperview()
        }
        
        let compensationLabel = UILabel()
        compensationLabel.text = NSLocalizedString("kCompensationLabel", comment: "")
        compensationLabel.font = setFontSize(size: 14, weight: .semibold)
        compensationLabel.textColor = UIColor.init(hexString: "666666")
        compensationView.addSubview(compensationLabel)
        compensationLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(20)
            make.left.equalToSuperview().offset(35)
            make.right.equalToSuperview()
            make.height.equalTo(14)
        }
        
        var markView = compensationLabel
        
        for compensationText in listCompensations {
            
            let icon = UIImageView()
            icon.image = UIImage.init(named: "compensation_icon")
            compensationView.addSubview(icon)
            icon.snp.makeConstraints { (make) in
                make.top.equalTo(markView.snp.bottom).offset(15)
                make.left.equalToSuperview().offset(35)
                make.height.width.equalTo(18)
            }
            
            let compensationLabel = UILabel()
            compensationLabel.numberOfLines = 0
            compensationLabel.text = compensationText
            compensationLabel.font = setFontSize(size: 14, weight: .regular)
            compensationLabel.textColor = UIColor.init(hexString: "888888")
            compensationView.addSubview(compensationLabel)
            compensationLabel.snp.makeConstraints { (make) in
                make.left.equalTo(icon.snp.right).offset(16)
                make.top.equalTo(icon)
                make.right.equalTo(markView)
            }
            
            markView = compensationLabel
            
        }
        
        markView.snp.makeConstraints({ (make) in
            make.bottom.equalToSuperview().offset(-20)
        })
    }

    //MARK: - Data
    func setDataSource(newDataSource: MobilityTestVideo) {
        self.dataSource = newDataSource
        
        let newVideoData = VideoDataSource.init(JSONString: "{}")!
        newVideoData.videoID = newDataSource.videoID
        newVideoData.videoPlayUrl = newDataSource.videoURLString
        
        self.videoPlayer.setVideoDataSource(newVideoData: newVideoData)
        
        self.reloadData()
    }
    
    func reloadData() {
        guard let dataSource = self.dataSource else {
            return
        }
        
        self.videoTitle.text = dataSource.videoTitle
        
        self.loadInstrctionView(listInstruction: dataSource.videoInstruction)
        self.loadCompensationView(listCompensations: dataSource.videoCompensations)
    }
    
    @objc func runTimedCode() {
        pageScroll.showsVerticalScrollIndicator = true
        if #available(iOS 13, *) {
            (pageScroll.subviews[(pageScroll.subviews.count - 1)].subviews[0]).backgroundColor = UIColor.init(hexString: "2d00ff")//verticalIndicator
            (pageScroll.subviews[(pageScroll.subviews.count - 2)].subviews[0]).backgroundColor = UIColor.init(hexString: "2d00ff") //horizontalIndicator
        } else {
            if let verticalIndicator: UIImageView = (pageScroll.subviews[(pageScroll.subviews.count - 1)] as? UIImageView) {
                verticalIndicator.backgroundColor = UIColor.init(hexString: "2d00ff")
            }
            
            if let horizontalIndicator: UIImageView = (pageScroll.subviews[(pageScroll.subviews.count - 2)] as? UIImageView) {
                horizontalIndicator.backgroundColor = UIColor.init(hexString: "2d00ff")
            }
        }
        UIView.animate(withDuration: 0.0001) {
            self.pageScroll.flashScrollIndicators()
        }
    }
}
