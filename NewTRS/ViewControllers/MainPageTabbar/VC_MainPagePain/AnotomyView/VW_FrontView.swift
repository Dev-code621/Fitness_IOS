//
//  VW_self.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_FrontView: UIView {
    
    var listFrontView       : [[String: Any]] = []
    var fullBodyImageView   = UIImageView()
    var delegate            : AnotomyDelegate?
    var mutiTouch         = false
    var counter             = 0
    let headImageView       = UIImageView()
    let quadsImageView      = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        headImageView.image = UIImage.init(named: "front_head")!
        headImageView.contentMode = .scaleAspectFit
        self.addSubview(headImageView)
        headImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let headData = ["name":"front_head",
                        "key": "head",
                        "view":headImageView] as [String : Any]
        self.listFrontView.append(headData)
        
        let neckImageView = UIImageView()
        neckImageView.image = UIImage.init(named: "front_neck")!
        neckImageView.contentMode = .scaleAspectFit
        self.addSubview(neckImageView)
        neckImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let neckData = ["name":"front_neck",
                        "key": "front_neck",
                        "view":neckImageView] as [String : Any]
        self.listFrontView.append(neckData)
        
        let abdominalImageView = UIImageView()
        abdominalImageView.image = UIImage.init(named: "front_abdominals")
        abdominalImageView.contentMode = .scaleAspectFit
        self.addSubview(abdominalImageView)
        abdominalImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let abdominalData = ["name":"front_abdominals",
                             "key": "abdominals_diaphragm",
                             "view":abdominalImageView] as [String : Any]
        self.listFrontView.append(abdominalData)
        
        let ankleImageView = UIImageView()
        ankleImageView.image = UIImage.init(named: "front_ankle")
        ankleImageView.contentMode = .scaleAspectFit
        self.addSubview(ankleImageView)
        ankleImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let ankleData = ["name":"front_ankle",
                         "key": "ankle",
                         "view":ankleImageView] as [String : Any]
        self.listFrontView.append(ankleData)
        
        let footImageView = UIImageView()
        footImageView.image = UIImage.init(named: "front_foot")
        footImageView.contentMode = .scaleAspectFit
        self.addSubview(footImageView)
        footImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let footData = ["name":"front_foot",
                        "key": "foot",
                        "view":footImageView] as [String : Any]
        self.listFrontView.append(footData)
        
