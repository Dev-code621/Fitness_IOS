//
//  VW_StreaksCongratulations.swift
//  NewTRS
//
//  Created by yaya on 9/28/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import AVFoundation

class VC_StreaksCongratulations: UIViewController {

    private var timerFireworks          : Timer?
    private var countFireworks          = 0
    private let congratulationTitle     = UILabel()
    private let congratulationDetail    = UILabel()
    private let coverStreakView         = UIView()
    private let streaksInactiveImage    = UIImageView()
    private let streaksActiveImage      = UIImageView()
    private let addOverlay              = UIView()
    private let nameStreaks             = UILabel()
    private let pointStreaks            = UILabel()
    private let doneBtn                 = UIButton()

    private var player                  = AVAudioPlayer()
    
    //MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = UIColor.white
        
        addOverlay.backgroundColor = UIColor.clear
        addOverlay.alpha = 1
        addOverlay.layer.cornerRadius = 60
        self.view.addSubview(addOverlay)
        
        addOverlay.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview().multipliedBy(0.6666)
            make.width.height.equalTo(120)
        }
        
        self.addOverlay.addSubview(streaksActiveImage)
        streaksActiveImage.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        coverStreakView.layer.masksToBounds = true
        coverStreakView.backgroundColor = .white
        self.addOverlay.addSubview(coverStreakView)
        coverStreakView.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalToSuperview()
        }
        
        streaksInactiveImage.layer.cornerRadius = 60
        streaksInactiveImage.layer.masksToBounds = true
        streaksInactiveImage.layer.opacity = 0.8
        self.coverStreakView.addSubview(streaksInactiveImage)
        streaksInactiveImage.snp.makeConstraints { (make) in
            make.left.top.equalToSuperview()
            make.width.height.equalTo(120)
        }
        
        nameStreaks.textColor =  UIColor.init(hexString: "2d00ff")
        nameStreaks.alpha = 0
        nameStreaks.font = setFontSize(size: 18, weight: .bold)
        self.view.addSubview(nameStreaks)
        nameStreaks.snp.makeConstraints { (make) in
            make.top.equalTo(streaksActiveImage.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        pointStreaks.textColor =  UIColor.init(hexString: "666666")
        pointStreaks.alpha = 0
        pointStreaks.font = setFontSize(size: 14, weight: .regular)
        self.view.addSubview(pointStreaks)
        pointStreaks.snp.makeConstraints { (make) in
            make.top.equalTo(nameStreaks.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        
        congratulationTitle.text = NSLocalizedString("kCongratulationTitle", comment: "")
        congratulationTitle.font = setFontSize(size: 24, weight: .bold)
        congratulationTitle.alpha = 0
        congratulationTitle.transform = CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        self.view.addSubview(congratulationTitle)
        congratulationTitle.snp.makeConstraints { (make) in
            make.top.equalTo(pointStreaks.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
        }
        
        congratulationDetail.font = setFontSize(size: 14, weight: .regular)
        congratulationDetail .textColor =  UIColor.init(hexString: "666666")
        congratulationDetail.numberOfLines = 0
        congratulationDetail.textAlignment = .center
        congratulationDetail.alpha = 0
        self.view.addSubview(congratulationDetail)
        congratulationDetail.snp.makeConstraints { (make) in
            make.top.equalTo(congratulationTitle.snp.bottom).offset(12)
            make.width.equalTo(250)
            make.centerX.equalToSuperview()
        }
        
        doneBtn.setTitle(NSLocalizedString("kOkAction", comment: ""), for: .normal)
        doneBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        doneBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold) 
        doneBtn.layer.cornerRadius = 20
        doneBtn.isHidden = true
        doneBtn.addTarget(self, action: #selector(didSelectOkButton), for: .touchDown)
        self.view.addSubview(doneBtn)
        doneBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
            make.bottom.equalToSuperview().offset(-20)
        }
                        
        timerFireworks = Timer.scheduledTimer(timeInterval: 1.25, target: self, selector: #selector(loadFireWork), userInfo: nil, repeats: true)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.congratulationTitle.alpha = 0
        self.congratulationDetail.alpha = 0
        self.nameStreaks.alpha = 0
        self.pointStreaks.alpha = 0
        
        UIView.animate(withDuration: 10) {
            self.coverStreakView.snp.remakeConstraints { (make) in
                make.left.top.equalToSuperview()
                make.width.equalTo(120)
                make.height.equalTo(0)
            }
            self.view.layoutIfNeeded()
        }
        
        self.nameStreaks.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.nameStreaks.fadeIn()
        })
        
        self.pointStreaks.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.pointStreaks.fadeIn()
        })
        
        self.congratulationTitle.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.congratulationTitle.fadeIn(duration:1)
        })
        
        self.congratulationDetail.fadeOut(completion: {
            (finished: Bool) -> Void in
            self.congratulationDetail.fadeIn(duration:1)
        })
        
        self.playSound()
    }
    
    //MARK: - UI Actions
    @objc func loadFireWork() {
        
        countFireworks += 1
        
        if countFireworks == 8 {
            timerFireworks?.invalidate()
            timerFireworks = nil
            countFireworks = 0
            doneBtn.isHidden = false
            self.coverStreakView.removeFromSuperview()
            return
        }
        
        let screenBounds = UIScreen.main.bounds
        
        let leftBounds: CGFloat = screenBounds.origin.x + 20
        let rightBounds: CGFloat = screenBounds.origin.x + screenBounds.size.width - 20.0
        let topBounds: CGFloat = screenBounds.origin.y + 20.0
        let bottomBounds: CGFloat = screenBounds.origin.y + screenBounds.size.height - 20.0
        let posX = SwiftFireworks.sharedInstance.randomCGFloat(min: leftBounds, max: rightBounds)
        let posY = SwiftFireworks.sharedInstance.randomCGFloat(min: topBounds, max: bottomBounds)
        
        SwiftFireworks.sharedInstance.showFireworkSet(inView: view,
                                                      andPosition: CGPoint(x: posX, y: posY),
                                                      numberOfFireworks: 6)
        // Jumping Animation
        UIView.animate(withDuration: 0.3 / 1.5, animations: {
            self.congratulationTitle.transform =
                CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }) { finished in
            UIView.animate(withDuration: 0.3 / 2, animations: {
                self.congratulationTitle.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            }) { finished in
                UIView.animate(withDuration: 0.3 / 2, animations: {
                    self.congratulationTitle.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    //MARK: - Play Sound
    @objc func didSelectOkButton() {
        self.dismiss(animated: true, completion: nil)
    }

    func playSound() {
        guard let url = Bundle.main.url(forResource: "PhaoBong", withExtension: "mp3") else { return }

        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSession.Category.playback)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url)
            player.prepareToPlay()
            player.play()

        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    //MARK: - Get Data
    func reloadData(data: [UserArchivementDataSource]) {
        if !data.isEmpty {
            if let streak = data.last {
                
                if let streakURL = URL(string: streak.achievementActiveImage) {
                    self.streaksActiveImage.setImage(url: streakURL, placeholder: UIImage.init(named: "default_archiverment_image")!)
                }
                
                if let unlockedURL = URL(string: streak.achievementInactiveImage) {
                    self.streaksInactiveImage.setImage(url: unlockedURL, placeholder: UIImage.init(named: "default_archiverment_image")!)
                }
                
                self.nameStreaks.text = streak.achievementTitle
                self.pointStreaks.text = NSLocalizedString("kPoints", comment: "").replacingOccurrences(of: "%@",with: "\(streak.achievementMilestone)")
                self.congratulationDetail.text = NSLocalizedString("kUserStreaksCongratulationDescr", comment: "").replacingOccurrences(of: "%@", with: "\(streak.achievementMilestone)")
            }
        }
    }
}

//MARK: - Extension UI
extension UIView {
    func fadeIn(duration: TimeInterval = 10.0, delay: TimeInterval = 0.0, completion: @escaping ((Bool) -> Void) = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 1.0
        }, completion: completion)
    }

    func fadeOut(duration: TimeInterval = 10.0, delay: TimeInterval = 13.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseIn, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
    
    func fadeInOut(duration: TimeInterval = 10.0, delay: TimeInterval = 13.0, completion: @escaping (Bool) -> Void = {(finished: Bool) -> Void in}) {
        UIView.animate(withDuration: duration, delay: delay, options: UIView.AnimationOptions.curveEaseInOut, animations: {
            self.alpha = 0.0
        }, completion: completion)
    }
}
