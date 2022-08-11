//
//  VC_MainPageMobilityTestResults.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageMobilityTestResults: UIViewController {
    
    let trunkResultLabel        = UILabel()
    let shouderResultLabel      = UILabel()
    let hipResultLabel          = UILabel()
    let ankleResultLabel        = UILabel()
    
    var userResult              = UserMobilityDataSource.init(JSONString: "{}")!
    
    let loadingAnimation        = VW_LoadingAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        self.navigationItem.setHidesBackButton(true, animated: true)
        
        let sendBtn = UIButton.init(type: .custom)
        sendBtn.setTitle(NSLocalizedString("kMobilityTestFinishBtn", comment: "").uppercased(), for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = setFontSize(size: 14, weight: .semibold)
        sendBtn.backgroundColor = kBlueBackgroundColor
        sendBtn.layer.borderWidth = 1
        sendBtn.layer.cornerRadius = 15
        sendBtn.layer.borderColor = kBlueBackgroundColor?.cgColor
        sendBtn.addTarget(self, action: #selector(self.nextButtonTapped), for: .touchUpInside)
        
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sendBtn)
        
//        let sendBtn = UIBarButtonItem.init(title: "Finish".uppercased(),
//                                           style: .done,
//                                           target: self,
//                                           action: #selector(nextButtonTapped))
//        self.navigationItem.rightBarButtonItem = sendBtn
        
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kMobilityTestResultTitle", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        let pageMessage = UILabel()
        pageMessage.text = NSLocalizedString("kMobilityTestMessageTitle", comment: "")
        pageMessage.font = setFontSize(size: 14, weight: .regular)
        pageMessage.textColor = UIColor.init(hexString: "666666")
        self.view.addSubview(pageMessage)
        pageMessage.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(16)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(15)
        }
        
        // trunk View
        let trunkView = UIImageView()
        trunkView.image = UIImage.init(named: "trunk_result_image")
        trunkView.contentMode = .scaleAspectFill
        trunkView.layer.masksToBounds = true
        self.view.addSubview(trunkView)
        trunkView.snp.makeConstraints { (make) in
            make.top.equalTo(pageMessage.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
        }
        
        let opacity1 = UIView()
        opacity1.backgroundColor = .black
        opacity1.layer.opacity = 0.5
        trunkView.addSubview(opacity1)
        opacity1.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        trunkResultLabel.textAlignment = .center
        trunkResultLabel.textColor = .white
        trunkView.addSubview(trunkResultLabel)
        trunkResultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        // shoulder view
        let shoulderView = UIImageView()
        shoulderView.image = UIImage.init(named: "shoulder_result_image")
        shoulderView.layer.masksToBounds = true
        self.view.addSubview(shoulderView)
        shoulderView.snp.makeConstraints { (make) in
            make.top.equalTo(trunkView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(trunkView)
        }
        
        let opacity2 = UIView()
        opacity2.backgroundColor = .black
        opacity2.layer.opacity = 0.5
        shoulderView.addSubview(opacity2)
        opacity2.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        shouderResultLabel.textAlignment = .center
        shouderResultLabel.textColor = .white
        shoulderView.addSubview(shouderResultLabel)
        shouderResultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        // hip view
        let hipView = UIImageView()
        hipView.image = UIImage.init(named: "hip_result_image")
        hipView.layer.masksToBounds = true
        self.view.addSubview(hipView)
        hipView.snp.makeConstraints { (make) in
            make.top.equalTo(shoulderView.snp.bottom).offset(16)
            make.left.right.equalToSuperview()
            make.height.equalTo(shoulderView)
        }
        
        let opacity3 = UIView()
        opacity3.backgroundColor = .black
        opacity3.layer.opacity = 0.5
        hipView.addSubview(opacity3)
        opacity3.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        hipResultLabel.textAlignment = .center
        hipResultLabel.textColor = .white
        hipView.addSubview(hipResultLabel)
        hipResultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        // ankle view
        let ankleView = UIImageView()
        ankleView.image = UIImage.init(named: "ankle_result_image")
        ankleView.layer.masksToBounds = true
        self.view.addSubview(ankleView)
        ankleView.snp.makeConstraints { (make) in
            make.top.equalTo(hipView.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
            make.height.equalTo(hipView)
        }
        
        let opacity4 = UIView()
        opacity4.backgroundColor = .black
        opacity4.layer.opacity = 0.5
        ankleView.addSubview(opacity4)
        opacity4.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        ankleResultLabel.textAlignment = .center
        ankleResultLabel.textColor = .white
        ankleView.addSubview(ankleResultLabel)
        ankleResultLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
        }
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(nextButtonTapped))
        self.view.addGestureRecognizer(singleTap)
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
        self.navigationItem.setHidesBackButton(true, animated: true)
        // remove old video screen
        if let button = self.navigationItem.rightBarButtonItem?.customView {
            button.frame = CGRect(x:0, y:0, width:110, height:20)
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //Remove old video screen selection
        guard let navigationController = self.navigationController else { return }
        var navigationArray = navigationController.viewControllers
        
        let previousVC = navigationArray[navigationArray.count - 2]
        
        if previousVC is VC_MainPageMobilityTestSelection { // Check type of previous UIViewController
            navigationArray.remove(at: navigationArray.count - 2) // To remove previous UIViewController
            self.navigationController?.viewControllers = navigationArray
        }
    }
    
    //MARK: - Button
    
    @objc func nextButtonTapped() {
        
        guard let userWatchLaterOption = UserDefaults.standard.value(forKey: kUserMobilityKellySkip) as? Int else {
            let kellyVideoVC = VC_KellyRecomendationVideo()
            _NavController.pushViewController(kellyVideoVC, animated: true)
            return
        }
        
        let currentDateInt = Int(Date().timeIntervalSince1970)
        
        if (currentDateInt - userWatchLaterOption) >= 86400 { // 1 days
            let kellyVideoVC = VC_KellyRecomendationVideo()
            _NavController.pushViewController(kellyVideoVC, animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    //MARK: - Data
    func reloadData() {
        
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
        self.userResult.on_process = false
        
        let groupAttribute = [NSAttributedString.Key.font : setFontSize(size: 24, weight: .regular)] as [NSAttributedString.Key : Any]
        let percentAttribute = [NSAttributedString.Key.font : setFontSize(size: 24, weight: .semibold)] as [NSAttributedString.Key : Any]
        
        //trunk
        let trunkAttributedString = NSMutableAttributedString()
        trunkAttributedString.append(NSAttributedString.init(string: NSLocalizedString("kTrunk", comment: ""), attributes: groupAttribute))
        trunkAttributedString.append(NSAttributedString.init(string: String(format: " %.f%%", trunkPoint*100), attributes: percentAttribute))
        trunkResultLabel.attributedText = trunkAttributedString
        
        //Shoulder
        let shoulderAttributedString = NSMutableAttributedString()
        shoulderAttributedString.append(NSAttributedString.init(string: NSLocalizedString("kShoulder", comment: ""), attributes: groupAttribute))
        shoulderAttributedString.append(NSAttributedString.init(string: String(format: " %.f%%", shoulderPoint*100), attributes: percentAttribute))
        shouderResultLabel.attributedText = shoulderAttributedString
        
        //Hip
        let hipAttributedString = NSMutableAttributedString()
        hipAttributedString.append(NSAttributedString.init(string: NSLocalizedString("kHip", comment: ""), attributes: groupAttribute))
        hipAttributedString.append(NSAttributedString.init(string: String(format: " %.f%%", hipPoint*100), attributes: percentAttribute))
        hipResultLabel.attributedText = hipAttributedString
        
        //ankle
        let ankleAttributedString = NSMutableAttributedString()
        ankleAttributedString.append(NSAttributedString.init(string: NSLocalizedString("kAnkle", comment: ""), attributes: groupAttribute))
        ankleAttributedString.append(NSAttributedString.init(string: String(format: " %.f%%", anklePoint*100), attributes: percentAttribute))
        ankleResultLabel.attributedText = ankleAttributedString
        
        self.sendDataResult()
    }
    
    func sendDataResult() {
        self.loadingAnimation.isHidden = false
        _AppDataHandler.sendMobilityResult(newUserResult: self.userResult) { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                NotificationCenter.default.post(name: kMobilityNeedReloadNotification, object: nil, userInfo: nil)
            }
            else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
}
