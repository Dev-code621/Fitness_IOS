//
//  VC_UserNotifications.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/25/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_UserNotifications: UIViewController,
                            UITableViewDataSource, UITableViewDelegate {
    
    let tableView           = UITableView()
    let loadingAnimation    = VW_LoadingAnimation()
    
    var listNotification    : [UserNotificationDataSource] = []
    let nodataLabel         = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let backBtn = UIBarButtonItem.init(image: UIImage.init(named: "back_black_btn")?.withRenderingMode(.alwaysOriginal),
                                           style: .plain,
                                           target: self,
                                           action: #selector(backButtonTapped))
        self.navigationItem.leftBarButtonItem = backBtn
        
        let pageTitle = UILabel()
        pageTitle.text = NSLocalizedString("kNotifications", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.backgroundColor = UIColor.init(hexString: "fafafa")
        tableView.showsVerticalScrollIndicator = false
        tableView.separatorStyle = .none
        tableView.register(TC_UserNotificationCell.self, forCellReuseIdentifier: "notificationCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(16)
            make.left.right.bottom.equalTo(self.view.safeAreaLayoutGuide)
        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        nodataLabel.isHidden = true
        nodataLabel.text = NSLocalizedString("kNotificationNoDataMeaage", comment: "")
        nodataLabel.textAlignment = .center
        nodataLabel.font = setFontSize(size: 14, weight: .regular)
        nodataLabel.textColor = UIColor.init(hexString: "666666")
        nodataLabel.numberOfLines = 0
        self.view.addSubview(nodataLabel)
        nodataLabel.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
        }
        
        self.reloadData()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: true)
    }
    
    //MARK: - Buttons
    
    @objc func backButtonTapped() {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    //MARK: - Data
    func reloadData() {
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getListNotification { (isSuccess, error, newListNotification) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.nodataLabel.isHidden = !(newListNotification.count == 0)
                self.listNotification = newListNotification
                self.tableView.reloadData()
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
                                                             message: error)
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.listNotification.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "notificationCell", for: indexPath) as! TC_UserNotificationCell
        
        let cellData = self.listNotification[indexPath.row]

        cell.titleLabel.text = cellData.notificationName
        cell.contentLabel.text = cellData.notificationDecs

        if cellData.notificationType == .newVideo {
            cell.avatarImageView.image = UIImage.init(named: "new_video_icon")
        } else if cellData.notificationType == .newArchiverment {
            cell.avatarImageView.image = UIImage.init(named: "new_archivement_icon")
        }

        let date = Date.init(timeIntervalSince1970: TimeInterval(cellData.notificaiotnDate))
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.init(abbreviation: "GMT")
        dateFormatter.dateFormat = "MMM dd"

        cell.dateLabel.text = dateFormatter.string(from: date)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        // Không cho user chọn
//        let cellData = self.listNotification[indexPath.row]
//        if (cellData.notificationIsRead == false) {
//            _AppDataHandler.setNotificationAsRead { (isSuccess, error) in
//                if isSuccess {
//                    print("")
//                }  else {
//                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
//                                                       message: error)
//                    return
//                }
//            }
//        }
    }
}
