//
//  VC_MainPageMobilityTestSelection.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/23/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageMobilityTestSelection: UIViewController {
    
    let redPoseView     = UIImageView()
    let yellowPoseView  = UIImageView()
    let greenPoseView   = UIImageView()
    
    let redPoseTitle    = UILabel()
    let yellowPoseTitle = UILabel()
    let greenPoseTitle = UILabel()
    
    private let cicrleViewRed       = UIImageView()
    private let cicrleViewYellow    = UIImageView()
    private let cicrleViewGreen     = UIImageView()
    
    //Data
    var dataSource      : MobilityTestVideo?
    var pagingSelection         = 0
    var totalPageSelection      = 0
    var tagView         :TagView = .all
    var userResult          = UserMobilityDataSource.init(JSONString: "{}")!
    var loadingAnimation    = VW_LoadingAnimation()

    
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
        
        let quitBtn = UIButton.init(type: .custom)
        quitBtn.setTitle(NSLocalizedString("kMobilityTestQuitBtn", comment: "").uppercased(), for: .normal)
        quitBtn.setTitleColor(.white, for: .normal)
        quitBtn.titleLabel?.font = setFontSize(size: 14, weight: .semibold)
        quitBtn.backgroundColor = kBlueBackgroundColor
        quitBtn.layer.borderWidth = 1
        quitBtn.layer.cornerRadius = 15
        quitBtn.layer.borderColor = kBlueBackgroundColor?.cgColor
        quitBtn.addTarget(self, action: #selector(self.quitButtonTapped), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: quitBtn)
        
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kMobilityTestTitle", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        let redView = UIView()
        self.view.addSubview(redView)
        redView.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
        }
        
        redPoseView.image = UIImage.init(named: "default_thumbnail_image")
        redPoseView.contentMode = .scaleToFill
        redPoseView.layer.masksToBounds = true
        redView.addSubview(redPoseView)
        redPoseView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        cicrleViewRed.backgroundColor = UIColor.white
        cicrleViewRed.contentMode = .center
        cicrleViewRed.image = UIImage.init(named: "checkSelection_icon")
        cicrleViewRed.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        cicrleViewRed.layer.cornerRadius = 10
        cicrleViewRed.layer.borderWidth = 3
        
        self.view.addSubview(cicrleViewRed)
        
        cicrleViewRed.snp.makeConstraints { (make) in
            make.top.equalTo(redPoseView.snp.top).offset(-10)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(20)
        }
        cicrleViewRed.isHidden = true
        
        let yellowView = UIView()
        self.view.addSubview(yellowView)
        yellowView.snp.makeConstraints { (make) in
            make.top.equalTo(redView.snp.bottom).offset(15)
            make.left.right.equalToSuperview()
            make.height.equalTo(redView)
        }
        
        yellowPoseView.image = UIImage.init(named: "default_thumbnail_image")
        yellowPoseView.contentMode = .scaleToFill
        yellowPoseView.layer.masksToBounds = true
        yellowView.addSubview(yellowPoseView)
        yellowPoseView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        cicrleViewYellow.backgroundColor = UIColor.white
        cicrleViewYellow.contentMode = .center
        cicrleViewYellow.image = UIImage.init(named: "checkSelection_icon")
        cicrleViewYellow.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        cicrleViewYellow.layer.cornerRadius = 10
        cicrleViewYellow.layer.borderWidth = 3
        
        self.view.addSubview(cicrleViewYellow)
        
        cicrleViewYellow.snp.makeConstraints { (make) in
            make.top.equalTo(yellowPoseView.snp.top).offset(-10)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(20)
        }
        cicrleViewYellow.isHidden = true
        
        let greenView = UIView()
        self.view.addSubview(greenView)
        greenView.snp.makeConstraints { (make) in
            make.top.equalTo(yellowView.snp.bottom).offset(15)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(yellowView)
        }
        
        greenPoseView.image = UIImage.init(named: "default_thumbnail_image")
        greenPoseView.contentMode = .scaleToFill
        greenPoseView.layer.masksToBounds = true
        greenView.addSubview(greenPoseView)
        greenPoseView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        cicrleViewGreen.backgroundColor = UIColor.white
        cicrleViewGreen.contentMode = .center
        cicrleViewGreen.image = UIImage.init(named: "checkSelection_icon")
        cicrleViewGreen.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        cicrleViewGreen.layer.cornerRadius = 10
        cicrleViewGreen.layer.borderWidth = 3
        
        self.view.addSubview(cicrleViewGreen)
        
        cicrleViewGreen.snp.makeConstraints { (make) in
            make.top.equalTo(greenPoseView.snp.top).offset(-10)
            make.right.equalToSuperview().offset(-15)
            make.width.height.equalTo(20)
        }
        cicrleViewGreen.isHidden = true
        //Opacity
        let redOpacityView = UIView()
        redOpacityView.backgroundColor = UIColor.init(hexString: "000000")!
        redOpacityView.layer.opacity = 0.05
        redPoseView.addSubview(redOpacityView)
        redOpacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let yellowOpacityView = UIView()
        yellowOpacityView.backgroundColor = UIColor.init(hexString: "000000")!
        yellowOpacityView.layer.opacity = 0.05
        yellowPoseView.addSubview(yellowOpacityView)
        yellowOpacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let greenOpacityView = UIView()
        greenOpacityView.backgroundColor = UIColor.init(hexString: "000000")!
        greenOpacityView.layer.opacity = 0.05
        greenPoseView.addSubview(greenOpacityView)
        greenOpacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.view.layoutIfNeeded()
        
        //Gradient
        let redGradientLayer = CAGradientLayer()
        redGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        redGradientLayer.frame = redPoseView.bounds
        redGradientLayer.locations = [0.6, 1.0]
        redPoseView.layer.addSublayer(redGradientLayer)
        redPoseView.layer.masksToBounds = true
        
        
        let yellowGradientLayer = CAGradientLayer()
        yellowGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        yellowGradientLayer.frame = yellowPoseView.bounds
        yellowGradientLayer.locations = [0.6, 1.0]
        yellowPoseView.layer.addSublayer(yellowGradientLayer)
        yellowPoseView.layer.masksToBounds = true
        
        let greenGradientLayer = CAGradientLayer()
        greenGradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        greenGradientLayer.frame = greenPoseView.bounds
        greenGradientLayer.locations = [0.6, 1.0]
        greenPoseView.layer.addSublayer(greenGradientLayer)
        greenPoseView.layer.masksToBounds = true
        
        //Color Mark
        let redColorMark = UIView()
        redColorMark.backgroundColor = UIColor.init(hexString: "ff5555")
        redColorMark.layer.cornerRadius = 5
        redPoseView.addSubview(redColorMark)
        redColorMark.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.width.equalTo(25)
        }
        
        let yellowColorMark = UIView()
        yellowColorMark.backgroundColor = UIColor.init(hexString: "ffbd34")
        yellowColorMark.layer.cornerRadius = 5
        yellowPoseView.addSubview(yellowColorMark)
        yellowColorMark.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.width.equalTo(25)
        }
        
        let greenColorMark = UIView()
        greenColorMark.backgroundColor = UIColor.init(hexString: "0bd493")
        greenColorMark.layer.cornerRadius = 5
        greenPoseView.addSubview(greenColorMark)
        greenColorMark.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(12)
            make.bottom.equalToSuperview().offset(-12)
            make.height.width.equalTo(25)
        }
        
        //Label
        redPoseTitle.text = NSLocalizedString("kPoseForRed", comment: "")
        redPoseTitle.font = setFontSize(size: 14, weight: .semibold)
        redPoseTitle.textColor = .white
        redPoseTitle.textAlignment = .left
        redPoseTitle.numberOfLines = 0
        redPoseView.addSubview(redPoseTitle)
        redPoseTitle.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.left.equalTo(redColorMark.snp.right).offset(10)
            make.width.equalToSuperview().offset(-50)
        }
        
        yellowPoseTitle.text = NSLocalizedString("kPoseForYellow", comment: "")
        yellowPoseTitle.font = setFontSize(size: 14, weight: .semibold)
        yellowPoseTitle.textColor = .white
        yellowPoseTitle.textAlignment = .left
        yellowPoseTitle.numberOfLines = 0
        yellowPoseView.addSubview(yellowPoseTitle)
        yellowPoseTitle.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.left.equalTo(yellowColorMark.snp.right).offset(10)
            make.width.equalToSuperview().offset(-50)
        }
        
        greenPoseTitle.text = NSLocalizedString("kPoseForGreen", comment: "")
        greenPoseTitle.font = setFontSize(size: 14, weight: .semibold) 
        greenPoseTitle.textColor = .white
        greenPoseTitle.textAlignment = .left
        greenPoseTitle.numberOfLines = 0
        greenPoseView.addSubview(greenPoseTitle)
        greenPoseTitle.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-12)
            make.left.equalTo(greenColorMark.snp.right).offset(10)
            make.width.equalToSuperview().offset(-50)
        }
        
        // Button
        let redBtn = UIButton()
        redBtn.addTarget(self, action: #selector(redButtonTapped), for: .touchUpInside)
        redView.addSubview(redBtn)
        redBtn.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let yellowBtn = UIButton()
        yellowBtn.addTarget(self, action: #selector(yellowButtonTapped), for: .touchUpInside)
        yellowView.addSubview(yellowBtn)
        yellowBtn.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let greenBtn = UIButton()
        greenBtn.addTarget(self, action: #selector(greenButtonTapped), for: .touchUpInside)
        greenView.addSubview(greenBtn)
        greenBtn.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        self.title = "\(pagingSelection)" + " " + NSLocalizedString("kOutOf", comment: "") + " " +  "\(totalPageSelection)"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        
        if let button = self.navigationItem.rightBarButtonItem?.customView {
            button.frame = CGRect(x:0, y:0, width:110, height:20)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //        //Remove old video screen
        //        guard let navigationController = self.navigationController else { return }
        //        var navigationArray = navigationController.viewControllers
        //        let previousVC = navigationArray[navigationArray.count - 2]
        //
        //        if previousVC is VC_MainPageMobilityTestVideo { // Check type of previous UIViewController
        //            navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
        //            self.navigationController?.viewControllers = navigationArray
        //        }
    }
    
    //MARK: - Button
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc private func quitButtonTapped(sender : UIButton) {
        sender.alpha = sender.alpha == 1.0 ? 0.5 : 1.0
        
        var arrayResult = _AppCoreData.getDataShoulder()
        arrayResult += _AppCoreData.getDataTruck()
        arrayResult += _AppCoreData.getDataAnkle()
        arrayResult += _AppCoreData.getDataHip()
        
        let sum = arrayResult.filter({$0.selectedResult != 0})
        
        if sum.count == _AppCoreData.getDataTruck().count {
            // hoàn thành phần 1
            self.sendDataResult()
        } else if sum.count > _AppCoreData.listTrunkVideo.count && sum.count < _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count{
            //hoàn thành phần 1, phần 2 chưa hoàn thành
            for item in _AppCoreData.listShouderVideo {
                item.selectedResult = 0
            }
            self.sendDataResult()
        } else if sum.count > _AppCoreData.listTrunkVideo.count && sum.count == _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count {
            //hoàn thành phần 2
            self.sendDataResult()
        } else if sum.count > _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count && sum.count < _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count + _AppCoreData.listHipVideo.count {
            //hoàn thành phần 2, phân 3 chưa hoàn thành
            for item in _AppCoreData.listHipVideo {
                item.selectedResult = 0
            }
            self.sendDataResult()
        } else if sum.count > _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count && sum.count == _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count + _AppCoreData.listHipVideo.count {
            //hoàn thành phần 3
            self.sendDataResult()
        } else if sum.count > _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count + _AppCoreData.listHipVideo.count && sum.count < _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count + _AppCoreData.listHipVideo.count + _AppCoreData.listAnkleVideo.count {
            //hoàn thành phần 3, phần 4 chưa hoàn thành
            for item in _AppCoreData.listAnkleVideo {
                item.selectedResult = 0
            }
            self.sendDataResult()
        }  else if sum.count > _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count + _AppCoreData.listHipVideo.count && sum.count == _AppCoreData.listTrunkVideo.count + _AppCoreData.listShouderVideo.count + _AppCoreData.listHipVideo.count + _AppCoreData.listAnkleVideo.count {
            // hoàn thành phần 4
            let testResult = VC_MainPageMobilityTestResults()
            testResult.userResult = userResult
            self.navigationController?.pushViewController(testResult, animated: true)
        } else {
            //chưa hoàn thành phần 1
            if _AppCoreData.listTrunkVideo.count != 0, _AppCoreData.listTrunkVideo[0].selectedResult == 0 {
                self.navigationController?.popToRootViewController(animated: true)
                return
            }
            for item in _AppCoreData.listTrunkVideo {
                item.selectedResult = 0
            }
            
            userResult.trunkPointAVG = 0.0
            userResult.shoulderPointAVG = 0.0
            userResult.hipPointAVG = 0.0
            userResult.anklePointAVG = 0.0
            self.sendDataResult()
        }
        
    }
    
    func sendDataResult() {
        
        let testDateUnixTime = userResult.testDate
        
        var testDate = Date()
        var dateCounter = TimeInterval()
        if testDateUnixTime > 0 {
            testDate = Date.init(timeIntervalSince1970: TimeInterval(testDateUnixTime))
            dateCounter = Date().timeIntervalSince(testDate)
        } else {
            dateCounter = 0
        }

        if dateCounter >= 1209600 {
            userResult.trunkPointAVG = 0.0
            userResult.shoulderPointAVG = 0.0
            userResult.hipPointAVG = 0.0
            userResult.anklePointAVG = 0.0
        }
        
        var trunkPoint = 0.0
        if userResult.trunkPointAVG != 0 {
            trunkPoint = userResult.trunkPointAVG
        } else {
            if _AppCoreData.listTrunkVideo.count > 0 {
                for videoData in _AppCoreData.listTrunkVideo {
                    trunkPoint += Double(videoData.selectedResult)
                }
                trunkPoint = trunkPoint/Double(_AppCoreData.listTrunkVideo.count*3)
            }
        }
        
        var shoulderPoint = 0.0
        if userResult.shoulderPointAVG != 0 {
            shoulderPoint = userResult.shoulderPointAVG
        } else {
            if _AppCoreData.listShouderVideo.count > 0 {
                for videoData in _AppCoreData.listShouderVideo {
                    shoulderPoint += Double(videoData.selectedResult)
                }
                shoulderPoint = shoulderPoint/Double(_AppCoreData.listShouderVideo.count*3)
            }
        }
        
        var hipPoint = 0.0
        if userResult.hipPointAVG != 0 {
            hipPoint = userResult.hipPointAVG
        } else {
            if _AppCoreData.listHipVideo.count > 0 {
                for videoData in _AppCoreData.listHipVideo {
                    hipPoint += Double(videoData.selectedResult)
                }
                hipPoint = hipPoint/Double(_AppCoreData.listHipVideo.count*3)
            }
        }
        
        var anklePoint = 0.0
        if userResult.anklePointAVG != 0 {
            anklePoint = userResult.trunkPointAVG
        } else {
            if _AppCoreData.listAnkleVideo.count > 0 {
                for videoData in _AppCoreData.listAnkleVideo {
                    anklePoint += Double(videoData.selectedResult)
                }
                anklePoint = anklePoint/Double(_AppCoreData.listAnkleVideo.count*3)
            }
        }
        
        self.userResult.trunkPointAVG = round(trunkPoint * 100) / 100
        self.userResult.shoulderPointAVG = round(shoulderPoint * 100) / 100
        self.userResult.hipPointAVG = round(hipPoint * 100) / 100
        self.userResult.anklePointAVG = round(anklePoint * 100) / 100
        
        if trunkPoint != 0 && shoulderPoint != 0 && hipPoint != 0 && anklePoint != 0 {
            self.userResult.on_process = false

        } else {
            self.userResult.on_process = true
        }
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.sendMobilityResult(newUserResult: self.userResult) { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true

            if isSuccess {
                self.navigationController?.popToRootViewController(animated: true)
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    @objc func redButtonTapped() {
        
        redPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        redPoseView.layer.borderWidth = 3
        yellowPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        yellowPoseView.layer.borderWidth = 0
        greenPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        greenPoseView.layer.borderWidth = 0
        
        cicrleViewRed.isHidden = false
        cicrleViewYellow.isHidden = true
        cicrleViewGreen.isHidden = true
        
        self.dataSource?.selectedResult = 1
        self.didSelectResult()
    }
    
    @objc func yellowButtonTapped() {
        
        yellowPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        yellowPoseView.layer.borderWidth = 3
        redPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        redPoseView.layer.borderWidth = 0
        greenPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        greenPoseView.layer.borderWidth = 0
        
        cicrleViewRed.isHidden = true
        cicrleViewYellow.isHidden = false
        cicrleViewGreen.isHidden = true
        
        self.dataSource?.selectedResult = 2
        self.didSelectResult()
    }
    
    @objc func greenButtonTapped() {
        
        greenPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        greenPoseView.layer.borderWidth = 3
        redPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        redPoseView.layer.borderWidth = 0
        yellowPoseView.layer.borderColor = UIColor.init(hexString: "2d00ff")?.cgColor
        yellowPoseView.layer.borderWidth = 0
        
        cicrleViewRed.isHidden = true
        cicrleViewYellow.isHidden = true
        cicrleViewGreen.isHidden = false
        
        self.dataSource?.selectedResult = 3
        self.didSelectResult()
    }
    
    func didSelectResult() {
        
        if let dataSource = self.dataSource {
            _AppCoreData.setMobilityTestVideo(updatedVideo: dataSource)
            
            switch tagView {
            case .truck:
                if  pagingSelection == _AppCoreData.listTrunkVideo.count  {
                    let testResult = VC_MainPageMobilityTestResults()
                    testResult.userResult = userResult
                    self.navigationController?.pushViewController(testResult, animated: true)
                    return
                }
                
                let mobilityVideo = _AppCoreData.listTrunkVideo[pagingSelection]
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = pagingSelection + 1
                mobilityVideoTest.totalPage = totalPageSelection
                mobilityVideoTest.tagView = .truck
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
                break
            case .shoulder:
                if  pagingSelection == _AppCoreData.listShouderVideo.count  {
                    let testResult = VC_MainPageMobilityTestResults()
                    testResult.userResult = userResult
                    self.navigationController?.pushViewController(testResult, animated: true)
                    return
                }
                
                let mobilityVideo = _AppCoreData.listShouderVideo[pagingSelection]
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = pagingSelection + 1
                mobilityVideoTest.tagView = .shoulder
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
                break
            case .hip:
                if  pagingSelection == _AppCoreData.listHipVideo.count  {
                    let testResult = VC_MainPageMobilityTestResults()
                    testResult.userResult = userResult
                    self.navigationController?.pushViewController(testResult, animated: true)
                    return
                }
                let mobilityVideo = _AppCoreData.listHipVideo[pagingSelection]
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = pagingSelection + 1
                mobilityVideoTest.tagView = .hip
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
                break
            case .ankle:
                if  pagingSelection == _AppCoreData.listAnkleVideo.count  {
                    let testResult = VC_MainPageMobilityTestResults()
                    testResult.userResult = userResult
                    self.navigationController?.pushViewController(testResult, animated: true)
                    return
                }
                let mobilityVideo = _AppCoreData.listAnkleVideo[pagingSelection]
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                mobilityVideoTest.paging = pagingSelection + 1
                mobilityVideoTest.tagView = .ankle
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
                break
            default:
                guard let mobilityVideo = _AppCoreData.getNextMobilityTestVideo() else {
                    if userResult.testDate != 0 || userResult.on_process {
                        self.sendDataResult()
                        return
                    }
                    let testResult = VC_MainPageMobilityTestResults()
                    testResult.userResult = userResult
                    self.navigationController?.pushViewController(testResult, animated: true)
                    return
                }
                let mobilityVideoTest = VC_MainPageMobilityTestVideo()
                mobilityVideoTest.setDataSource(newDataSource: mobilityVideo)
                var arrayResult = _AppCoreData.getDataShoulder()
                arrayResult += _AppCoreData.getDataTruck()
                arrayResult += _AppCoreData.getDataAnkle()
                arrayResult += _AppCoreData.getDataHip()
                
               // let sum = arrayResult.filter({$0.selectedResult != 0})
               // pagingSelection = arrayResult.count - sum.count
                mobilityVideoTest.paging = pagingSelection + 1
                mobilityVideoTest.tagView = .all
                mobilityVideoTest.totalPage = totalPageSelection
                mobilityVideoTest.userResult = userResult
                _NavController.pushViewController(mobilityVideoTest, animated: true)
                break
            }
        }
    }
    
    //MARK: - Data
    
    func setDataSource(newDataSource: MobilityTestVideo) {
        self.dataSource = newDataSource
    }
    
    private func reloadData() {
        
        guard let newDataSource = self.dataSource else {
            return
        }
        
        if newDataSource.poseImages.redPose != "" {
            if let imageURL = URL(string: newDataSource.poseImages.redPose) {
                redPoseView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "default_thumbnail_image")!)
            }
        }
        
        if newDataSource.poseImages.yellowPose != "" {
            if let imageURL = URL(string: newDataSource.poseImages.yellowPose) {
                yellowPoseView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "default_thumbnail_image")!)
            }
        }
        
        if newDataSource.poseImages.greenPose != "" {
            if let imageURL = URL(string: newDataSource.poseImages.greenPose) {
                greenPoseView.sd_setImage(with: imageURL, placeholderImage: UIImage.init(named: "default_thumbnail_image")!)
            }
        }
        
        redPoseTitle.text = newDataSource.poseImages.redText
        yellowPoseTitle.text = newDataSource.poseImages.yellowText
        greenPoseTitle.text = newDataSource.poseImages.greenText
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
