//
//  VW_BackView.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol AnotomyDelegate {
    func didSelectTheKey(name: String)
}

class VW_BackView: UIView {
    
    var listBackView        : [[String: Any]] = []
    let fullBodyImageView   = UIImageView()
    var delegate            : AnotomyDelegate?
    var mutiTouch           = false
    var counter             = 0
    let elbowImageView      = UIImageView()
    let headImageView       = UIImageView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        let calvesImageView = UIImageView()
        calvesImageView.image = UIImage.init(named: "back_calves")
        calvesImageView.contentMode = .scaleAspectFit
        self.addSubview(calvesImageView)
        calvesImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let calvesData = ["name":"back_calves",
                          "key":"calves",
                          "view":calvesImageView] as [String : Any]
        self.listBackView.append(calvesData)
        
        elbowImageView.image = UIImage.init(named: "back_elbow")
        elbowImageView.contentMode = .scaleAspectFit
        self.addSubview(elbowImageView)
        elbowImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let elbowData = ["name":"back_elbow",
                         "key":"elbow",
                         "view":elbowImageView] as [String : Any]
        self.listBackView.append(elbowData)
        
        let gluteImageView = UIImageView()
        gluteImageView.image = UIImage.init(named: "back_glutes")
        gluteImageView.contentMode = .scaleAspectFit
        self.addSubview(gluteImageView)
        gluteImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let glutesData = ["name":"back_glutes",
                          "key":"glutes",
                          "view":gluteImageView] as [String : Any]
        self.listBackView.append(glutesData)
            
        let hamstringImageView = UIImageView()
        hamstringImageView.image = UIImage.init(named: "back_hamstrings")
        hamstringImageView.contentMode = .scaleAspectFit
        self.addSubview(hamstringImageView)
        hamstringImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let hamstringsData = ["name":"back_hamstrings",
                              "key":"hamstrings",
                              "view":hamstringImageView] as [String : Any]
        self.listBackView.append(hamstringsData)
        
        headImageView.image = UIImage.init(named: "back_head")
        headImageView.contentMode = .scaleAspectFit
        self.addSubview(headImageView)
        headImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let headData = ["name":"back_head",
                        "key":"head",
                        "view":headImageView] as [String : Any]
        self.listBackView.append(headData)
        
        let kneeImageView = UIImageView()
        kneeImageView.image = UIImage.init(named: "back_knee")
        kneeImageView.contentMode = .scaleAspectFit
        self.addSubview(kneeImageView)
        kneeImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let kneeData = ["name":"back_knee",
                        "key":"back_knee",
                        "view":kneeImageView] as [String : Any]
        self.listBackView.append(kneeData)
            
        let lumbarImageView = UIImageView()
        lumbarImageView.image = UIImage.init(named: "back_lumbar_spine")
        lumbarImageView.contentMode = .scaleAspectFit
        self.addSubview(lumbarImageView)
        lumbarImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let spineData = ["name":"back_lumbar_spine",
                         "key":"lumbar_spine",
                         "view":lumbarImageView] as [String : Any]
        self.listBackView.append(spineData)
            
        let neckImageView = UIImageView()
        neckImageView.image = UIImage.init(named: "back_neck")
        neckImageView.contentMode = .scaleAspectFit
        self.addSubview(neckImageView)
        neckImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let neckData = ["name":"back_neck",
                        "key":"back_neck",
                        "view":neckImageView] as [String : Any]
        self.listBackView.append(neckData)
        
        let shoulderImageView = UIImageView()
        shoulderImageView.image = UIImage.init(named: "back_shoulder")
        shoulderImageView.contentMode = .scaleAspectFit
        self.addSubview(shoulderImageView)
        shoulderImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let shoulderData = ["name":"back_shoulder",
                            "key":"back_shoulder",
                            "view":shoulderImageView] as [String : Any]
        self.listBackView.append(shoulderData)
        
        let tSpineImageView = UIImageView()
        tSpineImageView.image = UIImage.init(named: "back_t_spine")
        tSpineImageView.contentMode = .scaleAspectFit
        self.addSubview(tSpineImageView)
        tSpineImageView.snp.makeConstraints { (make) in
            make.centerX.bottom.equalToSuperview()
            make.top.equalToSuperview().offset(10)
            make.width.equalToSuperview().offset(-20)
        }
        
        let tSpineData = ["name":"back_t_spine",
                          "key":"t_spine",
                          "view":tSpineImageView] as [String : Any]
        self.listBackView.append(tSpineData)
            
        fullBodyImageView.image = UIImage.init(named: "back_full_body")
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
            self.bringSubviewToFront(elbowImageView)
            self.bringSubviewToFront(headImageView)
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if let touch = touches.first {
            
            if mutiTouch {return}
            if !_AppDataHandler.getUserProfile().isFreemiumUser() {
                self.bringSubviewToFront(fullBodyImageView)
            }
            
            for imageData in listBackView {
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
