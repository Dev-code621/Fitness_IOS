//
//  ApplicationMacros.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

//MARK: - Import 3rd party
import Foundation
import SDWebImage
import SnapKit
import ObjectMapper
import FirebaseRemoteConfig

// MARK: Header
let _AppDelegate            = AppDelegate.sharedInstance
let _NavController          = _AppDelegate.appNavigation
let _AppDataHandler         = _AppDelegate.appDataHandler
let _AppPaymentManager      = ApplicationPayment.shared
let _AppVideoManager        = _AppDelegate.appVideoManager
let _AppCoreData            = _AppDelegate.appCoreData
let _RemoteConfig           =  RCFirebase.shared

let kAppleUserFullName          = "kAppleUserFullName"
let kAppleUserEmail             = "kAppleUserEmail"
let kUserSessionDataSource      = "kUserSessionDataSource"
let kUserDownloadedData         = "kUserDownloadedData"
let kUserStreaksData            = "kUserStreaksData"

let kUserDailySurvey            = "kUserDailySurvey"
let kUserPainTooltips           = "kUserPainTooltips"
let kUserMobilityIntroSkip      = "kUserMobilityIntroSkip"
let kUserMobilityKellySkip      = "kUserMobilityKellySkip"
let kUserSignUpIntroSkip        = "kUserSignUpIntroSkip"

let kAPICancelled               = "kAPICancelled"
let kUserPendingReceipt         = "kUserPendingReceipt"  // thanh toán bị treo nên gói của bạn chưa được update.

let kGoogleClientID             = _RemoteConfig.getRemoteConfigKey(key:ValueKey.kGoogleClientID.rawValue)
let kBaseURL                    = _RemoteConfig.getRemoteConfigKey(key:ValueKey.kBaseURL.rawValue)
let kAppStoreReleaseURL         = _RemoteConfig.getRemoteConfigKey(key:ValueKey.kAppStoreReleaseURL.rawValue)
let kBaseURLPolicy              = _RemoteConfig.getRemoteConfigKey(key:ValueKey.kBaseURLPolicy.rawValue)
let kBaseURLHelp                = _RemoteConfig.getRemoteConfigKey(key:ValueKey.kBaseURLHelp.rawValue)

let kIsProductionReleaseMode    = true

//Motification Name
let kMobilityNeedReloadNotification     = Notification.Name("kMobilityNeedReloadNotification")
let kUserProfileHasChangeNotification   = Notification.Name("kUserProfileHasChangeNotification")
let kNetwordHasChangeNotification       = Notification.Name("kNetwordHasChangeNotification")
let kDownloadVideoCancelNotification    = Notification.Name("kDownloadVideoCancelNotification")
let kDownloadVideoDoneNotification      = Notification.Name("kDownloadVideoDoneNotification")
let kDownloadVideoDeletedNotification   = Notification.Name("kDownloadVideoDeletedNotification")
let kWatchVideoDoneNotification         = Notification.Name("kWatchVideoDoneNotification") // xem xong hết clip ở bonus content
let kWatchPreVideoNotification          = Notification.Name("kWatchPreVideoNotification")
let kDailyTrackingNotification          = Notification.Name("kDailyTrackingNotification")

//MARK: Filter
let kZeroMinsFilter                     = 0
let kTenMaxFilter                       = 659
let kTenMinsFilter                      = 660
let kTwentyMaxFilter                    = 1259
let kTwentyMinsFilter                   = 1260
let kThirtyMaxFilter                    = 1859
let kThirtyMinsFilter                   = 1860
let kAllMinsFilter                      = 600000
let kFifteenMaxFilter                   = 899
let kFifteenMinsFilter                  = 900
let kTwentyFiveMaxFilter                = 1499
let kTwentyFiveMinsFilter               = 1500
let kThirtyFiveMaxFilter                = 2099
let kThirtyFiveMinsFilter               = 2100
