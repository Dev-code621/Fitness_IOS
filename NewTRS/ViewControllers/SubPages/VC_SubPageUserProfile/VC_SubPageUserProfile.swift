//
//  VC_SubPageUserProfile.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/24/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VC_SubPageUserProfile: UIViewController,
                            UITableViewDataSource, UITableViewDelegate,
                            UIImagePickerControllerDelegate, UINavigationControllerDelegate,
                            VW_UserUpdateProfileDelegate {
    
    let userAvatar          = UIImageView()
    let userName            = UILabel()
    let userRank            = UILabel()
    let userPlan            = UILabel()
    
    let userGender          = UILabel()
    let userAge             = UILabel()
    let userCountry         = UILabel()
    
    let tableView           = UITableView()
    
    var editProfileView     = VW_UserUpdateProfile()
    let loadingAnimation    = VW_LoadingAnimation()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let bannerImage = UIImageView()
        bannerImage.contentMode = .scaleAspectFill
        bannerImage.image = UIImage.init(named: "head_banner")
        bannerImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(self.view.snp.width).multipliedBy(0.432)
        }
        
        let userInfoView = UIView()
        userInfoView.backgroundColor = UIColor.init(hexString: "ccffffff")
        userInfoView.layer.cornerRadius = 20
        userInfoView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        userInfoView.layer.shadowOpacity = 0.5
        userInfoView.layer.shadowOffset = CGSize(width: 2, height: 9)
        userInfoView.layer.shadowRadius = 20
        self.view.addSubview(userInfoView)
        userInfoView.snp.makeConstraints { (make) in
            make.centerY.equalTo(bannerImage.snp.bottom).offset(-10)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.height.equalTo(125)
        }
        
        self.view.layoutIfNeeded()
        
        let blurEffect = UIBlurEffect(style: UIBlurEffect.Style.light)
        let blurEffectView = UIVisualEffectView(effect: blurEffect)
        blurEffectView.frame = userInfoView.bounds
        blurEffectView.layer.cornerRadius = 20
        blurEffectView.layer.masksToBounds = true
        blurEffectView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        userInfoView.addSubview(blurEffectView)
        
        userName.text = "Example User Name"
        userName.font = setFontSize(size: 18, weight: .bold)
        userName.textColor = UIColor.init(hexString: "1d00ff")
        userInfoView.addSubview(userName)
        userName.snp.makeConstraints { (make) in
            make.left.equalToSuperview().offset(136)
            make.top.equalToSuperview().offset(26)
            make.right.equalToSuperview()
        }
        
        userRank.isHidden = true
        let rankattributedString = NSMutableAttributedString(string: "No. 17 on Leaderboard", attributes: [
            .font: setFontSize(size: 12, weight: .regular),
            .foregroundColor: UIColor(white: 51.0 / 255.0, alpha: 1.0),
            .kern: 0.24
        ])
        rankattributedString.addAttribute(.font, value: setFontSize(size: 12, weight: .semibold), range: NSRange(location: 4, length: 2))
        userRank.attributedText = rankattributedString
        userInfoView.addSubview(userRank)
        userRank.snp.makeConstraints { (make) in
            make.left.right.equalTo(userName)
            make.top.equalTo(userName.snp.bottom).offset(8)
        }
        
        userPlan.text = "Fremium"
        userPlan.font = setFontSize(size: 12, weight: .semibold)
        userPlan.textColor = UIColor.init(hexString: "333333")
        userInfoView.addSubview(userPlan)
        userPlan.snp.makeConstraints { (make) in
            make.left.equalTo(userName)
            make.top.equalTo(userRank.snp.bottom).offset(16)
        }
        
