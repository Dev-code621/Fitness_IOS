//
//  VC_UserContactTRS.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/26/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import MessageUI

class VC_UserContactTRS: UIViewController, UITextViewDelegate, MFMailComposeViewControllerDelegate {

    let bannerImage             = UIImageView()
    
    let pageScroll              = UIScrollView()
    let contentView             = UIView()
    let textViewLayout          = UIView()
    let textView                = UITextView()
    
    let sendBtn                 = UIButton()

    override func viewDidLoad() {
        super.viewDidLoad()
        self.edgesForExtendedLayout = []
        self.view.backgroundColor = UIColor.init(hexString: "fafafa")
        
        let singleTap = UITapGestureRecognizer.init(target: self, action: #selector(dissmissKeyBoard))
        self.view.addGestureRecognizer(singleTap)

        let bannerHight = UIScreen.main.bounds.size.width * 0.432
        
        bannerImage.image = UIImage.init(named: "head_banner")
        bannerImage.layer.cornerRadius = 30
        bannerImage.layer.maskedCorners = [.layerMaxXMaxYCorner, .layerMinXMaxYCorner]
        bannerImage.layer.masksToBounds = true
        self.view.addSubview(bannerImage)
        bannerImage.snp.makeConstraints { (make) in
            make.top.left.right.equalToSuperview()
            make.height.equalTo(bannerHight)
        }
        
        sendBtn.setTitle(NSLocalizedString("kSendBtn", comment: ""), for: .normal)
        sendBtn.setTitleColor(.white, for: .normal)
        sendBtn.titleLabel?.font = setFontSize(size: 16, weight: .bold)
        sendBtn.backgroundColor = UIColor.lightGray
        sendBtn.isUserInteractionEnabled = false
        sendBtn.layer.cornerRadius = 20
        sendBtn.addTarget(self, action: #selector(sendButtonTapped), for: .touchUpInside)
        self.view.addSubview(sendBtn)
        sendBtn.snp.makeConstraints { (make) in
            make.bottom.equalTo(self.view.safeAreaLayoutGuide).offset(-20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(40)
        }
        
        self.view.addSubview(pageScroll)
        pageScroll.snp.makeConstraints { (make) in
            make.top.equalToSuperview().offset(70)
            make.left.right.equalToSuperview()
            make.bottom.equalTo(sendBtn.snp.top)
            make.width.equalTo(self.view)
        }
        
        contentView.backgroundColor = UIColor.init(hexString: "ffffff")
        contentView.layer.cornerRadius = 20
        contentView.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        contentView.layer.shadowOpacity = 0.5
        contentView.layer.shadowOffset = CGSize(width: 2, height: 9)
        contentView.layer.shadowRadius = 20
        pageScroll.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.equalTo(pageScroll.snp.top).offset(bannerHight - 140)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.height.equalTo(177)
        }
        
        let contactUsLabel = UILabel()
        contactUsLabel.text = NSLocalizedString("kContactUs", comment: "")
        contactUsLabel.font = setFontSize(size: 24, weight: .bold)//HurmeGeometricSans2 
        contactUsLabel.textColor = UIColor.init(hexString: "333333")
        contentView.addSubview(contactUsLabel)
        contactUsLabel.snp.makeConstraints { (make) in
            make.top.left.equalToSuperview().offset(30)
        }
        
        let kellyAvatar = UIImageView()
        kellyAvatar.image = UIImage.init(named: "kelly_avatar_image")
        contentView.addSubview(kellyAvatar)
        kellyAvatar.snp.makeConstraints { (make) in
            make.top.equalTo(contactUsLabel.snp.bottom).offset(20)
            make.left.equalToSuperview().offset(30)
            make.height.width.equalTo(30)
        }
        
        let kellyNameLabel = UILabel()
        kellyNameLabel.text = "Dr. Kelly Starrett"
        kellyNameLabel.font = setFontSize(size: 10, weight: .bold)
        kellyNameLabel.textColor = UIColor.init(hexString: "666666")
        contentView.addSubview(kellyNameLabel)
        kellyNameLabel.snp.makeConstraints { (make) in
            make.bottom.equalTo(kellyAvatar.snp.centerY).offset(-3)
            make.left.equalTo(kellyAvatar.snp.right).offset(10)
        }
        
        let kellyTitleLabel = UILabel()
        kellyTitleLabel.text = "Co-Founder"
        kellyTitleLabel.font = setFontSize(size: 10, weight: .regular) 
        kellyTitleLabel.textColor = UIColor.init(hexString: "666666")
        contentView.addSubview(kellyTitleLabel)
        kellyTitleLabel.snp.makeConstraints { (make) in
            make.top.equalTo(kellyAvatar.snp.centerY).offset(3)
            make.left.equalTo(kellyAvatar.snp.right).offset(10)
            make.centerX.equalToSuperview()
        }
        
        let kellyQouteLabel = UILabel()
        kellyQouteLabel.text = "“We love hearing from Virtual Mobility Coach community! Send a message to me and the rest of Virtual Mobility Coach team using the form below.”"
        kellyQouteLabel.font = setFontSize(size: 12, weight: .regular) //UIFont.init(name: "HurmeGeometricSans1-RegularObl", size: 12)
        kellyQouteLabel.textColor = UIColor.init(hexString: "666666")
        kellyQouteLabel.numberOfLines = 0
        contentView.addSubview(kellyQouteLabel)
        kellyQouteLabel.snp.makeConstraints { (make) in
            make.top.equalTo(kellyAvatar.snp.bottom).offset(6)
            make.left.equalToSuperview().offset(30)
            make.centerX.equalToSuperview()
        }
        
        textViewLayout.backgroundColor = UIColor.init(hexString: "ffffff")
        textViewLayout.layer.cornerRadius = 20
        textViewLayout.layer.shadowColor = UIColor.init(hexString: "772d00ff")!.cgColor
        textViewLayout.layer.shadowOpacity = 0.5
        textViewLayout.layer.shadowOffset = CGSize(width: 2, height: 9)
        textViewLayout.layer.shadowRadius = 20
        pageScroll.addSubview(textViewLayout)
        textViewLayout.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.bottom).offset(20)
            make.centerX.equalToSuperview()
            make.width.equalToSuperview().offset(-40)
            make.bottom.equalTo(pageScroll)
        }
        
        textView.text = "Type here"
        textView.delegate = self
        textView.textColor = .lightGray
        textViewLayout.addSubview(textView)
        textView.snp.makeConstraints { (make) in
            make.center.equalToSuperview()
            make.size.equalToSuperview().offset(-40)
            make.height.greaterThanOrEqualTo(300)
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
        
        self.addDoneButtonOnKeyboard()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(self.keyboardNotification(notification:)),
                                               name: UIResponder.keyboardWillChangeFrameNotification,
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    //MARK: - UI
    func addDoneButtonOnKeyboard() {
        let doneToolbar = UIToolbar()
        doneToolbar.barStyle = .default

        let flexSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let done = UIBarButtonItem(title: "Done",
                                   style: .done,
                                   target: self,
                                   action:#selector(dissmissKeyBoard))
        
        doneToolbar.setItems([flexSpace, done], animated: true)
        doneToolbar.sizeToFit()

        self.textView.inputAccessoryView = doneToolbar
    }
    
    @objc func keyboardNotification(notification: Notification) {
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0

            if endFrameY >= UIScreen.main.bounds.size.height {
                
                textViewLayout.snp.remakeConstraints { (make) in
                    make.top.equalTo(contentView.snp.bottom).offset(20)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-40)
                    make.bottom.equalTo(pageScroll)
                }
            } else {
                
                let height = UIScreen.main.bounds.size.height - endFrameY
                textViewLayout.snp.remakeConstraints { (make) in
                    make.top.equalTo(contentView.snp.bottom).offset(20)
                    make.centerX.equalToSuperview()
                    make.width.equalToSuperview().offset(-40)
                    make.bottom.equalTo(pageScroll).offset(-height)
                }
            }
            
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            UIView.animate(withDuration: duration,
                                       delay: TimeInterval(0),
                                       options: animationCurve,
                                       animations: { self.view.layoutIfNeeded() },
                                       completion: nil)
        }
    }
    
    //MARK: - Buttons
    @objc func dissmissKeyBoard() {
        self.view.endEditing(true)
    }
    
    @objc func backButtonTapped() {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func sendButtonTapped() {
                
        guard let userID = _AppDataHandler.getSessionDataSource()?.userID else {
            _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                               message:"User not login already")
            return
        }
        
        if MFMailComposeViewController.canSendMail() {
            let mail = MFMailComposeViewController()
            mail.mailComposeDelegate = self
            mail.setToRecipients(["info@thereadystate.com"])
            mail.setBccRecipients(["cbi.thereadystate@gmail.com"])
            mail.setSubject(String(format: "[Virtual Mobility Coach] - Contact support - userID: %ld", userID))
            mail.setMessageBody(textView.text, isHTML: false)

            present(mail, animated: true)
        } else {
            
            _NavController.presentAlertForCase(title: NSLocalizedString("kEmailContactFailTitle", comment: ""),
                                               message: NSLocalizedString("kEmailContactNotFound", comment: ""))

//            let email = "foo@bar.com"
//            if let url = URL(string: "mailto:\(email)") {
//              if #available(iOS 10.0, *) {
//                UIApplication.shared.open(url)
//              } else {
//                UIApplication.shared.openURL(url)
//              }
//            }
            
//            // set up activity view controller
//            let textToShare = [ self.textView.text ] as [Any]
//            let activityViewController = UIActivityViewController(activityItems: textToShare , applicationActivities: nil)
//            activityViewController.popoverPresentationController?.sourceView = self.view // so that iPads won't crash
//
//            // exclude some activity types from the list (optional)
//            activityViewController.excludedActivityTypes = [ UIActivity.ActivityType.mail,
//                                                             UIActivity.ActivityType.copyToPasteboard,
//                                                             UIActivity.ActivityType.message]
//
//            // present the view controller
//            self.present(activityViewController, animated: true, completion: nil)
        }
    }
    
    //MARK: - UITextViewDelegate
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.textColor == UIColor.lightGray {
            textView.text = nil
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Type here"
            textView.textColor = UIColor.lightGray
            
            self.sendBtn.backgroundColor = UIColor.lightGray
            self.sendBtn.isUserInteractionEnabled = false
        } else {
            self.sendBtn.backgroundColor = UIColor.init(hexString: "2d00ff")
            self.sendBtn.isUserInteractionEnabled = true
        }
    }
    
    //MARK: - MFMailComposeViewControllerDelegate
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true)
        
        switch result {
        case .sent:
            self.textView.text = ""
            _NavController.presentAlertForCase(title: NSLocalizedString("kEmailContactSendTitle", comment: ""),
                                               message: NSLocalizedString("kEmailContactSendMessage", comment: ""))
            break
        case .failed:
            _NavController.presentAlertForCase(title: NSLocalizedString("kEmailContactFailTitle", comment: ""),
                                               message: error?.localizedDescription ?? "")
            break
        case .cancelled:
            _NavController.presentAlertForCase(title: NSLocalizedString("kEmailContactFailTitle", comment: ""),
                                               message: error?.localizedDescription ?? "")
            break
        default:
            break
        }
    }
}
