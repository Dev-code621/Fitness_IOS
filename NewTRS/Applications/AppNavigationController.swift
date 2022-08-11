//
//  AppNavigationController.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class AppNavigationController: UINavigationController {
    
    private var reminderTimer    : Timer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        _AppDataHandler.checkForReachability()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleNotification(noti:)),
                                               name: kWatchPreVideoNotification, object: nil)
    }
        
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc private func handleNotification(noti: Notification) {
        if noti.name == kWatchPreVideoNotification {
            reminderTimer?.invalidate()
            reminderTimer = nil
            
            reminderTimer = Timer.scheduledTimer(withTimeInterval: 3600,
                                                 repeats: false,
                                                 block: { (timer) in
                                                    self.reminderTimer?.invalidate()
                                                    self.reminderTimer = nil
                                                    self.presentAlertForCase(title: "Reminder",
                                                                             message: "It's time to do your post-workout mobilizations!")
            })
            
            self.pushReminderNotification()
        }
    }
    
    private func pushReminderNotification () {
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        // remove pending Notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [kWatchPreVideoNotification.rawValue])
        
        // Fire in 1 hours (60 seconds times 60)
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (60*60), repeats: false)
        
        //create content
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("kReminderTitle", comment: "")
        content.body = NSLocalizedString("kReminderWorkoutMessage", comment: "")
        content.sound = .default
        
        // Create the request
        let uuidString = kWatchPreVideoNotification.rawValue
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content,
                                            trigger: trigger)

        // Schedule the request with the system.
        notificationCenter.add(request) { (error) in
           if error != nil {
              // Handle any errors.
           }
        }
        
