//
//  VC_InAppPurchase.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import StoreKit
import SwiftyStoreKit

enum ProductType :String {
    case month = "month"
    case year = "year"
}

enum PresentingType  {
    case signIn
    case presenting
}

class VC_InAppPurchase: UIViewController {
    
    let backBtn             = UIButton()
    let skipBtn             = UIButton()
    let closeBtn            = UIButton()
    
    var presentingType      : PresentingType = .signIn
    
    let backgroundImages    = UIImageView()
    
    let messageReviewTitle  = UILabel()
    
    let monthView           = UIView()
    let monthNameLabel      = UILabel()
    let monthPriceLabel     = UILabel()
    let monthIcon           = UIImageView()
    
    let yearView            = UIView()
    let yearNameLabel       = UILabel()
    let yearPriceLabel      = UILabel()
    let yearIcon            = UIImageView()
    
    let payPopup            = UIView()
    let selectedPackageLabel    = UILabel()
    let perRank                 = UILabel()
    
    let resendBtn               = UIButton()
    private let policyTitle     = UIButton()
    private let policyDesc      = UILabel()
    private let policyBtn       = UIButton()
    private let policyView      = UIView()
    private let termsBtn        = UIButton()
    private let privacyBtn      = UIButton()
    private let payBtn          = UIButton()
    private let resendLine      = UIView()
    
    let loadingAnimation    = VW_LoadingAnimation()
    var loadingAnimationCount   = 0
    
    var selectedProduct     : ProductType = .month
    
    var monthProduct        : SKProduct?
    var yearProduct         : SKProduct?
    private var userStatus  : UserVerifyStatus = .brandNewAppleID

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = .black
        
        //Payment Manager
        _AppPaymentManager.configPayment()
        
        backgroundImages.image = UIImage.init(named: "iap_background_image2")
        self.view.addSubview(backgroundImages)
        backgroundImages.snp.makeConstraints { (make) in
            make.top.right.left.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(1.4346)
        }
        
        let underlineAttribute = [NSAttributedString.Key.underlineStyle: NSUnderlineStyle.single.rawValue,
                                  NSAttributedString.Key.foregroundColor: UIColor.white,
                                  NSAttributedString.Key.font : setFontSize(size: 16, weight: .semibold)] as [NSAttributedString.Key : Any]
        let underlineAttributedString = NSAttributedString(string: NSLocalizedString("kSkipBtn", comment: ""), attributes: underlineAttribute)
        
