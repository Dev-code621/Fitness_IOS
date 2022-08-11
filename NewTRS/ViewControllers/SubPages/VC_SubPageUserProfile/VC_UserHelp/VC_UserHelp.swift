//
//  VC_UserHelp.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/17/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import WebKit

class VC_UserHelp: UIViewController, WKNavigationDelegate {
    
    let loadingAnimation    = VW_LoadingAnimation()
    let webView             = WKWebView()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let bannerImage = UIImageView()
        bannerImage.image = UIImage.init(named: "help_banner")
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.685)
        }
        
        let opacityView = UIView()
        opacityView.layer.opacity = 0.2
        self.view.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalTo(bannerImage)
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
        
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        webView.snp.makeConstraints { (make) in
            make.top.equalTo(bannerImage.snp.bottom).offset(16)
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        loadingAnimation.isHidden = false
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
    }
    
    //MARK: - Buttons
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    //MARK: - Data
    func reloadData() {
        
        let url = URL(string: kBaseURLHelp)!
        webView.load(URLRequest(url: url))
        webView.allowsBackForwardNavigationGestures = true
        
//        self.loadingAnimation.isHidden = false
//        _AppDataHandler.getUserHelp { (isSuccess, error, htmlString) in
//            
//            self.loadingAnimation.isHidden = true
//            if isSuccess {
//                self.webView.loadHTMLString(htmlString, baseURL: nil)
//            } else {
//                let alertVC = _NavController.getAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
//                                                             message: error)
//                self.present(alertVC, animated: true, completion: nil)
//                return
//            }
//        }
    }
    
    //MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loadingAnimation.isHidden = true
    }
}