//        let curentTime = NSDate.init(timeIntervalSinceNow: 3600)
//
//        let content = UNMutableNotificationContent()
//        content.title = NSLocalizedString("kFreemiumWarning", comment: "")
//        content.body = NSLocalizedString("kFreemiumExpiredMessage", comment: "")
//        content.sound = UNNotificationSound.default
//        content.badge = 1
//
//        let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: timeFireAtDate)
//
//        _ = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
    }
    
    
    private func pushDailyTrackingNotification () {
        
        let notificationCenter = UNUserNotificationCenter.current()
        
        // remove pending Notification
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [kDailyTrackingNotification.rawValue])
        
        // Fire in 23 hours
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: (23*60*60), repeats: false)
        
        //create content
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("kDailyLoginTitle", comment: "")
        content.body = NSLocalizedString("kDailyLoginMessage", comment: "")
        content.sound = .default
        
        // Create the request
        let uuidString = kDailyTrackingNotification.rawValue
        let request = UNNotificationRequest(identifier: uuidString,
                                            content: content,
                                            trigger: trigger)
        
        // Schedule the request with the system.
        notificationCenter.add(request) { (error) in
            if error != nil {
                // Handle any errors.
            }
        }
    }
    
    func presentAlertForCase(title: String, message: String) {
        
        if message == kAPICancelled {
            return
        }
        
        let alertVC = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""), style: .default)
        { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        
        alertVC.addAction(okAction)
        
        if let presentedVC = self.presentedViewController {
            
            if presentedVC is UIAlertController {
                return
            }
            
            presentedVC.present(alertVC, animated: true, completion: nil)
            return
        } else {
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentAlertForFreemium() {
        let alertVC = UIAlertController.init(title: NSLocalizedString("kFreemiumWarning", comment: ""), message: NSLocalizedString("kFreemiumMessage", comment: ""), preferredStyle: .alert)
        let cancelAction = UIAlertAction.init(title: NSLocalizedString("kCancelAction", comment: ""), style: .cancel) { (action) in
            alertVC.dismiss(animated: true, completion: nil)
        }
        alertVC.addAction(cancelAction)
        
        if let presentedVC = self.presentedViewController
        {
            let okAction = UIAlertAction.init(title: NSLocalizedString("kUpgradeAction", comment: ""), style: .default)
            { (action) in
                alertVC.dismiss(animated: true, completion: nil)
                
                let iapVC = VC_InAppPurchase()
                iapVC.presentingType = .presenting
                presentedVC.present(iapVC, animated: true, completion: nil)
            }
            alertVC.addAction(okAction)
            presentedVC.present(alertVC, animated: true, completion: nil)
        } else {
            let okAction = UIAlertAction.init(title: NSLocalizedString("kUpgradeAction", comment: ""), style: .default)
            { (action) in
                alertVC.dismiss(animated: true, completion: nil)
                
                let iapVC = VC_InAppPurchase()
                iapVC.presentingType = .presenting
                self.present(iapVC, animated: true, completion: nil)
            }
            
            alertVC.addAction(okAction)
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    var reachabilityAlertVC : UIAlertController?
    func presentAlertForNetworkRechability() {
        
        if reachabilityAlertVC != nil { return }
        
        reachabilityAlertVC = UIAlertController.init(title: NSLocalizedString("kNoInternetTitle", comment: ""), message: NSLocalizedString("kNoInternetMessage", comment: ""), preferredStyle: .alert)
        
        guard let alertVC = self.reachabilityAlertVC else {return}
        
        let settingsBtn = UIAlertAction.init(title: NSLocalizedString("kSettings", comment: ""), style: .cancel)
        { (action) in
            alertVC.dismiss(animated: true, completion: nil)
            self.reachabilityAlertVC = nil
            
            let application = UIApplication.shared
            if let url = URL(string: UIApplication.openSettingsURLString), application.canOpenURL(url)    {
                application.open(url, options: [:], completionHandler: nil)
            }
        }
        
        alertVC.addAction(settingsBtn)
        
        if let presentedVC = self.presentedViewController {
            if !_AppDataHandler.getUserProfile().isFreemiumUser() {
                let offlineModeBtn = UIAlertAction.init(title: NSLocalizedString("kOfflineModeBtn", comment: ""), style: .default)
                { (action) in
                    alertVC.dismiss(animated: true, completion: nil)
                    self.reachabilityAlertVC = nil
                    
                    presentedVC.dismiss(animated: false, completion: nil)
                    let offlineScreen = VC_UserDownloadedVideos()
                    _NavController.setViewControllers([offlineScreen], animated: true)
                }
                alertVC.addAction(offlineModeBtn)
            }
            presentedVC.present(alertVC, animated: true, completion: nil)
            
        } else {
            if !_AppDataHandler.getUserProfile().isFreemiumUser() {
                let offlineModeBtn = UIAlertAction.init(title: NSLocalizedString("kOfflineModeBtn", comment: ""), style: .default)
                { (action) in
                    alertVC.dismiss(animated: true, completion: nil)
                    self.reachabilityAlertVC = nil
                    
                    let offlineScreen = VC_UserDownloadedVideos()
                    _NavController.setViewControllers([offlineScreen], animated: true)
                }
                alertVC.addAction(offlineModeBtn)
            }
            
            self.present(alertVC, animated: true, completion: nil)
        }
    }
    
    func presentAlertUnauthorized() {
        
        if let presentedVC = self.presentedViewController {
            let alertVC = UIAlertController.init(title: NSLocalizedString("kAnotherDeviceTitle", comment: ""),
                                                 message: NSLocalizedString("kAnotherDeviceMessage", comment: ""),
                                                 preferredStyle: .alert)
            let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                              style: .cancel) { (action) in
                                                alertVC.dismiss(animated: true, completion: nil)
                                                presentedVC.dismiss(animated: false, completion: nil)
                                                _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
            }
            alertVC.addAction(okAction)
            presentedVC.present(alertVC, animated: true, completion: nil)
            return
        }
        
        let alertVC = UIAlertController.init(title: NSLocalizedString("kAnotherDeviceTitle", comment: ""),
                                             message: NSLocalizedString("kAnotherDeviceMessage", comment: ""),
                                             preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: NSLocalizedString("kOkAction", comment: ""),
                                          style: .cancel) { (action) in
                                            alertVC.dismiss(animated: true, completion: nil)
                                            _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
        }
        alertVC.addAction(okAction)
        _NavController.present(alertVC, animated: true, completion: nil)
    }
    
    //Check App Login
    var countTracking       = 0
    var timerTracking       : Timer?
    
    func dailyTrackingAccess(forceRefesh: Bool) {
        
        if _AppDataHandler.getSessionDataSource() == nil {
            self.timerTracking?.invalidate()
            self.timerTracking = nil
            self.countTracking = 0
            return
        }
        
        if forceRefesh {
            countTracking = 0
        }
        
        countTracking += 1
        
        if countTracking == 5 {
            self.timerTracking?.invalidate()
            self.timerTracking = nil
            self.countTracking = 0
            
            let dailyAlertVC = UIAlertController.init(title: NSLocalizedString("kTrackingUserStreaksTitle", comment: ""),
                                                    message: NSLocalizedString("kTrackingUserStreaksMessage", comment: ""),
                                                    preferredStyle: .alert)
            let cancelAction = UIAlertAction.init(title: NSLocalizedString("kTrackingUserStreaksCancelBtn", comment: ""),
                                                  style: .cancel) { (action) in
                                                    dailyAlertVC.dismiss(animated: true, completion: nil)
            }
            let retryAction = UIAlertAction.init(title: NSLocalizedString("kTrackingUserStreaksRetryBtn", comment: ""),
                                                 style: .default) { (action) in
                                                    dailyAlertVC.dismiss(animated: true, completion: nil)
                                                    self.dailyTrackingAccess(forceRefesh: true)
            }
            dailyAlertVC.addAction(cancelAction)
            dailyAlertVC.addAction(retryAction)
            self.present(dailyAlertVC, animated: true, completion: nil)
            
            return
        }
        
        self.timerTracking = Timer.scheduledTimer(withTimeInterval: 60,
                                                  repeats: false,
                                                  block: { (timer) in
                                                    _AppDataHandler.trackingUserStreak { (isSuccess, error) in
                                                        if isSuccess {
                                                            
                                                            self.timerTracking?.invalidate()
                                                            self.timerTracking = nil
                                                            self.countTracking = 0
                                                            self.pushDailyTrackingNotification()
                                                        } else {
                                                            self.dailyTrackingAccess(forceRefesh: false)
                                                        }
                                                    }
        })
    }
}