//        let wristImageView = UIImageView()
//        wristImageView.image = UIImage.init(named: "front_wrist")
//        wristImageView.contentMode = .scaleAspectFit
//        self.addSubview(wristImageView)
//        wristImageView.snp.makeConstraints { (make) in
//            make.centerX.bottom.equalToSuperview()
//            make.top.equalToSuperview().offset(10)
//            make.width.equalToSuperview().offset(-20)
//        }
//
//        let wristData = ["name":"front_wrist",
//                         "key":"wrist",
//                         "view":wristImageView] as [String : Any]
//        self.listFrontView.append(wristData)
        
        let forearmImageView = UIImageView()
        forearmImageView.image = UIImage.init(named: "front_forearm")
        forearmImageView.contentMode = .scaleAspectFit
        self.addSubview(forearmImageView)
        forearmImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let forearmData = ["name":"front_forearm",
                           "key":"wrist_forearm",
                           "view":forearmImageView] as [String : Any]
        self.listFrontView.append(forearmData)
        
        let hipImageView = UIImageView()
        hipImageView.image = UIImage.init(named: "front_hip")
        hipImageView.contentMode = .scaleAspectFit
        self.addSubview(hipImageView)
        hipImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let hipData = ["name":"front_hip",
                       "key":"front_hip",
                       "view":hipImageView] as [String : Any]
        self.listFrontView.append(hipData)
        
        let kneeImageView = UIImageView()
        kneeImageView.image = UIImage.init(named: "front_knee")
        kneeImageView.contentMode = .scaleAspectFit
        self.addSubview(kneeImageView)
        kneeImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let kneeData = ["name":"front_knee",
                        "key":"front_knee",
                        "view":kneeImageView] as [String : Any]
        self.listFrontView.append(kneeData)
        
        let pelvisImageView = UIImageView()
        pelvisImageView.image = UIImage.init(named: "front_pelvis")
        pelvisImageView.contentMode = .scaleAspectFit
        self.addSubview(pelvisImageView)
        pelvisImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let pelvisData = ["name":"front_pelvis",
                          "key":"pelvis",
                          "view":pelvisImageView] as [String : Any]
        self.listFrontView.append(pelvisData)
        
        quadsImageView.image = UIImage.init(named: "front_quads")
        quadsImageView.contentMode = .scaleAspectFit
        self.addSubview(quadsImageView)
        quadsImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let quadsData = ["name":"front_quads",
                         "key":"quads",
                         "view":quadsImageView] as [String : Any]
        self.listFrontView.append(quadsData)
        
        let shinsImageView = UIImageView()
        shinsImageView.image = UIImage.init(named: "front_shins")
        shinsImageView.contentMode = .scaleAspectFit
        self.addSubview(shinsImageView)
        shinsImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let shinsData = ["name":"front_shins",
                         "key":"shins",
                         "view":shinsImageView] as [String : Any]
        self.listFrontView.append(shinsData)
        
        let shoulderImageView = UIImageView()
        shoulderImageView.image = UIImage.init(named: "front_shoulder")
        shoulderImageView.contentMode = .scaleAspectFit
        self.addSubview(shoulderImageView)
        shoulderImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let shoulderData = ["name":"front_shoulder",
                            "key":"front_shoulder",
                            "view":shoulderImageView] as [String : Any]
        self.listFrontView.append(shoulderData)
        
        let chestImageView = UIImageView()
        chestImageView.image = UIImage.init(named: "front_chest")
        chestImageView.contentMode = .scaleAspectFit
        self.addSubview(chestImageView)
        chestImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let chestData = ["name":"front_chest",
                         "key":"chest",
                         "view":chestImageView] as [String : Any]
        self.listFrontView.append(chestData)
        
        fullBodyImageView.image = UIImage.init(named: "front_full_body")
        fullBodyImageView.contentMode = .scaleAspectFit
        self.addSubview(fullBodyImageView)
        fullBodyImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UIView
    
    func loadBlurView() {
        
        self.layoutIfNeeded()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = self.bounds
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        self.addSubview(blurEffectView)
        self.sendSubviewToBack(blurEffectView)
    }
    
    func loadAccountView() {
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            self.bringSubviewToFront(headImageView)
            self.bringSubviewToFront(quadsImageView)
        }
    }
    //MARK: - Touch handler
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if mutiTouch {return}
            if !_AppDataHandler.getUserProfile().isFreemiumUser() {
                self.bringSubviewToFront(fullBodyImageView)
            }
            
            for imageData in listFrontView {
                if let imageView = imageData["view"] as! UIImageView? {
                    let position = touch.location(in: imageView)
                    let color = imageView.getPixelColorAt(point: position)
                    if color.rgb()! > 0 {
                        self.mutiTouch = true
                        self.bringSubviewToFront(imageView)
                        imageView.flash(numberOfFlashes: 3)
                        
                        if !_AppDataHandler.getUserProfile().isFreemiumUser() {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                                
                                UIView.animate(withDuration: 0.5) {
                                    self.bringSubviewToFront(self.fullBodyImageView)
                                    
                                }
                            }
                        }
                        
                        if (self.delegate != nil) {
                            self.checkTimeMutiTouch() // kiểm tra 5s sau mới cho touch
                            self.delegate?.didSelectTheKey(name: imageData["key"] as! String)
                        }
                        
                        break
                    }
                }
            }
            
        }
    }
    
    func checkTimeMutiTouch() {
        let _ = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(runTimed), userInfo: nil, repeats: true)
        counter = 0
    }
    
    @objc func runTimed() {
        counter += 1
        if counter == 5 {
            mutiTouch = false
        }
    }
}


