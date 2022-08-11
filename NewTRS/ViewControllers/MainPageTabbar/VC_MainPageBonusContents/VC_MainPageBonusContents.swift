//
//  VC_MainPageCollection.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageBonusContents: UIViewController,
                                UITableViewDataSource, UITableViewDelegate {
    
    let tableView           = UITableView(frame: .zero, style: .grouped)

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let userProfileBtn = UIBarButtonItem.init(image: UIImage.init(named: "user_profile_icon"),
                                            style: .plain,
                                            target: self,
                                            action: #selector(userProfileButtonTapped))
        let userActitvityBtn = UIBarButtonItem.init(image: UIImage.init(named: "user_activity_icon"),
                                                   style: .plain,
                                                   target: self,
                                                   action: #selector(userActivityButtonTapped))
        let userFavoriteBtn = UIBarButtonItem.init(image: UIImage.init(named: "user_favorite_icon"),
                                                    style: .plain,
                                                    target: self,
                                                    action: #selector(userFavoriteButtonTapped))
        let homeBtn = UIBarButtonItem.init(image: UIImage.init(named: "home_icon"),
                                           style: .plain,
                                           target: self,
                                           action: #selector(homeButtonTapped))
        self.navigationItem.leftBarButtonItem = homeBtn
        self.navigationItem.rightBarButtonItems = [userFavoriteBtn, userActitvityBtn, userProfileBtn]
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(TC_BonusContentCell.self, forCellReuseIdentifier: "bonusCell")
        tableView.backgroundColor = .white
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.safeAreaLayoutGuide.snp.top)
            make.centerX.bottom.width.equalToSuperview()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        _NavController.setNavigationBarHidden(true, animated: false)
    }
    
    //MARK: - Function
    @objc func homeButtonTapped() {
        let homeNav = UINavigationController(rootViewController: VC_MainPageHome())
        _NavController.present(homeNav, animated: true, completion: nil)
    }
    
    @objc func userProfileButtonTapped() {
        let userProfileVC = VC_SubPageUserProfile()
        let userProfileNavigation = UINavigationController.init(rootViewController: userProfileVC)
        userProfileNavigation.setNavigationBarHidden(true, animated: false)
        _NavController.present(userProfileNavigation, animated: true, completion: nil)
    }
    
    @objc func userActivityButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let progressVC = VC_SubPageProgress()
        _NavController.present(progressVC, animated: true, completion: nil)
    }
    
    @objc func userFavoriteButtonTapped() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            _NavController.presentAlertForFreemium()
            return
        }
        
        let favoriteVC = VC_SubPageFavorite()
        _NavController.present(favoriteVC, animated: true, completion: nil)
    }
    
    //MARK: - Data
    
    func reloadData() {
        tableView.reloadData()
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return _AppCoreData.listBonusData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 94.5
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "bonusCell", for: indexPath) as! TC_BonusContentCell
        
        let cellData = _AppCoreData.listBonusData[indexPath.row]
        cell.titleLabel.text = cellData.bonusTitle
        
        if let thumbnailURL = URL(string: cellData.bonusImage) {
            cell.thumbnailImage.setImage(url: thumbnailURL, placeholder: UIImage.init(named: "default_thumbnail_image")!)
        }
        
//        if (cellData.bonusId == 1322) {
//            cell.thumbnailImage.image = UIImage.init(named: "mini_qa_image")
//            cell.titleLabel.text = NSLocalizedString("kMiniQA", comment: "")
//        } else if (cellData.bonusId == 1323) {
//            cell.thumbnailImage.image = UIImage.init(named: "downregulation_image")
//            cell.titleLabel.text = NSLocalizedString("kDownregulation", comment: "")
//        } else if (cellData.bonusId == 1331) {
//            cell.thumbnailImage.image = UIImage.init(named: "askmeanything_image")
//            cell.titleLabel.text = NSLocalizedString("kAskMeAnything", comment: "")
//        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kBonusContent", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        headerView.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(10)
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
            make.bottom.equalToSuperview().offset(-5)
        }
        return headerView
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let cellData = _AppCoreData.listBonusData[indexPath.row]
        
        let bonusContentVC  = VC_MainPageBonusContentDetails()
        bonusContentVC.setDataSource(newDataSource: cellData)
        _NavController.pushViewController(bonusContentVC, animated: true)
    }
}
