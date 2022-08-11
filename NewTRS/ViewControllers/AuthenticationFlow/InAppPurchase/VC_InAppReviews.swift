//
//  VC_InAppReviews.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_InAppReviews: UIViewController,
                        UIScrollViewDelegate {

    let headerLayout    = UIView()
    
    let reviewSlider    = UIScrollView()
    let pageControl     = UIPageControl()
    let learnMoreBtn    = UIButton()
    let startTrialBtn   = UIButton()
    
    let loadingAnimation    = VW_LoadingAnimation()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")

        let bannerImage = UIImageView()
        bannerImage.image = UIImage.init(named: "head_banner")
        bannerImage.layer.cornerRadius = 30
        bannerImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.432)
        }
        
        headerLayout.backgroundColor = UIColor.init(hexString: "ccffffff")
        headerLayout.layer.cornerRadius = 20
        headerLayout.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        headerLayout.layer.shadowOpacity = 0.5
        headerLayout.layer.shadowOffset = CGSize(width: 2, height: 9)
        headerLayout.layer.shadowRadius = 20
        self.view.addSubview(headerLayout)
        headerLayout.snp.makeConstraints { (make) in
            make.bottom.equalTo(bannerImage).offset(50)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-30)
            make.height.equalTo(185)
        }
        
        let titleLabel = UILabel()
        titleLabel.textAlignment = .center
        titleLabel.text = NSLocalizedString("kReviewTitle", comment: "")
        titleLabel.font = setFontSize(size: 22, weight: .bold)
        titleLabel.textColor = UIColor.init(hexString: "1400b3")
        headerLayout.addSubview(titleLabel)
        titleLabel.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(40)
            make.centerX.equalToSuperview()
            make.height.equalTo(18)
        }
        
        let attributes = [NSAttributedString.Key.font: setFontSize(size: 14, weight: .regular),
                          NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "1400b3")!]
        let qouteStr = NSMutableAttributedString.init(string: NSLocalizedString("kQuoteReviews", comment: ""), attributes: attributes)

        qouteStr.addAttribute(NSAttributedString.Key.font, value: setFontSize(size: 14, weight: .regular), range: NSRange(location: 0, length: qouteStr.length))
     //   qouteStr.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.init(hexString: "1400b3")!, range: NSRange(location: 0, length: qouteStr.length))

        qouteStr.addAttribute(NSAttributedString.Key.font, value: setFontSize(size: 14, weight: .semibold), range: NSRange(location: 0, length: 36))
        qouteStr.addAttribute(NSAttributedString.Key.font, value: setFontSize(size: 11, weight: .semibold), range: NSRange(location: 115, length: 25))
//        let paragraphStyle = NSMutableParagraphStyle()
//        paragraphStyle.lineSpacing = 8
//        paragraphStyle.alignment = NSTextAlignment.center
//        qouteStr.addAttribute(NSAttributedString.Key.paragraphStyle, value:paragraphStyle, range: NSMakeRange(0, qouteStr.length))
        
        let qouteLabel = UILabel()
        qouteLabel.numberOfLines = 0
        qouteLabel.textAlignment = .center
        qouteLabel.attributedText = qouteStr
      //  qouteLabel.font = setFontSize(size: 16, weight: .semibold)
        headerLayout.addSubview(qouteLabel)
        qouteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(titleLabel.snp.bottom).offset(18)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
        }
        
        startTrialBtn.setTitle(NSLocalizedString("kTrialBtn", comment: "").uppercased(), for: .normal)
        startTrialBtn.setTitleColor(.white, for: .normal)
        startTrialBtn.titleLabel?.font = setFontSize(size: 16, weight: .semibold)
        startTrialBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
        startTrialBtn.layer.cornerRadius = 20
        startTrialBtn.addTarget(self, action: #selector(startTrialButtonTapped), for: .touchUpInside)
        self.view.addSubview(startTrialBtn)
        startTrialBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        learnMoreBtn.setTitle(NSLocalizedString("kChooseFreemiumBtn", comment: ""), for: .normal)
        learnMoreBtn.setTitleColor(UIColor.init(hexString: "2d02ff"), for: .normal)
        learnMoreBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        learnMoreBtn.backgroundColor = .white
        learnMoreBtn.layer.cornerRadius = 20
        learnMoreBtn.layer.borderWidth = 0.5
        learnMoreBtn.layer.borderColor = UIColor.init(hexString: "1d02ff")!.cgColor
        learnMoreBtn.addTarget(self, action: #selector(learnMoreButtonTapped), for: .touchUpInside)
        self.view.addSubview(learnMoreBtn)
        learnMoreBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(startTrialBtn.snp.top).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        reviewSlider.delegate = self
        reviewSlider.isPagingEnabled = true
        reviewSlider.showsHorizontalScrollIndicator = false
        self.view.addSubview(reviewSlider)
        reviewSlider.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.top.equalTo(headerLayout.snp.bottom)
            make.bottom.equalTo(learnMoreBtn.snp.top)
            make.width.equalToSuperview().offset(-40)
        }
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = 5
        pageControl.pageIndicatorTintColor = UIColor.init(hexString: "d8d8d8")
        pageControl.currentPageIndicatorTintColor = UIColor.init(hexString: "1d00ff")
        self.view.addSubview(pageControl)
        pageControl.snp.makeConstraints { (make) in
            make.bottom.equalTo(learnMoreBtn.snp.top).offset(-6)
            make.centerX.equalToSuperview()
        }
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        _AppPaymentManager.configPayment()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = headerLayout.bounds
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        headerLayout.addSubview(blurEffectView)
        
        headerLayout.sendSubviewToBack(blurEffectView)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Data
    
    func reloadData() {
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getAppReview { (isSuccess, error, listReviews) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.reloadSlider(listReview: listReviews)
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
                                                   message: error)
                return
            }
        }
    }
    
    func reloadSlider(listReview: [ReviewDataSource]) {
        
        pageControl.currentPage = 0
        pageControl.numberOfPages = listReview.count
        
        let size    = reviewSlider.frame.size
        var index   = 0
        
        for reviewData in listReview {
            
            let frame = CGRect.init(x: CGFloat(index)*size.width, y: 0, width: size.width, height: size.height)
            
            let reviewContent = VW_ReviewContent.init(frame: frame)
            reviewContent.setReviewData(reviewData)
            reviewSlider.addSubview(reviewContent)
            
            index += 1
        }
        
        reviewSlider.contentSize = CGSize.init(width: CGFloat(index)*size.width, height: size.height)
    }
    
    //MARK: - Functions
    
    @objc func learnMoreButtonTapped() {
        let homeVC = MainPageTabbar()
        _NavController.setViewControllers([homeVC], animated: true)
    }
    
    @objc func startTrialButtonTapped() {
        let iapVC = VC_InAppPurchase()
        self.navigationController?.pushViewController(iapVC, animated: true)
    }
    
    //MARK: - UIScrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let pageWidth = reviewSlider.frame.size.width
        let fractionalPage = reviewSlider.contentOffset.x / pageWidth
        
        let page = lroundf(Float(fractionalPage))
        self.pageControl.currentPage = page
    }
}
