//
//  VC_UserSubscription.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_UserSubscription: UIViewController {
    
    let bannerImage     = UIImageView()
    let contentView     = UIView()
    let membershipValue = UILabel()
    
    let regstrationDate = UILabel()
    let expirationDate  = UILabel()
    
    let loadingAnimation = VW_LoadingAnimation()
    
    let cancelBtn       = UIButton()
//    let changePlanBtn   = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyBoard))
        self.view.addGestureRecognizer(singleTap)

        bannerImage.image = UIImage.init(named: "head_banner")
        bannerImage.layer.cornerRadius = 30
        bannerImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.432)
        }
        
        let backBtn = UIButton()
        backBtn.setBackgroundImage(UIImage.init(named: "back_white_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(35)
            make.height.width.equalTo(30)
        }
        
        contentView.backgroundColor = UIColor.init(hexString: "ffffff")
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 2, height: 9)
        contentView.layer.shadowRadius = 20
        self.view.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(-70)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(240)
        }
        
        let subscriptionLabel = UILabel()
        subscriptionLabel.text = NSLocalizedString("kSubsriptions", comment: "")
        subscriptionLabel.font = setFontSize(size: 24, weight: .bold)//HurmeGeometricSans2
        subscriptionLabel.textColor = UIColor.init(hexString: "333333")
        contentView.addSubview(subscriptionLabel)
        subscriptionLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.left.equalToSuperview().offset(40)
        }
        
        let membershipPackageLabel = UILabel()
        membershipPackageLabel.text = NSLocalizedString("kMembershipPackage", comment: "")
        membershipPackageLabel.font = setFontSize(size: 18, weight: .regular) 
        membershipPackageLabel.textColor = UIColor.init(hexString: "333333")
        contentView.addSubview(membershipPackageLabel)
        membershipPackageLabel.snp.makeConstraints { (make) in
            make.top.equalTo(subscriptionLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(40)
        }
        
        membershipValue.font = setFontSize(size: 14, weight: .bold)
        membershipValue.textColor = UIColor.init(hexString: "333333")
        contentView.addSubview(membershipValue)
        membershipValue.snp.makeConstraints { (make) in
            make.top.equalTo(membershipPackageLabel.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(40)
        }
        
        let registrationDateLabel = UILabel()
        registrationDateLabel.text = NSLocalizedString("kRegistrationDate", comment: "")
        registrationDateLabel.font = setFontSize(size: 14, weight: .regular)
        registrationDateLabel.textColor = UIColor.init(hexString: "888888")
        contentView.addSubview(registrationDateLabel)
        registrationDateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(membershipValue.snp.bottom).offset(23)
            make.left.equalToSuperview().offset(40)
        }
        
        regstrationDate.text = "20/12/2019"
        regstrationDate.font = setFontSize(size: 12, weight: .bold)
        regstrationDate.textColor = UIColor.init(hexString: "666666")
        contentView.addSubview(regstrationDate)
        regstrationDate.snp.makeConstraints { (make) in
            make.top.equalTo(registrationDateLabel.snp.bottom).offset(8)
            make.left.equalTo(registrationDateLabel)
        }
        
        let expriedDateLabel = UILabel()
        expriedDateLabel.text = NSLocalizedString("kExpiredDate", comment: "")
        expriedDateLabel.font = setFontSize(size: 14, weight: .regular)
        expriedDateLabel.textColor = UIColor.init(hexString: "888888")
        contentView.addSubview(expriedDateLabel)
        expriedDateLabel.snp.makeConstraints { (make) in
            make.right.equalToSuperview().offset(-40)
            make.width.top.equalTo(registrationDateLabel)
        }
        
        expirationDate.text = "20/12/2019"
        expirationDate.font = setFontSize(size: 12, weight: .bold)
        expirationDate.textColor = UIColor.init(hexString: "666666")
        contentView.addSubview(expirationDate)
        expirationDate.snp.makeConstraints { (make) in
            make.top.equalTo(expriedDateLabel.snp.bottom).offset(8)
            make.left.equalTo(expriedDateLabel)
        }
        
//        changePlanBtn.setTitle(NSLocalizedString("kChangePlanSubscription", comment: ""), for: .normal)
//        changePlanBtn.setTitleColor(UIColor.init(hexString: "ffffff")!, for: .normal)
//        changePlanBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
//        changePlanBtn.backgroundColor = UIColor.init(hexString: "2d00ff")!
//        changePlanBtn.layer.cornerRadius = 20
//        changePlanBtn.addTarget(self, action: #selector(changePlanButtonTapped), for: .touchUpInside)
//        self.view.addSubview(changePlanBtn)
//        changePlanBtn.snp.makeConstraints { (make) in
//            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
//            make.centerX.equalToSuperview()
//            make.width.equalToSuperview().offset(-40)
//            make.height.equalTo(40)
//        }
        
//        cancelBtn.isHidden = true
        cancelBtn.setTitle(NSLocalizedString("kCancelSubcriptionMember", comment: ""), for: .normal)
        cancelBtn.setTitleColor(UIColor.init(hexString: "ff5555")!, for: .normal)
        cancelBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        cancelBtn.backgroundColor = .white
        cancelBtn.layer.cornerRadius = 20
        cancelBtn.layer.borderWidth = 1.5
        cancelBtn.layer.borderColor = UIColor.init(hexString: "ff5555")!.cgColor
        cancelBtn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        self.view.addSubview(cancelBtn)
        cancelBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    //MARK: -
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func cancelButtonTapped() {
        switch _AppDataHandler.getUserProfile().userPlanPlatform {
        case .android:
            self.showMessageCrossPlatform(message: NSLocalizedString("kUserPlatformCancelAndroidMessage", comment: ""))
            break
        case .web:
            self.showMessageCrossPlatform(message: NSLocalizedString("kUserPlatformCancelWebMessage", comment: ""))
            break
        case .iOS:
            let alertVC = UIAlertController.init(title: NSLocalizedString("kCancelSubscriptionAlert", comment: ""),
                                                 message: NSLocalizedString("kCancelSubscriptionMessage", comment: ""),
                                                 preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                  style: .cancel) { (action) in
                alertVC.dismiss(animated: true, completion: nil)
            }
            let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                              style: .default) { (action) in
                alertVC.dismiss(animated: true, completion: nil)
                if let url = URL.init(string: _AppDataHandler.getUserProfile().cancelPlanLink) {
                    UIApplication.shared.open(url)
                }
            }
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            break
        default:
            break
        }
    }
    
    private func showMessageCrossPlatform(message: String) {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kSubsriptions", comment: ""),
                                             message: message,
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                          style: .default) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func changePlanButtonTapped() {
        let iapVC = VC_InAppPurchase()
        self.navigationController?.pushViewController(iapVC, animated: true)
    }
    
    //MARK: - Data
    func reloadData() {
        let userProfile = _AppDataHandler.getUserProfile()
        
        self.loadingAnimation.isHidden = false
        let _ = _AppDataHandler.getUserProfile { (isSuccess, error, newUserProfile) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess && (newUserProfile != nil) {
                self.membershipValue.text = newUserProfile!.userPlan
                
                let dateFormatter = DateFormatter()
                dateFormatter.dateFormat = "MMM dd, yyyy"
                
                let endDate = Date.init(timeIntervalSince1970: TimeInterval(newUserProfile!.userPlanExpriedDate))
                self.expirationDate.text = dateFormatter.string(from: endDate)
                
//                if userProfile.userPlanPlatform == .android || userProfile.userPlanPlatform == .web {
//                    self.cancelBtn.isHidden = true
//                } else {
//                    if userProfile.cancelStatus == .onAutoRenew {
//                        self.cancelBtn.isHidden = false
//                    } else {
//                        self.cancelBtn.isHidden = true
//                    }
//                }
                
                if userProfile.cancelStatus == .onAutoRenew {
                    self.cancelBtn.isHidden = false
                } else {
                    self.cancelBtn.isHidden = true
                }
                
                if userProfile.userPlanRegisterDate == 0 {
                    self.regstrationDate.text = ""
                    return
                }
                
                let startDate = Date.init(timeIntervalSince1970: TimeInterval(newUserProfile!.userPlanRegisterDate))
                self.regstrationDate.text = dateFormatter.string(from: startDate)
            }
        }
        
        self.membershipValue.text = userProfile.userPlan
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd, yyyy"
        
        let endDate = Date.init(timeIntervalSince1970: TimeInterval(userProfile.userPlanExpriedDate))
        self.expirationDate.text = dateFormatter.string(from: endDate)
        
//        if userProfile.userPlanPlatform == .android || userProfile.userPlanPlatform == .web {
//            self.cancelBtn.isHidden = true
//        } else {
//            if userProfile.cancelStatus == .onAutoRenew {
//                self.cancelBtn.isHidden = false
//            } else {
//                self.cancelBtn.isHidden = true
//            }
//        }
        
        if userProfile.cancelStatus == .onAutoRenew {
            self.cancelBtn.isHidden = false
        } else {
            self.cancelBtn.isHidden = true
        }
        
        if userProfile.userPlanRegisterDate == 0 {
            self.regstrationDate.text = ""
            return
        }
        
        let startDate = Date.init(timeIntervalSince1970: TimeInterval(userProfile.userPlanRegisterDate))
        self.regstrationDate.text = dateFormatter.string(from: startDate)
    }
}