//        userGender.text = "Male"
//        userGender.font = setFontSize(size: 12, weight: .semibold)
//        userGender.textColor = UIColor.init(hexString: "333333")
//        userInfoView.addSubview(userGender)
//        userGender.snp.makeConstraints { (make) in
//            make.left.equalTo(userName)
//            make.top.equalTo(userRank.snp.bottom).offset(16)
//        }
//
//        let dotView = UIView()
//        dotView.backgroundColor = UIColor.init(hexString: "666666")
//        dotView.layer.cornerRadius = 2
//        userInfoView.addSubview(dotView)
//        dotView.snp.makeConstraints { (make) in
//            make.centerY.equalTo(userGender)
//            make.left.equalTo(userGender.snp.right).offset(6)
//            make.height.width.equalTo(4)
//        }
//
//        let ageattributedString = NSMutableAttributedString(string: "35 age", attributes: [
//          .font: setFontSize(size: 12, weight: .regular),
//          .foregroundColor: UIColor(white: 51.0 / 255.0, alpha: 1.0),
//          .kern: 0.24
//        ])
//        ageattributedString.addAttribute(.font, value: setFontSize(size: 12, weight: .semibold), range: NSRange(location: 0, length: 2))
//        userAge.attributedText = ageattributedString
//        userInfoView.addSubview(userAge)
//        userAge.snp.makeConstraints { (make) in
//            make.centerY.height.equalTo(userGender)
//            make.left.equalTo(dotView.snp.right).offset(6)
//        }
//
//        let dotView2 = UIView()
//        dotView2.backgroundColor = UIColor.init(hexString: "666666")
//        dotView2.layer.cornerRadius = 2
//        userInfoView.addSubview(dotView2)
//        dotView2.snp.makeConstraints { (make) in
//            make.centerY.equalTo(userGender)
//            make.left.equalTo(userAge.snp.right).offset(6)
//            make.height.width.equalTo(4)
//        }
//
//        userCountry.text = "USA"
//        userCountry.font = setFontSize(size: 12, weight: .semibold)
//        userCountry.textColor = UIColor.init(hexString: "333333")
//        userInfoView.addSubview(userCountry)
//        userCountry.snp.makeConstraints { (make) in
//            make.centerY.height.equalTo(userGender)
//            make.left.equalTo(dotView2.snp.right).offset(6)
//        }
        
        userAvatar.image = UIImage.init(named: "default_avatar")
        userAvatar.contentMode = .scaleAspectFill
        userAvatar.layer.cornerRadius = 10
        userAvatar.layer.borderWidth = 0.5
        userAvatar.layer.borderColor = UIColor.white.cgColor
        userAvatar.layer.masksToBounds = true
        self.view.addSubview(userAvatar)
        userAvatar.snp.makeConstraints { (make) in
            make.left.equalTo(userInfoView)
            make.top.equalTo(userInfoView).offset(-15)
            make.width.height.equalTo(120)
        }
        
        let editAvatarBtn = UIButton()
        editAvatarBtn.setBackgroundImage(UIImage.init(named: "edit_btn"), for: .normal)
        editAvatarBtn.addTarget(self, action: #selector(editAvatarButtonTapped), for: .touchUpInside)
        self.view.addSubview(editAvatarBtn)
        editAvatarBtn.snp.makeConstraints { (make) in
            make.bottom.right.equalTo(userAvatar)
            make.height.width.equalTo(23)
        }
        
        let editProfileBtn = UIButton()
        editProfileBtn.setBackgroundImage(UIImage.init(named: "white_edit_btn"), for: .normal)
        editProfileBtn.addTarget(self, action: #selector(editProfileButtonTapped), for: .touchUpInside)
        self.view.addSubview(editProfileBtn)
        editProfileBtn.snp.makeConstraints { (make) in
            make.centerY.equalTo(userInfoView.snp.top)
            make.centerX.equalTo(self.view.snp.right).offset(-45)
            make.height.width.equalTo(40)
        }
        
        let closeBtn = UIButton()
        closeBtn.setBackgroundImage(UIImage.init(named: "close_btn"), for: .normal)
        closeBtn.addTarget(self, action: #selector(closeButtonTapped), for: .touchUpInside)
        self.view.addSubview(closeBtn)
        closeBtn.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(34)
            make.right.equalToSuperview().offset(-20)
            make.height.width.equalTo(23)
        }
        
        //TableView
        
        let tableContentView = UIView()
        tableContentView.backgroundColor = UIColor.init(hexString: "ccffffff")
        tableContentView.layer.cornerRadius = 20
        tableContentView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        tableContentView.layer.shadowOpacity = 0.5
        tableContentView.layer.shadowOffset = CGSize(width: 2, height: 9)
        tableContentView.layer.shadowRadius = 20
        self.view.addSubview(tableContentView)
        tableContentView.snp.makeConstraints { (make) in
            make.top.equalTo(userInfoView.snp.bottom).offset(5)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-60)
            make.bottom.lessThanOrEqualToSuperview().offset(-10)
            make.height.lessThanOrEqualTo(450)
        }
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.layer.cornerRadius = 20
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        tableView.register(TC_UserProfileCell.self, forCellReuseIdentifier: "userProfileCell")
        tableContentView.addSubview(tableView)
        tableView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(handleNotification(noti:)),
                                               name: kUserProfileHasChangeNotification,
                                               object: nil)
        
        self.view.addSubview(editProfileView)
        editProfileView.reloadData()
        editProfileView.snp.makeConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom)
            make.centerX.size.equalToSuperview()
        }
        
        self.loadingAnimation.isHidden = true
        self.view.addSubview(loadingAnimation)
        loadingAnimation.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        self.reloadData()
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.reloadUserProfile()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    //MARK: - Button
    @objc func closeButtonTapped() {
        self.navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc func editAvatarButtonTapped() {
        
        let alertVC = UIAlertController.init(title: "Select Image",
                                             message: "",
                                             preferredStyle: .alert)
        let cameraOption = UIAlertAction.init(title: "Camera",
                                              style: .default) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                let picker = UIImagePickerController()
                                                picker.delegate = self
                                                if UIImagePickerController.isSourceTypeAvailable(.camera){
                                                    picker.sourceType = .camera
                                                }
                                                self.present(picker, animated: true, completion: nil)
        }
        
        let photoOption = UIAlertAction.init(title: "Photo Gallery",
                                             style: .default) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                let picker = UIImagePickerController()
                                                picker.delegate = self
                                                picker.sourceType = .photoLibrary
                                                self.present(picker, animated: true, completion: nil)
        }
        
        let cancelOption = UIAlertAction.init(title: "Cancel",
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(cameraOption)
        alertVC.addAction(photoOption)
        alertVC.addAction(cancelOption)
        
        self.present(alertVC, animated: true, completion: nil)
    }
    
    @objc func editProfileButtonTapped() {
        
        self.editProfileView.reloadData()
        self.editProfileView.delegate = self
        self.editProfileView.snp.remakeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    //MARK: - Data
    func reloadData() {
        
        self.loadingAnimation.isHidden = true
        
        let userProfile = _AppDataHandler.getUserProfile()
        
        if let avatarURL = URL(string: userProfile.userAvatar) {
            self.userAvatar.sd_setImage(with: avatarURL,
                                        placeholderImage: UIImage.init(named: "default_avatar"),
                                        options: [], context: nil)
        }
        
        self.userName.text = userProfile.firstName + " " + userProfile.lastName
        self.userPlan.text = userProfile.userPlan
        
        let rankString = String(format: "%ld", userProfile.userProfileRank.userRankIndex)
        let attributedStr = NSMutableAttributedString(string: String(format: "No. %@ on Leaderboard", rankString))
        attributedStr.addAttribute(NSAttributedString.Key.foregroundColor,
                                        value: UIColor.init(hexString: "333333")!,
                                          range: NSMakeRange(0, attributedStr.length))
        attributedStr.addAttribute(NSAttributedString.Key.font,
                                   value: setFontSize(size: 12, weight: .regular),
                                        range: NSMakeRange(0, attributedStr.length))
        attributedStr.addAttribute(NSAttributedString.Key.font,
                                   value: setFontSize(size: 12, weight: .semibold),
                                          range: NSMakeRange(4, rankString.count))
        userRank.attributedText = attributedStr
    }
    
    @objc private func handleNotification(noti: Notification) {
        self.reloadData()
    }
    
    //MARK: - UITableViewDataSource
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 9
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "userProfileCell", for: indexPath) as! TC_UserProfileCell
        let bgColorView = UIView()
        bgColorView.backgroundColor = UIColor.init(hexString: "F3F1FF")
        cell.selectedBackgroundView = bgColorView
        
        cell.accessoryType = .none
        
        switch indexPath.row {
        case 0:
            cell.cellIcon.image = UIImage.init(named: "user_favorite_icon")
            cell.cellTitle.text = NSLocalizedString("kFavorites", comment: "")
            break
        case 1:
            cell.cellIcon.image = UIImage.init(named: "notification_icon")
            cell.cellTitle.text = NSLocalizedString("kNotifications", comment: "")
            break
        case 2:
            cell.cellIcon.image = UIImage.init(named: "settings_icon")
            cell.cellTitle.text = NSLocalizedString("kMyEquipmentsList", comment: "")
            break
        case 3:
            cell.cellIcon.image = UIImage.init(named: "subscription_icon")
            cell.cellTitle.text = NSLocalizedString("kMyMembership", comment: "")
            break
        case 4:
            cell.cellIcon.image = UIImage.init(named: "downloaded_icon")
            cell.cellTitle.text = NSLocalizedString("kDownloaded", comment: "")
            break
        case 5:
            cell.cellIcon.image = UIImage.init(named: "contact_icon")
            cell.cellTitle.text = NSLocalizedString("kContactUs", comment: "")
            break
        case 6:
            cell.cellIcon.image = UIImage.init(named: "help_icon")
            cell.cellTitle.text = NSLocalizedString("kUserChangePass", comment: "")
            break
        case 7:
            cell.cellIcon.image = UIImage.init(named: "privacy_policy")
            cell.cellTitle.text = NSLocalizedString("kAppPolicy", comment: "")
            break
        case 8:
            cell.cellIcon.image = UIImage.init(named: "logout_icon")
            cell.cellTitle.text = NSLocalizedString("kLogout", comment: "")
            cell.bottomLine.isHidden = true
            cell.accessoryType = .none
        default:
            break
        }
        
        return cell
    }
    
    //MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        switch indexPath.row {
        case 0:
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                _NavController.presentAlertForFreemium()
                return
            }
            
            let favoriteVC = VC_SubPageFavorite()
            self.navigationController?.pushViewController(favoriteVC, animated: true)
            break
        case 1:
            let notificationVC = VC_UserNotifications()
            self.navigationController?.pushViewController(notificationVC, animated: true)
            break
        case 2:
            let settingsVC = VC_UserSettings()
            self.navigationController?.pushViewController(settingsVC, animated: true)
            break
        case 3:
            
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                let iapVC = VC_InAppPurchase()
                self.navigationController?.pushViewController(iapVC, animated: true)
                return
            }
            
            let supscriptionVC = VC_UserSubscription()
            self.navigationController?.pushViewController(supscriptionVC, animated: true)
            break
        case 4:
            
            if _AppDataHandler.getUserProfile().isFreemiumUser() {
                _NavController.presentAlertForFreemium()
                return
            }
            
            let donwloadedVC = VC_UserDownloadedVideos()
            self.navigationController?.pushViewController(donwloadedVC, animated: true)
            break
        case 5:
            let contactUSVC = VC_UserContactTRS()
            self.navigationController?.pushViewController(contactUSVC, animated: true)
            break
        case 6:
            let changePassVC = VC_UserChangePass()
            self.navigationController?.pushViewController(changePassVC, animated: true)
            break
        case 7:
            let appPolicyVC = VC_AppPrivacyPolicy()
            self.navigationController?.pushViewController(appPolicyVC, animated: true)
            break
        case 8:
            
            let alertVC = UIAlertController.init(title: NSLocalizedString("kLogoutTitle", comment: ""),
                                                 message: NSLocalizedString("kLogoutMessage", comment: ""),
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                              style: .default) { (action) in
                                                alertVC.dismiss(animated: false, completion: nil)
                                                self.dismiss(animated: false, completion: nil)
                                                _AppDataHandler.signout()
                                                _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
            }
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""),
                                                  style: .cancel) { (action) in
                                                    alertVC.dismiss(animated: true, completion: nil)}
            alertVC.addAction(okAction)
            alertVC.addAction(cancelAction)
            self.present(alertVC, animated: true, completion: nil)
            
            break
        default:
            break
        }
    }
    
    //MARK: - UIImagePickerControllerDelegate
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        picker.dismiss(animated: true, completion: nil)
        if let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage? {
            
            self.loadingAnimation.isHidden = false
            _AppDataHandler.updateUserAvatar(image: image) { (isSuccess, error) in
                
                self.loadingAnimation.isHidden = true
                if isSuccess {
                    let _ = _AppDataHandler.getUserProfile { (isSuccess, error, newUserProfile) in
                        if isSuccess {
                            self.reloadData()
                        }
                    }
                } else {
                    _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
                                                       message: error)
                    return
                }
            }
        }
    }
    
    //MARK: - VW_UserUpdateProfileDelegate
    func didCloseUpdateView() {
        self.editProfileView.snp.remakeConstraints { (make) in
            make.top.equalTo(self.view.snp.bottom)
            make.size.centerX.equalToSuperview()
        }
        
        UIView.animate(withDuration: 0.5) {
            self.view.layoutIfNeeded()
        }
    }
    
    func didUpdateUserProfile(newUserProfile: UserProfileDataSource) {
        
        self.loadingAnimation.isHidden = false
        _AppDataHandler.updateUserProfile(profile: newUserProfile) { (isSuccess, error) in
            
            self.loadingAnimation.isHidden = true
            if isSuccess {
                self.reloadData()
                
                _NavController.presentAlertForCase(title: NSLocalizedString("kEditProfileTitle", comment: "") ,
                                                   message: NSLocalizedString("kEditProfileSuccessMessage", comment: ""))
                return
                
            }  else {
                _NavController.presentAlertForCase(title: NSLocalizedString("kAPIRequestFailed", comment: ""),
                                                   message: error)
                return
            }
        }
    }
}
