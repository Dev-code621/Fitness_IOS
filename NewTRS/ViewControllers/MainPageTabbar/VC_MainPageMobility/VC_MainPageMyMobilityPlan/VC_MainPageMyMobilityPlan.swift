//
//  VC_MainPageMyMobilityPlan.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_MainPageMyMobilityPlan: UIViewController,
                                UITableViewDataSource, UITableViewDelegate {
    
    let tableView           = UITableView()
    
    var listTrunkVideos     : [VideoDataSource] = []
    var isTrunkCollaped     : Bool = true
    
    var listShoudleVideos   : [VideoDataSource] = []
    var isShoudleCollaped   : Bool = true
    
    var listHipVideos       : [VideoDataSource] = []
    var isHipCollaped       : Bool = true
    
    var listAnkleVideos     : [VideoDataSource] = []
    var isAnkleCollaped     : Bool = true
    
    let loadingAnimation    = VW_LoadingAnimation()

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
        pageTitle.text = NSLocalizedString("kMyMobilityPlanTitle", comment: "")
        pageTitle.font = setFontSize(size: 24, weight: .bold)
        pageTitle.textColor = UIColor.init(hexString: "333333")
        self.view.addSubview(pageTitle)
        pageTitle.snp.makeConstraints { (make) in
            make.top.equalToSuperview()
            make.left.equalToSuperview().offset(20)
            make.height.equalTo(24)
        }
        
        // Trunk
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .none
        tableView.register(TC_VideoPracticeCell.self, forCellReuseIdentifier: "videoTableCell")
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "emptyCell")
        self.view.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.top.equalTo(pageTitle.snp.bottom).offset(16)
            make.left.right.bottom.equalToSuperview()
        }
        
        loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
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
    
    @objc func collapseButtonTapped(btn: UIButton) {
        btn.isSelected = !btn.isSelected
        
        if (btn.tag == 0) {
            self.isTrunkCollaped = !self.isTrunkCollaped
        } else if (btn.tag == 1) {
            self.isShoudleCollaped = !self.isShoudleCollaped
        } else if (btn.tag == 2) {
            self.isHipCollaped = !self.isHipCollaped
        } else {
            self.isAnkleCollaped = !self.isAnkleCollaped
        }
        
        tableView.reloadSections([btn.tag], with: .none)
    }
    
    //MARK: - Data
    func reloadData() {
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.getMobilitySuggestionVideo { (isSuccess, error, listMobilityVideos) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.listTrunkVideos = listMobilityVideos[0]
                self.listShoudleVideos = listMobilityVideos[1]
                self.listHipVideos = listMobilityVideos[2]
                self.listAnkleVideos = listMobilityVideos[3]
                
                self.tableView.reloadData()
                
            } else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""), message: error)
                return
            }
        }
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if (section == 0) {
            if self.isTrunkCollaped {
                return 1
            }
            else {
                return self.listTrunkVideos.count + 1
            }
        } else if (section == 1) {
            if self.isShoudleCollaped {
                return 1
            }
            else {
                return self.listShoudleVideos.count + 1
            }
        } else if (section == 2) {
            if self.isHipCollaped {
                return 1
            }
            else {
                return self.listHipVideos.count + 1
            }
        } else if (section == 3) {
            if self.isAnkleCollaped {
                return 1
            }
            else {
                return self.listAnkleVideos.count + 1
            }
        }
        
        return 5
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 190
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let headerView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: tableView.frame.width, height: 190))
        headerView.layer.masksToBounds = true
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.layer.masksToBounds = true
        headerView.addSubview(imageView)
        imageView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let opacityView = UIView()
        opacityView.layer.opacity = 0.2
        headerView.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        gradientLayer.frame = headerView.bounds
        gradientLayer.locations = [0.5, 1.0]
        headerView.layer.addSublayer(gradientLayer)
        
        let collapseIcon = UIImageView()
        headerView.addSubview(collapseIcon)
        collapseIcon.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(20)
            make.bottom.equalToSuperview().offset(-20)
            make.height.width.equalTo(20)
        }
        
        let collapseBtn = UIButton()
        collapseBtn.tag = section
        collapseBtn.addTarget(self, action: #selector(collapseButtonTapped(btn:)), for: .touchUpInside)
        headerView.addSubview(collapseBtn)
        collapseBtn.snp.makeConstraints { (make) in
            make.left.right.equalToSuperview()
            make.bottom.equalToSuperview().offset(-20)
            make.height.width.equalToSuperview()
        }
        
        let videoCountLabel = UILabel()
        videoCountLabel.text = NSLocalizedString("kTodaySuggestTitle", comment: "")
        videoCountLabel.font = setFontSize(size: 11, weight: .regular)
        videoCountLabel.textColor = UIColor.init(hexString: "dddddd")
        headerView.addSubview(videoCountLabel)
        videoCountLabel.snp.makeConstraints { (make) in
            make.centerY.equalTo(collapseIcon)
            make.left.equalTo(collapseIcon.snp.right).offset(6)
        }
        
//        let videoAttributeString = NSMutableAttributedString()
//        let videoAttribute = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "dddddd")!,
//                              NSAttributedString.Key.font : setFontSize(size: 11, weight: .regular)] as [NSAttributedString.Key : Any]
//        let countAttribute = [NSAttributedString.Key.foregroundColor: UIColor.init(hexString: "dddddd")!,
//                              NSAttributedString.Key.font : setFontSize(size: 11, weight: .semibold)] as [NSAttributedString.Key : Any]
        
        let groupLabel = UILabel()
        groupLabel.font = setFontSize(size: 14, weight: .semibold)
        groupLabel.textColor = .white
        headerView.addSubview(groupLabel)
        groupLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(collapseIcon.snp.top).offset(-2)
            make.left.equalTo(collapseIcon)
        }
        
        if (section == 0) {
            groupLabel.text = NSLocalizedString("kTrunkPractice", comment: "")
            imageView.image = UIImage.init(named: "trunk_result_image")
//            videoAttributeString.append(NSAttributedString.init(string: NSString(format: "%ld", self.listTrunkVideos.count) as String, attributes: countAttribute))
            collapseIcon.image = self.isTrunkCollaped ?
                UIImage.init(named: "mobility_collapse_btn") :
                UIImage.init(named: "mobility_expand_btn")
        }
        else if (section == 1) {
            groupLabel.text = NSLocalizedString("kShoulderPractice", comment: "")
            imageView.image = UIImage.init(named: "shoulder_result_image")
//            videoAttributeString.append(NSAttributedString.init(string: NSString(format: "%ld", self.listShoudleVideos.count) as String, attributes: countAttribute))
            collapseIcon.image = self.isShoudleCollaped ?
                UIImage.init(named: "mobility_collapse_btn") :
                UIImage.init(named: "mobility_expand_btn")
        }
        else if (section == 2) {
            groupLabel.text = NSLocalizedString("kHipPractice", comment: "")
            imageView.image = UIImage.init(named: "hip_result_image")
//            videoAttributeString.append(NSAttributedString.init(string: NSString(format: "%ld", self.listHipVideos.count) as String, attributes: countAttribute))
            collapseIcon.image = self.isHipCollaped ?
                UIImage.init(named: "mobility_collapse_btn") :
                UIImage.init(named: "mobility_expand_btn")
        }
        else if (section == 3) {
            groupLabel.text = NSLocalizedString("kAnklePractice", comment: "")
            imageView.image = UIImage.init(named: "ankle_result_image")
//            videoAttributeString.append(NSAttributedString.init(string: NSString(format: "%ld", self.listAnkleVideos.count) as String, attributes: countAttribute))
            collapseIcon.image = self.isAnkleCollaped ?
                UIImage.init(named: "mobility_collapse_btn") :
                UIImage.init(named: "mobility_expand_btn")
        }
        
