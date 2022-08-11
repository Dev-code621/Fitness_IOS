//
//  RCFirebase.swift
//  NewTRS
//
//  Created by yaya on 10/29/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import Foundation
import Firebase

enum ValueKey: String {
    case kGoogleClientID
    case kBaseURL
    case kAppStoreReleaseURL
    case kBaseURLPolicy
    case kBaseURLHelp
}

class RCFirebase {
    
    static let shared = RCFirebase()
    
    private init () {
        loadDefaultValues()
        fetchCloudValues()
    }
    
    func loadDefaultValues() {
        let appDefaults: [String: Any?] = [
            ValueKey.kGoogleClientID.rawValue : "212450975274-r252ec92583vtjll0luh6ipa1bsdejp8.apps.googleusercontent.com",
            ValueKey.kBaseURL.rawValue : "https://thereadystate.com/wp-json/cbidigital/v2",
            ValueKey.kAppStoreReleaseURL.rawValue : "https://apps.apple.com/us/app/id1513867112",
            ValueKey.kBaseURLPolicy.rawValue : "https://thereadystate.com/privacy_policy",
            ValueKey.kBaseURLHelp.rawValue : "https://thereadystate.com/help"
        ]
        RemoteConfig.remoteConfig().setDefaults(appDefaults as? [String: NSObject])
    }
    
    func fetchCloudValues() {
      // 1
      // WARNING: Don't actually do this in production!
      let fetchDuration: TimeInterval = 0
      RemoteConfig.remoteConfig().fetch(withExpirationDuration: fetchDuration) { status, error in

        if let error = error {
          print("Uh-oh. Got an error fetching remote values \(error)")
          return
        }

        // 2
        RemoteConfig.remoteConfig().activate(completion: nil)
        
      //  print("Our app's primary is \(String(describing: RemoteConfig.remoteConfig().configValue(forKey: ValueKey.kGoogleClientID.rawValue).stringValue))")
      }
    }
    
    func getRemoteConfigKey(key: String) -> String {
        return RemoteConfig.remoteConfig().configValue(forKey: key).stringValue!
    }
}
