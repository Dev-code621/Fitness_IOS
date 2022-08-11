//
//  AppDelegate.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import CoreData
import GoogleSignIn
import Firebase
import FBSDKCoreKit
import SwiftyStoreKit
import AVKit
import IQKeyboardManagerSwift
import AppTrackingTransparency
@_exported import BugfenderSDK
import UserNotifications
import GoogleCast

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessagingDelegate, UNUserNotificationCenterDelegate {
    
    static let sharedInstance       = UIApplication.shared.delegate as! AppDelegate
    var appNavigation               = AppNavigationController()
    let appDataHandler              = AppDataHandler()
    let appVideoManager             = ApplicationVideoManager()
    let appCoreData                 = ApplicationCoreData()
    var window                      : UIWindow?
    let kReceiverAppID              = kGCKDefaultMediaReceiverApplicationID
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        //Config Google Services
        FirebaseApp.configure()
        GIDSignIn.sharedInstance().clientID = kGoogleClientID
        
        //Config Firebase
        UIApplication.shared.applicationIconBadgeNumber = 0
        Messaging.messaging().delegate = self
        if #available(iOS 10.0, *) {
            // For iOS 10 display notification (sent via APNS)
            UNUserNotificationCenter.current().delegate = self
            
            let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
            UNUserNotificationCenter.current().requestAuthorization(
                options: authOptions,
                completionHandler: {_, _ in })
        } else {
            let settings: UIUserNotificationSettings =
                UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: nil)
            application.registerUserNotificationSettings(settings)
        }
        
        application.registerForRemoteNotifications()
        
        //Config Facebook Services
        Settings.isAutoLogAppEventsEnabled = true
        Settings.isAdvertiserIDCollectionEnabled = false
        ApplicationDelegate.shared.application( application, didFinishLaunchingWithOptions: launchOptions)
        
        //Payment Manager
        _AppPaymentManager.configPayment()
        
        //Application Download Manager COnfig
        _AppVideoManager.checkDoneDownloadManager()
        
        //Application CoreData
        _AppCoreData.startContext()
        
        //Naviagtion
        let lunchScreenVC = VC_SubPageLunchSceen()
        self.appNavigation = AppNavigationController.init(rootViewController: lunchScreenVC)
        self.appNavigation.setNavigationBarHidden(true, animated: false)
        
        self.window = UIWindow.init(frame: UIScreen.main.bounds)
        self.window?.rootViewController = self.appNavigation
        self.window?.makeKeyAndVisible()
        IQKeyboardManager.shared.enable = true
        
        Bugfender.activateLogger("SfGcA8yQJGbvrbPBtNzhvMhUTebt1nJ7")
        Bugfender.enableCrashReporting()
      //  Bugfender.enableUIEventLogging() // optional, log user interactions automatically
        
        //daily tracking 23h
        _NavController.dailyTrackingAccess(forceRefesh: false)
        
        //google cast
        let discoveryCriteria = GCKDiscoveryCriteria(applicationID: kReceiverAppID)
        let castOptions = GCKCastOptions(discoveryCriteria: discoveryCriteria)
        GCKCastContext.setSharedInstanceWith(castOptions)
        GCKLogger.sharedInstance().delegate = self
        return true
    }
    
    func application( _ app: UIApplication,
                      open url: URL,
                      options: [UIApplication.OpenURLOptionsKey : Any] = [:] ) -> Bool
    {
        if (kIsProductionReleaseMode == false) {
            if url.absoluteString.contains("consolelogviewer") {
                
                do {
                    var schemaString = "consolelogviewer:thereadystate"
                    
                    let fm = FileManager.default
                    let path = fm.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent("console_log.txt")
                    let string = try String(contentsOf: path)
                    
                    let data = Data(string.utf8)
                    schemaString.append("?param="+data.base64EncodedString())
                    
                    if let schemaLink = URL(string: schemaString) {
                        if UIApplication.shared.canOpenURL(schemaLink) {
                            UIApplication.shared.open(schemaLink)
                        }
                    }
                    
                    // Clear log
                    ConsoleLog.consoleLog.clear()
                }
                catch {
                    
                }
            }
        }
        
        return ApplicationDelegate.shared.application( app,
                                                open: url,
                                                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                                                annotation: options[UIApplication.OpenURLOptionsKey.annotation] )
    }
    
    func applicationDidBecomeActive(_ application: UIApplication) {
        
        let current = UNUserNotificationCenter.current()
                current.getNotificationSettings(completionHandler: { permission in
                    switch permission.authorizationStatus  {
                    case .authorized:
                        print("User granted permission for notification")
                        self.trakingApp()
                    case .denied:
                        print("User denied notification permission")
                        self.trakingApp()
                    case .notDetermined:
                        print("Notification permission haven't been asked yet")
                    case .provisional:
                        // @available(iOS 12.0, *)
                        print("The application is authorized to post non-interruptive user notifications.")
                    case .ephemeral:
                        // @available(iOS 14.0, *)
                        print("The application is temporarily authorized to post notifications. Only available to app clips.")
                    @unknown default:
                        print("Unknow Status")
                    }
                })
        do {
              try AVAudioSession.sharedInstance().setCategory(.playback)
           } catch(let error) {
               print(error.localizedDescription)
           }
    }
    
    func trakingApp() {
        if #available(iOS 14.0, *) {
            ATTrackingManager.requestTrackingAuthorization { (status) in
                switch status {
                case .authorized :
                    AppEvents.activateApp()
                default:
                    break
                }
            }
        } else {
            AppEvents.activateApp()
        }
    }
    
    func applicationWillTerminate(_ application: UIApplication) {
        _AppVideoManager.syncDownloadingData()
    }
    
    func applicationDidEnterBackground(_ application: UIApplication) {
        _AppVideoManager.syncDownloadingData()
    }
    
    func applicationWillEnterForeground(_ application: UIApplication) {
        _NavController.dailyTrackingAccess(forceRefesh: true)
    }
    
    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        _AppVideoManager.getBackgroundSessionCompletionHandler(completionHandler: completionHandler)
    }
    
    //MARK: - MessagingDelegate
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        //
    }
    
//    // MARK: UISceneSession Lifecycle
//
//    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
//        // Called when a new scene session is being created.
//        // Use this method to select a configuration to create the new scene with.
//        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
//    }
//
//    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
//        // Called when the user discards a scene session.
//        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
//        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
//    }
    
    // MARK: - Core Data stack
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "NewTRS")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
}

extension AppDelegate: GCKLoggerDelegate {

    func logMessage(_ message: String, at level: GCKLoggerLevel, fromFunction function: String, location: String) {
        print("Message from Chromecast = \(message)")
    }
}