//        videoAttributeString.append(NSAttributedString.init(string: " videos", attributes: videoAttribute))
//        videoCountLabel.attributedText = videoAttributeString
        
        return headerView
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if indexPath.row == 0 {
            return 11
        }
        
        if indexPath.section == 0 {
            if indexPath.row == (self.listTrunkVideos.count + 1) {return 127}
        } else if indexPath.section == 1 {
            if indexPath.row == (self.listShoudleVideos.count + 1) {return 127}
        } else if indexPath.section == 2 {
            if indexPath.row == (self.listHipVideos.count + 1) {return 127}
        } else if indexPath.section == 3 {
            if indexPath.row == (self.listAnkleVideos.count + 1) {return 127}
        }
        
        return 107
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.row == 0 {
            //Allway return at least empty row
            let emptyCell = tableView.dequeueReusableCell(withIdentifier: "emptyCell", for: indexPath)
            return emptyCell
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "videoTableCell", for: indexPath) as! TC_VideoPracticeCell
        
        var cellData : VideoDataSource = VideoDataSource.init(JSONString: "{}")!
        if indexPath.section == 0 {
            //Trunk video
            cellData = self.listTrunkVideos[indexPath.row - 1]
        } else if indexPath.section == 1 {
            //Shoulder video
            cellData = self.listShoudleVideos[indexPath.row - 1]
        } else if indexPath.section == 2 {
            //Hip video
            cellData = self.listHipVideos[indexPath.row - 1]
        } else if indexPath.section == 3 {
            //Ankle video
            cellData = self.listAnkleVideos[indexPath.row - 1]
        }
        
        cell.setDataSource(videoData: cellData)
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        var cellData : VideoDataSource = VideoDataSource.init(JSONString: "{}")!
        // Nhấp vào row đầu tiên là khoảng trống sẽ ko làm gì
        if indexPath.row == 0 { return }
        
        if indexPath.section == 0 {
            //Trunk video
            cellData = self.listTrunkVideos[indexPath.row - 1]
        } else if indexPath.section == 1 {
            //Shoulder video
            cellData = self.listShoudleVideos[indexPath.row - 1]
        } else if indexPath.section == 2 {
            //Hip video
            cellData = self.listHipVideos[indexPath.row - 1]
        } else if indexPath.section == 3 {
            //Ankle video
            cellData = self.listAnkleVideos[indexPath.row - 1]
        }
        
        let videoVC = VC_SubPageVideoPlayer()
        videoVC.setVideoDataSource(newVideoDataSource: cellData)
        self.navigationController?.pushViewController(videoVC, animated: true)
    }
}