        skipBtn.setAttributedTitle(underlineAttributedString, for: .normal)
        skipBtn.addTarget(self, action: #selector(skipButtonTapped), for: .touchUpInside)
        self.view.addSubview(skipBtn)
        skipBtn.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide).offset(20)
            make.right.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.height.equalTo(30)
        }
        
        closeBtn.isHidden = true
        closeBtn.setAttributedTitle(underlineAttributedString, for: .normal)
        closeBtn.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.center.size.equalTo(skipBtn)
        }
        
        let gradientView = UIView()
        self.view.addSubview(gradientView)
        gradientView.snp.makeConstraints { (make) in
            make.centerY.equalTo(backgroundImages.snp.bottom)
            make.centerX.left.equalToSuperview()
            make.height.equalTo(63)
        }
        
        self.view.layoutIfNeeded()
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = gradientView.bounds
        gradientLayer.locations = [0, 1.0]
        gradientView.layer.addSublayer(gradientLayer)
        
        backBtn.setBackgroundImage(UIImage.init(named: "back_white_btn"), for: .normal)
        backBtn.addTarget(self, action: #selector(backButtonTapped), for: .touchUpInside)
        self.view.addSubview(backBtn)
        backBtn.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.top.equalToSuperview().offset(35)
            make.height.width.equalTo(30)
        }
        
        monthView.layer.cornerRadius = 10
        monthView.layer.borderColor = UIColor.init(red: 161 / 255.0, green: 161 / 255.0, blue: 161 / 255.0, alpha: 1).cgColor
        monthView.backgroundColor = UIColor.init(red: 161 / 255.0, green: 161 / 255.0, blue: 161 / 255.0, alpha: 1)
        monthView.layer.borderWidth = 2.5
        self.view.addSubview(monthView)
        monthView.snp.makeConstraints { (make) in
            make.height.equalTo(138)
            make.width.equalTo(138)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-90)
            make.right.equalTo(self.view.snp.centerX).offset(-10)
        }
        
        monthIcon.image = UIImage.init(named: "checkIAP_icon")
        monthIcon.clipsToBounds = true
        monthIcon.contentMode = .scaleAspectFit
        monthIcon.isHidden = true
        monthView.addSubview(monthIcon)
        monthIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(18)
        }
        
        monthNameLabel.text = NSLocalizedString("kInAppPurchaseMonthTitle", comment: "")
        monthNameLabel.font = setFontSize(size: 10, weight: .semibold)
        monthNameLabel.textColor = UIColor.init(hexString: "2d00ff")!
        monthNameLabel.textAlignment = .center
        monthView.addSubview(monthNameLabel)
        monthNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(monthIcon.snp.bottom).offset(1)
            make.centerX.equalToSuperview()
            make.height.equalTo(13)
        }
        
        monthPriceLabel.text = "$0.00"
        monthPriceLabel.font = setFontSize(size: 28, weight: .bold)
        monthPriceLabel.textColor = UIColor.init(hexString: "2d00ff")!
        monthPriceLabel.textAlignment = .center
        monthView.addSubview(monthPriceLabel)
        monthPriceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(55.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }

        let monthLabel = UILabel()
        monthLabel.text = NSLocalizedString("kIAPMonthlyPriceTitle", comment: "")
        monthLabel.font = setFontSize(size: 13, weight: .regular)
        monthLabel.textColor = UIColor.init(hexString: "2d00ff")!
        monthLabel.textAlignment = .center
        monthView.addSubview(monthLabel)
        monthLabel.snp.makeConstraints { (make) in
            make.top.equalTo(monthPriceLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.height.equalTo(13)
        }
        
        let attributedIncludeStr = NSMutableAttributedString(string: NSLocalizedString("kInclude14DayFree", comment: ""), attributes: [
          .font: setFontSize(size: 11, weight: .semibold),
          .foregroundColor: UIColor.white
        ])
        attributedIncludeStr.addAttribute(.font, value: setFontSize(size: 13.44, weight: .regular), range: NSRange(location: 0, length: 7))
        
        let monthlyIncludeLabel = UILabel()
        monthlyIncludeLabel.isHidden = true
        monthlyIncludeLabel.attributedText = attributedIncludeStr
        monthView.addSubview(monthlyIncludeLabel)
        monthlyIncludeLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8.5)
            make.height.equalTo(12)
            make.centerX.equalToSuperview()
        }
        
        yearView.layer.cornerRadius = 10
        yearView.layer.borderColor = UIColor.init(hexString: "2d00ff")!.cgColor
        yearView.layer.borderWidth = 2.5
        yearView.backgroundColor = UIColor.white
        self.view.addSubview(yearView)
        yearView.snp.makeConstraints { (make) in
            make.height.equalTo(138)
            make.width.equalTo(138)
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-90)
            make.left.equalTo(monthView.snp.right).offset(20)
        }
        
        yearIcon.image = UIImage.init(named: "checkIAP_icon")
        yearIcon.clipsToBounds = true
        yearIcon.contentMode = .scaleAspectFit
        yearIcon.isHidden = false
        yearView.addSubview(yearIcon)
        yearIcon.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(8)
            make.left.equalToSuperview().offset(8)
            make.width.height.equalTo(18)
        }
        
        yearNameLabel.text = NSLocalizedString("kInAppPurchaseYearTitle", comment: "")
        yearNameLabel.font = setFontSize(size: 10, weight: .semibold)
        yearNameLabel.textColor = UIColor.init(hexString: "2d00ff")!
        yearNameLabel.textAlignment = .center
        yearView.addSubview(yearNameLabel)
        yearNameLabel.snp.makeConstraints { (make) in
            make.top.equalTo(yearIcon.snp.bottom).offset(1)
            make.centerX.equalToSuperview()
            make.height.equalTo(13)
        }
        
        let attributedString = NSMutableAttributedString(string: "Save OVER 10%!", attributes: [
            .font: setFontSize(size: 10, weight: .regular),
            .foregroundColor: UIColor(red: 1.0, green: 85.0 / 255.0, blue: 85.0 / 255.0, alpha: 1.0)
        ])
        attributedString.addAttribute(.font, value: setFontSize(size: 10, weight: .semibold), range: NSRange(location: 10, length: 3))
        
