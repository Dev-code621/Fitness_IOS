//
//  VC_CustomAlertController.swift
//  NewTRS
//
//  Created by Luu Lucas on 8/27/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

protocol DailyAlertControllerDelegate {
    func didSelectPainOption()
    func didSelectWorkoutOption()
    func didSelectMobilityTestOption()
}

class VC_DailyAlertController : UIViewController {

    var delegate        : DailyAlertControllerDelegate?
    let contentView     = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .clear
        
        let opacityView = UIView()
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.4
        self.view.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let dismissPopup = UITapGestureRecognizer.init(target: self, action: #selector(dissmisPopup))
        opacityView.addGestureRecognizer(dismissPopup)
        
        contentView.backgroundColor = .white
        contentView.layer.cornerRadius = 30
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.centerY.lessThanOrEqualToSuperview()
            make.centerX.equalToSuperview()
            make.height.equalTo(326.5)
            make.width.equalTo(335)
        }
        
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 8
        paragraphStyle.alignment = .center
        
        let titleLabelAttr = NSMutableAttributedString(string: NSLocalizedString("kDailyQuizTitle", comment: ""))
        titleLabelAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle,
                                   range: NSMakeRange(0, titleLabelAttr.length))
        
        let titleLabel = UILabel()
        titleLabel.attributedText = titleLabelAttr
        titleLabel.font = setFontSize(size: 18, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "333333")
        titleLabel.numberOfLines = 2
        titleLabel.textAlignment = .center
        contentView.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
            make.left.equalToSuperview().offset(40)
        }
        
        let dailyBtn = UIButton()
        dailyBtn.layer.borderColor = UIColor.init(hexString: "718cfe")!.cgColor
        dailyBtn.layer.borderWidth = 1
        dailyBtn.layer.cornerRadius = 20
        dailyBtn.layer.masksToBounds = true
        dailyBtn.setTitle(NSLocalizedString("kDailyQuizOptionDaily", comment: ""), for: .normal)
        dailyBtn.setTitleColor(UIColor.init(hexString: "718cfe"), for: .normal)
        dailyBtn.titleLabel?.font = setFontSize(size: 15, weight: .semibold)
        dailyBtn.addTarget(self, action: #selector(dailyButtonTapped), for: .touchDown)
        contentView.addSubview(dailyBtn)
        dailyBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalToSuperview().offset(96)
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-40)
        }
        
        let workoutTitleAttr = NSMutableAttributedString(string: NSLocalizedString("kDailyQuizOptionWorkouts", comment: ""))
        workoutTitleAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle,
                                   range: NSMakeRange(0, workoutTitleAttr.length))
        workoutTitleAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: "718cfe")!,
                                   range: NSMakeRange(0, workoutTitleAttr.length))
        
        let workoutBtn = UIButton()
        workoutBtn.layer.borderColor = UIColor.init(hexString: "718cfe")!.cgColor
        workoutBtn.layer.borderWidth = 1
        workoutBtn.layer.cornerRadius = 30
        workoutBtn.layer.masksToBounds = true
        workoutBtn.setAttributedTitle(workoutTitleAttr, for: .normal)
        workoutBtn.titleLabel?.font = setFontSize(size: 15, weight: .semibold)
        workoutBtn.titleLabel?.numberOfLines = 2
        workoutBtn.addTarget(self, action: #selector(workoutButtonTapped), for: .touchDown)
        contentView.addSubview(workoutBtn)
        workoutBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(dailyBtn.snp.bottom).offset(16)
            make.height.equalTo(60)
            make.width.equalToSuperview().offset(-40)
        }
        
        let painTitleAttr = NSMutableAttributedString(string: NSLocalizedString("kDailyQuizOptionPain", comment: ""))
        painTitleAttr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle,
                                   range: NSMakeRange(0, painTitleAttr.length))
        painTitleAttr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: "718cfe")!,
                                   range: NSMakeRange(0, painTitleAttr.length))
        
        let painBtn = UIButton()
        painBtn.layer.borderColor = UIColor.init(hexString: "718cfe")!.cgColor
        painBtn.layer.borderWidth = 1
        painBtn.layer.cornerRadius = 30
        painBtn.layer.masksToBounds = true
        painBtn.setAttributedTitle(painTitleAttr, for: .normal)
        painBtn.titleLabel?.font = setFontSize(size: 15, weight: .semibold)
        painBtn.titleLabel?.numberOfLines = 2
        painBtn.addTarget(self, action: #selector(painButtonTapped), for: .touchDown)
        contentView.addSubview(painBtn)
        painBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(workoutBtn.snp.bottom).offset(16)
            make.height.equalTo(60)
            make.width.equalToSuperview().offset(-40)
        }
        
        self.checkShowMobilize(button: painBtn)
    }
    
    //MARK: -
    @objc private func dissmisPopup() {
        self.dismiss(animated: true, completion: nil)
        let homeNav = UINavigationController(rootViewController: VC_MainPageHome())
        _NavController.present(homeNav, animated: true, completion: nil)
    }
    
    @objc func dailyButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    @objc func painButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        if delegate != nil {
            delegate!.didSelectPainOption()
        }
    }
    
    @objc func workoutButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        if delegate != nil {
            delegate!.didSelectWorkoutOption()
        }
    }
    
    func addButton(addBtn: UIButton) {

        let mobilityBtn = UIButton()
        mobilityBtn.layer.borderColor = UIColor.init(hexString: "718cfe")!.cgColor
        mobilityBtn.layer.borderWidth = 1
        mobilityBtn.layer.cornerRadius = 20
        mobilityBtn.layer.masksToBounds = true
        mobilityBtn.setTitle(NSLocalizedString("kDailyQuizOptionMobilized", comment: ""), for: .normal)
        mobilityBtn.titleLabel?.font = setFontSize(size: 15, weight: .semibold)
        mobilityBtn.setTitleColor(UIColor.init(hexString: "718cfe"), for: .normal)
        mobilityBtn.addTarget(self, action: #selector(mobilizeButtonTapped), for: .touchDown)
        contentView.addSubview(mobilityBtn)
        mobilityBtn.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(addBtn.snp.bottom).offset(16)
            make.height.equalTo(40)
            make.width.equalToSuperview().offset(-40)
        }
        
        contentView.snp.updateConstraints { (make) in
            make.height.equalTo(366.5) //306.5
        }
    }
    
    func checkShowMobilize(button: UIButton) {
        let _ = _AppDataHandler.getUserMobilityPoint { (isSucess, error, userMobilityPoint) in

            if isSucess {
                let testDateUnixTime = userMobilityPoint.testDate
                
                let testDate = Date.init(timeIntervalSince1970: TimeInterval(testDateUnixTime))
                let dateCounter = Date().timeIntervalSince(testDate)
                if userMobilityPoint.testDate == 0 || dateCounter >= 1209600 {
                    self.addButton(addBtn: button)
                }
            }
        }
    }
    
    @objc func mobilizeButtonTapped() {
        self.dismiss(animated: true, completion: nil)
        if delegate != nil {
            delegate!.didSelectMobilityTestOption()
        }
      }
}