//        let savingLabel = UILabel()
//        savingLabel.attributedText = attributedString
//        savingLabel.isHidden = true
//        yearView.addSubview(savingLabel)
//        savingLabel.snp.makeConstraints { (make) in
//            make.top.equalToSuperview().offset(41.5)
//            make.centerX.equalToSuperview()
//        }

        yearPriceLabel.text = "$0.00"
        yearPriceLabel.font = setFontSize(size: 28, weight: .bold)
        yearPriceLabel.textColor = UIColor.init(hexString: "2d00ff")!
        yearPriceLabel.textAlignment = .center
        yearView.addSubview(yearPriceLabel)
        yearPriceLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(55.5)
            make.centerX.equalToSuperview()
            make.height.equalTo(28)
        }
        
        let yearLabel = UILabel()
        yearLabel.text = NSLocalizedString("kIAPYearlyPriceTitle", comment: "")
        yearLabel.font = setFontSize(size: 13, weight: .regular)
        yearLabel.textColor = UIColor.init(hexString: "2d00ff")!
        yearLabel.textAlignment = .center
        yearView.addSubview(yearLabel)
        yearLabel.snp.makeConstraints { (make) in
            make.top.equalTo(monthPriceLabel.snp.bottom).offset(2)
            make.centerX.equalToSuperview()
            make.height.equalTo(13)
        }
        
        let yearlyIncludeLabel = UILabel()
        yearlyIncludeLabel.attributedText = attributedString
        yearView.addSubview(yearlyIncludeLabel)
        yearlyIncludeLabel.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-8.5)
            make.height.equalTo(12)
            make.centerX.equalToSuperview()
        }
        
        let monthPaymentTap = UITapGestureRecognizer.init(target: self, action: #selector(monthPayment))
        monthView.addGestureRecognizer(monthPaymentTap)
        
        let yearPaymentTap = UITapGestureRecognizer.init(target: self, action: #selector(yearPayment))
        yearView.addGestureRecognizer(yearPaymentTap)
        
        messageReviewTitle.text = NSLocalizedString("kInAppPurchaseTitle", comment: "")
        messageReviewTitle.font = setFontSize(size: 24, weight: .bold)//HurmeGeometricSans2
        messageReviewTitle.textAlignment = .center
        messageReviewTitle.numberOfLines = 0
        messageReviewTitle.textColor = .white
        self.view.addSubview(messageReviewTitle)
        messageReviewTitle.snp.makeConstraints { (make) in
            make.bottom.equalTo(monthView.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        payPopup.backgroundColor = UIColor.init(hexString: "2d00ff")
        payPopup.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        payPopup.layer.cornerRadius = 30
        self.view.addSubview(payPopup)
        payPopup.snp.makeConstraints { (make) in
            make.height.equalTo(333)
            make.left.right.equalToSuperview()
            make.top.equalTo(self.view.snp.bottom)
        }
        
        let popUpTitle = UILabel()
        popUpTitle.text = NSLocalizedString("kChosenPlanTitle", comment: "")
        popUpTitle.font = setFontSize(size: 18, weight: .bold)//HurmeGeometricSans2
        popUpTitle.textColor = UIColor.white
        popUpTitle.textAlignment = .center
        payPopup.addSubview(popUpTitle)
        popUpTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(50)
            make.centerX.equalToSuperview()
        }
        
        let freeTrialLabel = UILabel()
        freeTrialLabel.text = "Free 14-Day Trial"
        freeTrialLabel.font = setFontSize(size: 14, weight: .regular)
        freeTrialLabel.textColor = .white
        freeTrialLabel.textAlignment = .center
        payPopup.addSubview(freeTrialLabel)
        freeTrialLabel.snp.makeConstraints { (make) in
            make.top.equalTo(popUpTitle.snp.bottom).offset(49)
            make.centerX.equalToSuperview()
        }
        
        selectedPackageLabel.text = "$0"
        selectedPackageLabel.textColor = UIColor.init(hexString: "0fd7ff")
        selectedPackageLabel.font = setFontSize(size: 50.4, weight: .bold)
        selectedPackageLabel.textAlignment = .center
        payPopup.addSubview(selectedPackageLabel)
        selectedPackageLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(143)
            make.centerX.equalToSuperview()
        }
        
        perRank.text = "/year"
        perRank.textColor = UIColor.init(hexString: "0fd7ff")
        perRank.font = setFontSize(size: 23, weight: .regular)
        perRank.textAlignment = .center
        payPopup.addSubview(perRank)
        perRank.snp.makeConstraints { (make) in
            make.top.equalTo(selectedPackageLabel.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
        }
        
        payBtn.backgroundColor = .white
        payBtn.setTitle(NSLocalizedString("kPayBtn", comment: ""), for: .normal)
        payBtn.setTitleColor(UIColor.init(hexString: "2d00ff")!, for: .normal)
        payBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        payBtn.layer.cornerRadius = 20
        payBtn.addTarget(self, action: #selector(payButtonTapped), for: .touchUpInside)
        payPopup.addSubview(payBtn)
        payBtn.snp.makeConstraints { (make) in
            make.bottom.equalToSuperview().offset(-50)
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(40)
            make.centerX.equalToSuperview()
        }
        
        resendBtn.setTitle(NSLocalizedString("kRestorePurchaseBtn", comment: ""), for: .normal)
        resendBtn.titleLabel?.font = setFontSize(size: 12, weight: .regular)
        resendBtn.setTitleColor(UIColor.init(hexString: "0fd7ff"), for: .normal)
        resendBtn.addTarget(self, action: #selector(didRetorePurchaseButtonTapped), for: .touchUpInside)
        self.view.addSubview(resendBtn)
        resendBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-72)
            make.centerX.equalToSuperview()
            make.height.equalTo(16)
        }
        
        resendLine.backgroundColor = UIColor.init(hexString: "0fd7ff")
        self.view.addSubview(resendLine)
        resendLine.snp.makeConstraints { (make) in
            make.width.bottom.equalTo(resendBtn)
            make.centerX.equalToSuperview()
            make.height.equalTo(1)
        }
        
        policyTitle.setTitleColor(.white, for: .normal)
        policyTitle.setTitle("Virtual Mobility Coach App for Free", for: .normal)
        policyTitle.addTarget(self, action: #selector(didPolicyButtonTapped), for: .touchUpInside)
        self.view.addSubview(policyTitle)
        policyTitle.snp.makeConstraints { (make) in
            make.top.equalTo(resendLine).offset(20)
            make.height.equalTo(20)
            make.centerX.equalToSuperview()
        }
        
        policyBtn.addTarget(self, action: #selector(didPolicyButtonTapped), for: .touchUpInside)
        policyBtn.setImage(UIImage.init(named: "down_IAP_icon"), for: .normal)
        self.view.addSubview(policyBtn)
        policyBtn.snp.makeConstraints { (make) in
            make.top.equalTo(policyTitle).offset(35)
            make.centerX.equalToSuperview()
        }
        
        self.view.addSubview(policyView)
        policyView.snp.makeConstraints { (make) in
            make.top.equalTo(policyBtn).offset(25)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-32)
            make.height.equalTo(0)
        }
        
        policyDesc.text = NSLocalizedString("kInAppDescMessage", comment: "")
        policyDesc.numberOfLines = 0
        policyDesc.textAlignment = .center
        policyDesc.textColor = .white
        self.policyView.addSubview(policyDesc)
        policyDesc.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
        }
        
        termsBtn.setTitle(NSLocalizedString("kInAppTermsServiceBtn", comment: ""), for: .normal)
        termsBtn.addTarget(self, action: #selector(didPolicyLink), for: .touchUpInside)
        termsBtn.setTitleColor(UIColor.init(hexString: "0fd7ff"), for: .normal)
        self.policyView.addSubview(termsBtn)
        termsBtn.snp.makeConstraints { (make) in
            make.top.equalTo(policyDesc.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        privacyBtn.setTitle(NSLocalizedString("kInAppPrivacyPolicyBtn", comment: ""), for: .normal)
        privacyBtn.addTarget(self, action: #selector(didPolicyLink), for: .touchUpInside)
        privacyBtn.setTitleColor(UIColor.init(hexString: "0fd7ff"), for: .normal)
        self.policyView.addSubview(privacyBtn)
        privacyBtn.snp.makeConstraints { (make) in
            make.top.equalTo(termsBtn.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.height.equalTo(30)
        }
        
        policyDesc.isHidden = true
        termsBtn.isHidden = true
        privacyBtn.isHidden = true
        
        let singleTouch = UITapGestureRecognizer.init(target: self, action: #selector(screenTapped))
        self.view.addGestureRecognizer(singleTouch)
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: true)
        
        let userDefault = UserDefaults.standard
        
        if let _ = userDefault.object(forKey: kUserPendingReceipt) as? String {
            resendBtn.isHidden = false
            let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipInAppTitle", comment: ""),
                                                 message: NSLocalizedString("kUserInAppPurchasePendingMessage", comment: ""),
                                                 preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kSkipBtn", comment: ""),
                                                  style: .cancel) { (action) in
                alertVC.dismiss(animated: true, completion: nil)
                self.skipButtonTapped()
            }
            let okAction = UIAlertAction.init(title: NSLocalizedString("kResumeAction", comment: ""),
                                              style: .default) { (action) in
                alertVC.dismiss(animated: true, completion: nil)
                self.didRetorePurchaseButtonTapped()
            }
            
            alertVC.addAction(cancelAction)
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
}
    
    //MARK: - Functions
    @objc private func didPolicyLink(sender: UIButton) {
        let appPolicyVC = VC_AppPrivacyPolicy()
        if presentingType == .presenting {
            appPolicyVC.isPresenting = true
            self.present(appPolicyVC, animated: true, completion: nil)
        } else {
            self.navigationController?.pushViewController(appPolicyVC, animated: true)
        }
    }
    
    @objc private func didPolicyButtonTapped(sender: UIButton) {
        policyDesc.isHidden = true
        termsBtn.isHidden = true
        privacyBtn.isHidden = true
        
        if sender.isSelected {
            print("selected")
            policyBtn.isSelected = false
            policyTitle.isSelected = false
            
            monthView.snp.remakeConstraints { (make) in
                make.height.equalTo(138)
                make.width.equalTo(138)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-90)
                make.right.equalTo(self.view.snp.centerX).offset(-10)
            }
            
            yearView.snp.remakeConstraints { (make) in
                make.height.equalTo(138)
                make.width.equalTo(138)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-90)
                make.left.equalTo(monthView.snp.right).offset(20)
            }
            
            resendBtn.snp.remakeConstraints { (make) in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-72)
                make.centerX.equalToSuperview()
                make.height.equalTo(16)
            }
            
            resendLine.snp.remakeConstraints { (make) in
                make.width.bottom.equalTo(resendBtn)
                make.centerX.equalToSuperview()
                make.height.equalTo(1)
            }
            
            policyTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(resendLine).offset(20)
                make.centerX.equalToSuperview()
            }
            
            policyBtn.setImage(UIImage.init(named: "down_IAP_icon"), for: .normal)
            policyBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(policyTitle).offset(35)
                make.centerX.equalToSuperview()
            }
            
            policyView.snp.remakeConstraints { (make) in
                make.top.equalTo(policyBtn).offset(25)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-32)
                make.height.equalTo(0)
            }
            
        } else {
            policyBtn.isSelected = true
            policyTitle.isSelected = true
            monthView.snp.remakeConstraints { (make) in
                make.height.equalTo(138)
                make.width.equalTo(138)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-300)
                make.right.equalTo(self.view.snp.centerX).offset(-10)
            }
            
            yearView.snp.remakeConstraints { (make) in
                make.height.equalTo(138)
                make.width.equalTo(138)
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-300)
                make.left.equalTo(monthView.snp.right).offset(20)
            }
            
            resendBtn.snp.remakeConstraints { (make) in
                make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-280)
                make.centerX.equalToSuperview()
                make.height.equalTo(16)
            }
            
            resendLine.snp.remakeConstraints { (make) in
                make.width.bottom.equalTo(resendBtn)
                make.centerX.equalToSuperview()
                make.height.equalTo(1)
            }
            
            policyTitle.snp.remakeConstraints { (make) in
                make.top.equalTo(resendLine).offset(20)
                make.centerX.equalToSuperview()
            }
            
            policyBtn.setImage(UIImage.init(named: "up_IAP_icon"), for: .normal)
            policyBtn.snp.remakeConstraints { (make) in
                make.top.equalTo(policyTitle).offset(35)
                make.centerX.equalToSuperview()
                make.height.equalTo(20)
                make.width.equalTo(120)
            }
            
            policyView.snp.remakeConstraints { (make) in
                make.top.equalTo(policyBtn).offset(20)
                make.centerX.equalToSuperview()
                make.width.equalToSuperview().offset(-32)
                make.height.equalTo(200)
            }
            
            policyDesc.isHidden = false
            termsBtn.isHidden = false
            privacyBtn.isHidden = false
        }
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func screenTapped() {
        self.payPopup.snp.remakeConstraints { (remake) in
            remake.height.equalTo(333)
            remake.left.right.equalToSuperview()
            remake.top.equalTo(self.view.snp.bottom)
        }
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func skipButtonTapped() {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kSkipInAppTitle", comment: ""),
                                             message: NSLocalizedString("kSkipInAppWarningMessage", comment: ""),
                                             preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
        }
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                          style: .default) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
                                            self.dismiss(animated: true, completion: nil)
                                            _NavController.setViewControllers([MainPageTabbar()], animated: true)
        }
        
        alertVC.addAction(cancelAction)
        alertVC.addAction(okAction)
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func cancelButtonTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - UI
    
    func reloadData() {
        
        _AppDataHandler.sendLog(apiName: "DEBUG point VC_InAppPurchase - 416: ", log: "reloadData")
        
        _AppPaymentManager.updateUserTransaction { (userStatus) in
            self.userStatus = userStatus
            _AppDataHandler.sendLog(apiName: "DEBUG point VC_InAppPurchase - 416: updateUserTransaction", log: self.userStatus.rawValue)
            
            switch self.userStatus {
            case .userReactive, .myUserInclude :
                self.messageReviewTitle.text = NSLocalizedString("kInAppPurchaseRenewTitle", comment: "")
            default:
                if _AppDataHandler.getUserProfile().userPlanPlatform == .android  || _AppDataHandler.getUserProfile().userPlanPlatform == .web  {
                    self.messageReviewTitle.text = NSLocalizedString("kInAppPurchaseNonTrialTitle", comment: "")
                } else {
                    self.messageReviewTitle.text = NSLocalizedString("kInAppPurchaseTitle", comment: "")
                }
            }
        }
        
        if self.presentingType == .presenting {
            self.backBtn.isHidden = true
            self.skipBtn.isHidden = true
            self.closeBtn.isHidden = false
        }
        
        self.loadingAnimation.isHidden = false
        
        let listProducts = _AppPaymentManager.listProduct
        
        for productData in listProducts {
            if productData.billingPeriod == "month" {
                
                _AppPaymentManager.getProductData(product: productData)
                { (isSuccess, error, skProduct) in
                    
                    self.processLoadingAnimation()
                    if isSuccess {
                        self.monthProduct = skProduct
                        let priceString = skProduct?.localizedPrice ?? ""
                        self.monthPriceLabel.text = priceString
                        self.monthNameLabel.text = skProduct?.localizedTitle
                        print("Product: \(String(describing: skProduct?.localizedDescription)), price: \(priceString)")
                    } else {
                        print("Error: \(error)")
                    }
                }
                
            } else if productData.billingPeriod == "year" {
                
                _AppPaymentManager.getProductData(product: productData)
                { (isSuccess, error, skProduct) in
                    
                    self.processLoadingAnimation()
                    if isSuccess {
                        self.yearProduct = skProduct
                        let priceString = skProduct?.localizedPrice ?? ""
                        self.yearPriceLabel.text = priceString
                        self.yearNameLabel.text = skProduct?.localizedTitle
                        print("Product: \(String(describing: skProduct?.localizedDescription)), price: \(priceString)")
                    } else {
                        print("Error: \(error)")
                    }
                }
            }
        }
    }
    
    func processLoadingAnimation() {
        
        self.loadingAnimationCount += 1
        if self.loadingAnimationCount == 2 {
            self.loadingAnimation.isHidden = true
            return
        }
    }
    
    //MARK:- Button
    @objc func monthPayment() {
        
        yearIcon.isHidden = true
        monthIcon.isHidden = false
        
        yearView.layer.borderColor = UIColor.init(red: 161 / 255.0, green: 161 / 255.0, blue: 161 / 255.0, alpha: 1).cgColor
        yearView.backgroundColor = UIColor.init(red: 161 / 255.0, green: 161 / 255.0, blue: 161 / 255.0, alpha: 1)
        monthView.layer.borderColor = UIColor.init(hexString: "2d00ff")!.cgColor
        monthView.backgroundColor = UIColor.white
        
        selectedProduct = .month
        
        self.payPopup.snp.remakeConstraints { (remake) in
            remake.bottom.left.right.equalToSuperview()
            remake.height.equalTo(333)
        }
        
        self.view.bringSubviewToFront(payPopup)
        self.selectedPackageLabel.text = monthProduct?.localizedPrice
        self.perRank.text = NSLocalizedString("kIAPMonthlyPriceTitle", comment: "")
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)        
    }
    
    @objc func yearPayment() {
        
        yearIcon.isHidden = false
        monthIcon.isHidden = true
        
        yearView.layer.borderColor = UIColor.init(hexString: "2d00ff")!.cgColor
        yearView.backgroundColor = UIColor.white
        
        monthView.layer.borderColor = UIColor.init(red: 161 / 255.0, green: 161 / 255.0, blue: 161 / 255.0, alpha: 1).cgColor
        monthView.backgroundColor = UIColor.init(red: 161 / 255.0, green: 161 / 255.0, blue: 161 / 255.0, alpha: 1)
        
        selectedProduct = .year
        
        self.payPopup.snp.remakeConstraints { (remake) in
            remake.bottom.left.right.equalToSuperview()
            remake.height.equalTo(333)
        }
        self.view.bringSubviewToFront(payPopup)
        self.selectedPackageLabel.text = yearProduct?.localizedPrice
        self.perRank.text = NSLocalizedString("kIAPYearlyPriceTitle", comment: "")
        
        UIView.animate(withDuration: 0.5,
                       delay: 0,
                       usingSpringWithDamping: 0.5,
                       initialSpringVelocity: 0.1,
                       options: .curveEaseIn, animations: {
                        self.view.layoutIfNeeded()
        }, completion: nil)
    }
    
    @objc func payButtonTapped() {
        
        self.screenTapped()
        _AppDataHandler.sendLog(apiName: "DEBUG point VC_InAppPurchase - 524: payButtonTapped", log: self.userStatus.rawValue)

        switch self.userStatus {
        case .notMyuser:
            bfprint(String(format:"IAP - payButtonTapped: %@", "notMyuser"), tag: "IAP", level: .default)

            let alertVC = UIAlertController.init(title: NSLocalizedString("kSubscriptionTitle", comment: ""),
                                                 message: NSLocalizedString("kSubscriptionNotMyUserMessage", comment: ""),
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            break
        case .userReactive:
            bfprint(String(format:"IAP - payButtonTapped: %@", "userReactive"), tag: "IAP", level: .default)

            let alertVC = UIAlertController.init(title: NSLocalizedString("kSubscriptionTitle", comment: ""),
                                                 message: NSLocalizedString("kSubscriptionMyUserReactiveMessage", comment: ""),
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                self.processPayment()
            }
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
            break
        case .myUserInclude:
            bfprint(String(format:"IAP - payButtonTapped: %@", "myUserInclude"), tag: "IAP", level: .default)
            let alertVC = UIAlertController.init(title: NSLocalizedString("kSubscriptionTitle", comment: ""),
                                                 message: NSLocalizedString("kSubscriptionMyUserIncludeMessage", comment: ""),
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kSubscriptionContinueBtn", comment: ""),
                                              style: .default) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                self.processPayment()
            }
            
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
            break
        case .brandNewAppleID :
            bfprint(String(format:"IAP - payButtonTapped: %@", "brandNewAppleID"), tag: "IAP", level: .default)
            let alertVC = UIAlertController.init(title: NSLocalizedString("kSubscriptionTitle", comment: ""),
                                                 message: NSLocalizedString("kSubscriptionBrandNewAppleMessage", comment: ""),
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                              style: .default) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                self.processPayment()
            }
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
            break
        default:
            bfprint(String(format:"IAP - payButtonTapped: %@", "processPayment"), tag: "IAP", level: .default)
            self.processPayment()
            break
        }
    }
    
    func processPayment() {
        self.loadingAnimation.isHidden = false
        
        if selectedProduct == .month {
            
            bfprint(String(format:"IAP: %@", "selectedProduct.month"), tag: "IAP", level: .default)
            
            guard let product = self.monthProduct else {
                self.dismiss(animated: true, completion: nil)
                _NavController.presentAlertForCase(title: NSLocalizedString("kSubscriptionTitle", comment: ""), message: NSLocalizedString("kSubscriptionMissForMonthMessage", comment: ""))
                self.loadingAnimation.isHidden = true
                return
            }
            
            _AppPaymentManager.purchaseProduct(product: product)
            { (isSuccess, error) in
                if isSuccess {
                    self.loadingAnimation.isHidden = true
                    if self.presentingType == .presenting {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let homeVC = MainPageTabbar()
                        _NavController.setViewControllers([homeVC], animated: true)
                    }
                } else {
                    self.loadingAnimation.isHidden = true
                    bfprint(String(format:"IAP - selectedProduct.month - error: %@", error), tag: "IAP", level: .default)
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSubscriptionTitle", comment: ""), message: error)
                }
            }
        }
        else {
            
            bfprint(String(format:"IAP: %@", "selectedProduct.year"), tag: "IAP", level: .default)
            
            guard let product = self.yearProduct else {
                self.loadingAnimation.isHidden = true
                self.dismiss(animated: true, completion: nil)
                _NavController.presentAlertForCase(title: NSLocalizedString("kSubscriptionTitle", comment: ""), message: NSLocalizedString("kSubscriptionMissForYearMessage", comment: ""))
                return
            }
            
            _AppPaymentManager.purchaseProduct(product: product)
            { (isSuccess, error) in
                if isSuccess {
                    self.loadingAnimation.isHidden = true
                    if self.presentingType == .presenting {
                        self.dismiss(animated: true, completion: nil)
                    } else {
                        let homeVC = MainPageTabbar()
                        _NavController.setViewControllers([homeVC], animated: true)
                    }
                } else {
                    self.loadingAnimation.isHidden = true
                    bfprint(String(format:"IAP - selectedProduct.year - error: %@", error), tag: "IAP", level: .default)
                    _NavController.presentAlertForCase(title: NSLocalizedString("kSubscriptionTitle", comment: ""), message: error)
                }
            }
        }
    }
    
    
    
    @objc func didRetorePurchaseButtonTapped() {
        
        self.loadingAnimation.isHidden = false
        _AppPaymentManager.restorePurchaseAction { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                if self.presentingType == .presenting {
                    self.dismiss(animated: true, completion: nil)
                    self.navigationController?.dismiss(animated: true, completion: nil)
                } else {
                    let homeVC = MainPageTabbar()
                    _NavController.setViewControllers([homeVC], animated: true)
                }
            } else {
                
                bfprint(String(format:"IAP - didRetorePurchaseButtonTapped: %@", error), tag: "IAP", level: .default)
                _NavController.presentAlertForCase(title: NSLocalizedString("kSubscriptionTitle", comment: ""),
                                                   message: error)
            }
        }
    }
}
