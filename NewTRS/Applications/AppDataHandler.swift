//
//  AppDataHandler.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/4/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit
import Alamofire
import ObjectMapper
import Firebase
import SwiftyStoreKit

class AppDataHandler: NSObject {
    
    private var sessionDataSource       : UserTRSToken?
    private var userProfile             : UserProfileDataSource? = UserProfileDataSource.init(JSONString: "{}")
    var tokenTimer                      : Timer?
    var userPlanTimer                   : Timer?
    var statusQuiz                      : Bool = false
    
    //Alarmofire
    var alamofireManager                : SessionManager = {
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 60
        configuration.timeoutIntervalForResource = 60
        let alamofire = Alamofire.SessionManager(configuration: configuration)
        return alamofire
    }()
    
    override init() {
        super.init()
        
        if (UserDefaults.standard.object(forKey: kUserSessionDataSource) is String) {
            if let data = UserDefaults.standard.object(forKey: kUserSessionDataSource) as? String {
                let sessionData = UserTRSToken.init(JSONString: data)
                if sessionData != nil {
                    self.sessionDataSource = sessionData
                }
                else {
                    UserDefaults.standard.removeObject(forKey: kUserSessionDataSource)
                }
            }
        }
        else {
            UserDefaults.standard.removeObject(forKey: kUserSessionDataSource)
        }
        
    }
    
    func getSessionDataSource() -> UserTRSToken? {
        return self.sessionDataSource
    }
    
    func setSessionDataSource (_ newObject: UserTRSToken) {
        
        //Save updated token
        self.sessionDataSource = newObject
        
        let curentTime = NSDate().timeIntervalSince1970
        let timeInterval = newObject.expirationTime - 120 - Int(curentTime) // 120 seconds is time to get new token
        
        if timeInterval >= 0
        {
            self.tokenTimer = Timer.scheduledTimer(timeInterval: TimeInterval(timeInterval),
                                                   target: self,
                                                   selector: #selector(autoRefreshToken),
                                                   userInfo: nil,
                                                   repeats: false)
        }
        
        //Get User Profile
        self.reloadUserProfile()
        
        // Send user fcmToken
        self.sendFCMToken { (isSuccess, error) in
            print(error)
        }
        
        //Get user Mobility Video
        self.getListMobilityVideoSource { (isSuccess, error) in
            print(error)
        }
        
        UserDefaults.standard.set(newObject.toJSONString(), forKey: kUserSessionDataSource)
    }
    
    func getUserProfile() -> UserProfileDataSource {
        if self.userProfile != nil {
            return self.userProfile!
        }
        return UserProfileDataSource.init(JSONString: "{}")!
    }
    
    func setUserProfile(newProfile: UserProfileDataSource) {
        self.userProfile = newProfile
        
        self.trackingUserPremium()
        NotificationCenter.default.post(name: kUserProfileHasChangeNotification, object: nil)
    }
    
    deinit {
        self.tokenTimer?.invalidate()
        self.userPlanTimer?.invalidate()
    }
    
    //MARK: - Handle Status Code
    private func handleResponseDict (response:DataResponse<Any>, requestParam: [String: Any]? = nil) -> ResponseData?
    {
        if let urlRequest = response.request?.url?.path {
            bfprint(String(format: "Lucas-API-URL-Request: %@", urlRequest), tag: "API-Response", level: .default)
        }
        
        if requestParam != nil {
            bfprint(String(format: "Lucas-API-Request-Param: %@", requestParam!), tag: "API-Response", level: .default)
        }
        
        if let header = response.request?.allHTTPHeaderFields {
            bfprint(String(format: "Lucas-API-Header-Request: %@", header), tag: "API-Response", level: .default)
        }
        
        switch(response.result) {
        case .success(_):
            
            bfprint("handleResponseDict_success", tag: "API-Response", level: .default)

            if var urlRequest = response.request?.url?.absoluteString {
                
                urlRequest = urlRequest.replacingOccurrences(of: kBaseURL, with: "")
                #if DEBUG
                print("API Response:", urlRequest)
                #else
                print("API Response:", Date(), urlRequest, to: &ConsoleLog.consoleLog)
                #endif
                
            }
            
            if response.response!.statusCode < 300 {
                #if DEBUG
                print("Lucas-API-Success:", "Did get \(response.response!.statusCode) success code")
                #else
                print("Lucas-API-Success:", Date(), "Did get \(response.response!.statusCode) success code", to: &ConsoleLog.consoleLog)
                #endif
                
            }
            else if response.response!.statusCode < 400 {
                #if DEBUG
                print("Lucas-API-Error:", "Did get \(response.response!.statusCode) error code")
                #else
                print("Lucas-API-Error:", Date(), "Did get \(response.response!.statusCode) error code", to: &ConsoleLog.consoleLog)
                #endif
                
            } else if response.response!.statusCode < 500 {
                #if DEBUG
                print("Lucas-API-Error:", "Did get \(response.response!.statusCode) error code")
                #else
                print("Lucas-API-Error:", Date(), "Did get \(response.response!.statusCode) error code", to: &ConsoleLog.consoleLog)
                #endif
                
                if response.response!.statusCode == 401 {
                    //User expried token
                    self.signout()
                    
                    _NavController.presentAlertUnauthorized()
                    
                    return nil
                } else if response.response!.statusCode == 403 {
                    //User expried token
                    
                    self.reloadUserProfile()
                    
                    var tempResponse = ResponseData.init(JSONString: "{}")!
                    tempResponse.isSuccess = false
                    tempResponse.message = "You do not have permission to do. Please check your account subscription."
                    return tempResponse
                }
                
            } else if response.response!.statusCode < 600 {
                #if DEBUG
                print("Lucas-API-Error:", "Did get \(response.response!.statusCode) error code")
                #else
                print("Lucas-API-Error:", Date(), "Did get \(response.response!.statusCode) error code", to: &ConsoleLog.consoleLog)
                #endif
            }
            
            guard let responseDict = response.result.value as? [String : Any] else {
                var tempResponse = ResponseData.init(JSONString: "{}")!
                tempResponse.isSuccess = false
                tempResponse.message = NSLocalizedString("kAPIFailToParse", comment: "")
                
                return tempResponse
            }
            
            let finalResponse = Mapper<ResponseData>().map(JSON: responseDict)
            
            #if DEBUG
//            print("Lucas-API-Data-Response:", finalResponse?.toJSONString() ?? "")
            #else
            print("Lucas-API-Data-Response:", Date(), finalResponse?.toJSONString() ?? "", to: &ConsoleLog.consoleLog)
            #endif
            
            return finalResponse
            
        case .failure(let error):
            
            if var urlRequest = response.request?.url?.absoluteString {
                
                urlRequest = urlRequest.replacingOccurrences(of: kBaseURL, with: "")
                #if DEBUG
                 print("API Request:", urlRequest)
                #else
                print("API Request:", Date(), urlRequest, to: &ConsoleLog.consoleLog)
                #endif
            }
            
            var failResponse = ResponseData.init(JSONString: "{}")!
            failResponse.message = response.result.error?.localizedDescription ?? ""
            
            if error._code == NSURLErrorTimedOut {
                failResponse.message = NSLocalizedString("kAPIErrorTimeOut", comment: "")
            } else if error._code == NSURLErrorCancelled {
                failResponse.message = kAPICancelled
            } else if error._code == NSURLErrorNotConnectedToInternet {
                failResponse.message = "We're having difficulty connecting to the internet. Please check your connection."
                failResponse.errorCode = NSURLErrorNotConnectedToInternet
            } else if error._code == NSURLErrorCannotParseResponse {
                failResponse.message = NSLocalizedString("kAPIFailToParse", comment: "")
            } else if failResponse.message.contains("JSON could not be serialized because of error") {
                failResponse.message = NSLocalizedString("kAPIFailToParse", comment: "")
            }
            
            #if DEBUG
            print("API Request:",failResponse.toJSONString() ?? "")
            #else
            print("API Request:", Date(), failResponse.toJSONString() ?? "", to: &ConsoleLog.consoleLog)
            #endif
            
            return failResponse
        }
    }
    
    //MARK: - Authentications
    
    @objc func autoRefreshToken() {
        
        guard let userRefreshToken = sessionDataSource?.refreshToken else {
            _AppDataHandler.signout()
            _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
            return
        }
        
       let _ = self.renewToken(oldRefreshToken: userRefreshToken) { (isSuccess, error)  in
            if isSuccess {
                print("Token refreshed!!")
            } else {
                _AppDataHandler.signout()
                _NavController.presentAlertForCase(title: NSLocalizedString("kSignInFailTitle", comment: ""),
                                                   message: error)
                _NavController.setViewControllers([VC_SignUpInAuthentication()], animated: true)
            }
        }
    }
    
    func renewToken(oldRefreshToken : String,
                    completion:@escaping (Bool, String)->()) -> Request? {
        
        let parameters : [String:Any] = ["refresh_token":oldRefreshToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/refresh_token"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameters), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/user/refresh_token",
                                      method: .post,
                                      parameters: parameters,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameters) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message)
                    return
                }
                
                guard let userTokenDict = responseData.objectData?["user_token"] as? [String:Any] else {
                    completion (responseData.isSuccess, responseData.message)
                    return
                }
                guard let sessionDataSource = Mapper<UserTRSToken>().map(JSON: userTokenDict) else {
                    completion (responseData.isSuccess, responseData.message)
                    return
                }
                self.setSessionDataSource(sessionDataSource)
                
                guard let userProfileDict = responseData.objectData?["user_profile"] as? [String:Any] else {
                    completion (responseData.isSuccess, responseData.message)
                    return
                }
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(true, responseData.message)
        }
        return request
    }
    
    @objc func warningExpiredUserPlan() {
        _NavController.presentAlertForCase(title: NSLocalizedString("kFreemiumWarning", comment: ""),
                                           message: NSLocalizedString("kFreemiumExpiredMessage", comment: ""))
        if self.userProfile != nil {
            self.setUserProfile(newProfile: self.userProfile!)
        }
    }
    
    func signout() {
        self.sessionDataSource = nil
        self.userProfile = nil
        UserDefaults.standard.removeObject(forKey: kUserSessionDataSource)
        //remove clean user streaks
        UserDefaults.standard.removeObject(forKey: kUserStreaksData)
        //remove clean user watch later sign up
        UserDefaults.standard.removeObject(forKey: kUserSignUpIntroSkip)
        //remove daily
        UserDefaults.standard.removeObject(forKey: kUserDailySurvey)
        //remove lastest receipt
        UserDefaults.standard.removeObject(forKey: kUserPendingReceipt)
    }
    
    func signInWithTRSAccount(email: String,
                              password: String,
                              completion:@escaping (Bool,String,ResponseData?)->()) {
        let parametters : [String: Any] = ["email":email,
                                           "password":password]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/trs_sign_in"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/user/trs_sign_in",
                                      method: .post,
                                      parameters: parametters,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametters) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""),nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, responseData)
                    return
                }
                
                guard let userTokenDict = responseData.objectData?["user_token"] as? [String:Any] else {
                    return
                }
                guard let sessionDataSource = Mapper<UserTRSToken>().map(JSON: userTokenDict) else {
                    return
                }
                self.setSessionDataSource(sessionDataSource)
                
                guard let userProfileDict = responseData.objectData?["user_profile"] as? [String:Any] else {
                    return
                }
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(true, responseData.message,responseData)
        }
    }
    
    func signUpWithTRSAccount(email: String,
                              password: String,
                              completion:@escaping (Bool,String,ResponseData?)->()) {
        let parametters : [String: Any] = ["email":email,
                                           "password":password]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/trs_sign_up"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/user/trs_sign_up",
                                      method: .post,
                                      parameters: parametters,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametters) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""),nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, responseData)
                    return
                }
                
                guard let userTokenDict = responseData.objectData?["user_token"] as? [String:Any] else {
                    return
                }
                guard let sessionDataSource = Mapper<UserTRSToken>().map(JSON: userTokenDict) else {
                    return
                }
                self.setSessionDataSource(sessionDataSource)
                
                guard let userProfileDict = responseData.objectData?["user_profile"] as? [String:Any] else {
                    return
                }
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(true, responseData.message,responseData)
        }
    }
    
    func signInWithGoogleAccount(googleToken: String,
                                 completion:@escaping (Bool,String,ResponseData?)->()) {
        let parametters : [String: Any] = ["google_token":googleToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/google_authenticate"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/user/google_authenticate",
                                      method: .post,
                                      parameters: parametters,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response,requestParam: parametters) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""),nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, responseData)
                    return
                }
                
                guard let userTokenDict = responseData.objectData?["user_token"] as? [String:Any] else {
                    return
                }
                guard let sessionDataSource = Mapper<UserTRSToken>().map(JSON: userTokenDict) else {
                    return
                }
                self.setSessionDataSource(sessionDataSource)
                
                
                guard let userProfileDict = responseData.objectData?["user_profile"] as? [String:Any] else {
                    return
                }
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(true, responseData.message,responseData)
        }
    }
    
    func signInWithFacebookAccount(facebookToken: String,
                                   completion:@escaping (Bool,String,ResponseData?)->()) {
        let parametters : [String: Any] = ["facebook_token":facebookToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/facebook_authenticate"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/user/facebook_authenticate",
                                      method: .post,
                                      parameters: parametters,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametters) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""),nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message,responseData)
                    return
                }
                
                guard let userTokenDict = responseData.objectData?["user_token"] as? [String:Any] else {
                    return
                }
                guard let sessionDataSource = Mapper<UserTRSToken>().map(JSON: userTokenDict) else {
                    return
                }
                self.setSessionDataSource(sessionDataSource)
                
                
                guard let userProfileDict = responseData.objectData?["user_profile"] as? [String:Any] else {
                    return
                }
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(true, responseData.message,responseData)
        }
    }
    
    func signInWithAppleAccount(appleToken: String,
                                completion:@escaping (Bool,String,ResponseData?)->()) {
        let parametters : [String: Any] = ["apple_token":appleToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/apple_autheticate"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/user/apple_autheticate",
                                      method: .post,
                                      parameters: parametters,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametters) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""),nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, responseData)
                    return
                }
                
                guard let userTokenDict = responseData.objectData?["user_token"] as? [String:Any] else {
                    return
                }
                guard let sessionDataSource = Mapper<UserTRSToken>().map(JSON: userTokenDict) else {
                    return
                }
                self.setSessionDataSource(sessionDataSource)
                
                
                guard let userProfileDict = responseData.objectData?["user_profile"] as? [String:Any] else {
                    return
                }
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(true, responseData.message,responseData)
        }
    }
    
    func forgotPasswordByEmail(email: String,
                               completion:@escaping (Bool, String)->()) {
        let parameter = ["email":email]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/get_otp"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/user/get_otp",
                                      method: .post,
                                      parameters: parameter,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
    }
    
    func forgotPassword(OTPcode: String,
                        password: String,
                        email: String,
                        completion:@escaping (Bool,String)->()) {
        let parameter = ["password":password,
                         "otp_id":OTPcode,
                         "email": email]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/user/trs_change_pass"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)

        self.alamofireManager.request(kBaseURL+"/user/trs_change_pass",
                                      method: .post,
                                      parameters: parameter,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
    }
    
    func changePassword(password: String,
                        newPassword: String,
                        confirmPassword: String,
                        completion:@escaping (Bool,String)->()) -> Request? {
        let parameter = ["old_password":password,
                         "new_password":newPassword,
                         "rematch_new_password": confirmPassword]
                
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session")
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID")
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/update_new_password"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/user/update_new_password",
                                      method: .post,
                                      parameters: parameter,
                                      encoding: JSONEncoding.default,
                                      headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
        return request
    }
    
    //MARK: - Systems apis
    func checkAppStore(completion:@escaping ( String?)->()) -> Request?{
        let ourBundleId = Bundle.main.infoDictionary!["CFBundleIdentifier"] as! String
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", "https://itunes.apple.com/lookup?bundleId=\(ourBundleId)"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request("https://itunes.apple.com/lookup?bundleId=\(ourBundleId)")
            .responseJSON
            { response in
                                
                if let json = response.result.value as? NSDictionary,
                    let results = json["results"] as? NSArray,
                    let entry = results.firstObject as? NSDictionary,
                    let appVersion = entry["version"] as? String
                {
                    completion(appVersion)
                    return
                }
                
                completion(nil)
        }
        return request
    }
    
    func checkForceUpdate(completion:@escaping (Bool, String, ResponseData?) -> ()) -> Request?{
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/system/config"), tag: "API-Request", level: .default)

        let request = self.alamofireManager.request(kBaseURL+"/system/config",
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion (false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                completion(responseData.isSuccess, responseData.message, responseData)
        }
        return request
    }
    
    func getListFocusAreas(completion:@escaping (Bool, String)-> ()) -> Request? {
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/system/areas"), tag: "API-Request", level: .default)

        let request = self.alamofireManager.request(kBaseURL+"/system/areas",
                                                    method: .get,
                                                    parameters: nil,
                                                    encoding: URLEncoding.default,
                                                    headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message)
                    return
                }
                
                if responseData.objectList.count > 0 {
                    let listSystemFocusAreas = Mapper<SystemFocusAreaDataSource>().mapArray(JSONArray: responseData.objectList)
                    _AppCoreData.insertSystemFocusAreas(list: listSystemFocusAreas)
                    completion(true, responseData.message)
                }
        }
        return request
    }
    
    // api filter Areas
    func getListFilterAreas(completion:@escaping (Bool, String)-> ()) -> Request? {
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/system/areas_filtered_by_daily_mainternance"), tag: "API-Request", level: .default)

        let request = self.alamofireManager.request(kBaseURL+"/system/areas_filtered_by_daily_mainternance",
                                                    method: .get,
                                                    parameters: nil,
                                                    encoding: URLEncoding.default,
                                                    headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                                                        guard let responseData = self.handleResponseDict(response: response) else {
                                                            //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                                                            return
                                                        }
                                                        
                                                        if !responseData.isSuccess {
                                                            completion(responseData.isSuccess, responseData.message)
                                                            return
                                                        }
                                                        
                                                        if responseData.objectList.count > 0 {
                                                            let listSystemFilterAreas = Mapper<SystemFocusAreaDataSource>().mapArray(JSONArray: responseData.objectList)
                                                            _AppCoreData.insertSystemFilterAreas(list: listSystemFilterAreas)
                                                            completion(true, responseData.message)
                                                        }
                                                    }
        return request
    }
    
    func getListPainAreas(completion:@escaping (Bool, String)-> ()) -> Request?  {
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/system/pain_areas"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/system/pain_areas",
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message)
                    return
                }
                
                if responseData.objectList.count > 0 {
                    let listSystemPainAreas = Mapper<SystemPainAreaDataSource>().mapArray(JSONArray: responseData.objectList)
                    _AppCoreData.insertSystemPainAreas(list: listSystemPainAreas)
                    completion(true, responseData.message)
                }
        }
        return request
    }
    
    func getListEquipments(completion:@escaping (Bool, String)-> ()) -> Request? {
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/system/equipments"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/system/equipments",
                                                    method: .get,
                                                    parameters: nil,
                                                    encoding: URLEncoding.default,
                                                    headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message)
                    return
                }
                
                if responseData.objectList.count > 0 {
                    let listSystemEquipments = Mapper<SystemEquipmentDataSource>().mapArray(JSONArray: responseData.objectList)
                    _AppCoreData.insertSystemEquipment(list: listSystemEquipments)
                    completion(true, responseData.message)
                }
        }
        return request
    }
    
    func getListBonus(completion:@escaping (Bool, String)-> ()) -> Request?{
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/system/bonus"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/system/bonus",
                                                    method: .get,
                                                    parameters: nil,
                                                    encoding: URLEncoding.default,
                                                    headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                guard let responseData = self.handleResponseDict(response: response) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message)
                    return
                }
                
                if responseData.objectList.count > 0 {
                    var listBonusData = Mapper<SystemBonusDataSource>().mapArray(JSONArray: responseData.objectList)
                    listBonusData = listBonusData.sorted(by: { $0.bonusId > $1.bonusId })
                    _AppCoreData.insertSystemBonus(list: listBonusData)
                    completion(true, responseData.message)
                }
        }
        return request
    }
    
    //MARK: - Apple Push Notification
    
    func sendFCMToken(completion:@escaping(Bool, String)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parametter = ["device_id":UIDevice.current.identifierForVendor?.uuidString,
                          "device_type":"ios",
                          "device_token":Messaging.messaging().fcmToken ?? ""] as! [String:String]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/notifications/register"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/notifications/register",
            method: .post,
            parameters: parametter ,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
    }
    
    //MARK: - User Profiles
    
    func reloadUserProfile() {
        let _ = self.getUserProfile { ( isSuccess, error , _) in
            if isSuccess{
                print("Reload User profile Success!!")
            } else {
                print("Reload User profile Fail: ", error)
                NotificationCenter.default.post(name: kUserProfileHasChangeNotification, object: nil) // fail call vào profile load lại data 
            }
        }
    }
    
    func getUserProfile(completion:@escaping (Bool, String, UserProfileDataSource?)-> ()) -> Request? {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session",nil)
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID",nil)
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/profile"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/user/profile",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
                  //  completion(false, "401", nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let userDict = responseData.objectData else {
                    completion(false,responseData.message, nil)
                    return
                }
                
                let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userDict)!
                self.setUserProfile(newProfile: newUserProfile)
                completion(responseData.isSuccess,responseData.message,self.userProfile)
        }
        
        return request
    }
    
    func updateUserProfile(profile : UserProfileDataSource,
                           completion:@escaping (Bool,String)-> ()) {
        
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parametter : [String: Any] = ["data":profile.toJSON()]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/update_profile"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/user/update_profile",
            method: .post,
            parameters: parametter,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametter) else {
//                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess,responseData.message)
                self.reloadUserProfile()
        }
    }
    
    func getInitialQuizStatus(completion:@escaping (Bool, String, Bool)-> ()) -> Request?  {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session", false)
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID", false)
            return nil 
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/initial_survey_status"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/user/initial_survey_status",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""), false)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, false)
                    return
                }
                
                if let objectDict = responseData.objectData {
                    completion(responseData.isSuccess, responseData.message, objectDict["initial_quiz"] as? Bool ?? false)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, false)
        }
        return request
    }
    
    func sendInitialQuiz(quizData: UserQuizResults,
                         completion:@escaping (Bool, String, Bool)-> ())  {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session", false)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID", false)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameters : [String: Any] = quizData.toJSON()
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/update_initial_survey"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/user/update_initial_survey",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameters) else {
//                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""), false)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, false)
                    return
                }
                
                guard let isSuccess = responseData.objectData?["initial_quiz"] as? Bool else {
                    completion(responseData.isSuccess, responseData.message, false)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, isSuccess)
        }
    }
    
    func updateUserAvatar(image: UIImage,
                          completion:@escaping(Bool, String) ->()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID")
            return
        }
        guard let imgData = image.jpegData(compressionQuality: 0.2) else {
            completion(false,"Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
                
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/update_avatar"), tag: "API-Request", level: .default)
        
        Alamofire.upload(multipartFormData: { multipartFormData in
                multipartFormData.append(imgData, withName: "file",
                                         fileName: "file.jpg",
                                         mimeType: "image/jpg")
            },
        to:kBaseURL+"/\(userID)/user/update_avatar",
        headers: headers)
        { (result) in
            switch result {
            case .success(let upload, _, _):

                upload.uploadProgress(closure: { (progress) in
                    print("Upload Progress: \(progress.fractionCompleted)")
                })

                upload.responseJSON { response in
                    guard let responseData = self.handleResponseDict(response: response) else {
//                        completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                        return
                    }
                    
                    completion(responseData.isSuccess, responseData.message)
                    self.reloadUserProfile()
                }

            case .failure(let encodingError):
                print(encodingError)
            }
        }
    }
    
    //MARK: - Apple In-App Purchase
    
    func getListProduct(completion:@escaping (Bool, String, [ProductSubscriptionData])-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session", [])
            return
        }

        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]

        let parameters : [String:Any] = ["platform":"iOS"]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/product/subscription_user"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameters), tag: "API-Request", level: .default)
            
        // "/\(userID)/product/subscription_user"
        self.alamofireManager.request(kBaseURL+"/\(userID)/product/subscription_user",
                                      method: .get,
                                      parameters: parameters,
                                      encoding: URLEncoding.default,
                                      headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameters) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count == 0 {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count > 0 {
                    let listProducts = Mapper<ProductSubscriptionData>().mapArray(JSONArray: responseData.objectList)
                    completion(responseData.isSuccess, responseData.message, listProducts)
                }
        }
    }
    
    func uploadReceipt(receiptStr: String,
                       completion:@escaping (Bool, String)-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        UserDefaults.standard.setValue(receiptStr, forKey: kUserPendingReceipt)
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]

        var mode = "Sandbox"
        if kIsProductionReleaseMode {
            mode = "Production"
        }
        
        let parameters : [String:Any] = ["latest_receipt" : receiptStr ,
                                         "release_mode" : mode]
        self.sendLog(apiName: "product/transaction/appstore", log: parameters)
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/product/transaction/appstore"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/product/transaction/appstore",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                
                if let data = response.data {
                    let jsonString = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(String(describing: jsonString))")
                    self.sendLog(apiName: "product/transaction/appstore", log: String(describing: jsonString))
                }
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameters) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message)
                    return
                }
                
                UserDefaults.standard.removeObject(forKey: kUserPendingReceipt)
                
                if let userProfileDict = responseData.objectData {
                    if let newUserProfile = Mapper<UserProfileDataSource>().map(JSON: userProfileDict) {
                        self.setUserProfile(newProfile: newUserProfile)
                    }
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
    }
    
    func getUserTransaction(completion:@escaping ([String])-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion([])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion([])
            return
        }
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        var mode = "Sandbox"
        if kIsProductionReleaseMode {
            mode = "Production"
        }
        
        var receiptStr = ""
        
        if let lastReceipt = UserDefaults.standard.object(forKey: kUserPendingReceipt) as? String {
            receiptStr = lastReceipt
        }
        
        let parameters : [String:Any] = ["latest_receipt": receiptStr,
                                         "release_mode":mode]
        self.sendLog(apiName: "product/verify_receipt", log: parameters)
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/product/verify_receipt"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/product/verify_receipt",
            method: .post,
            parameters: parameters,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                
                if let data = response.data {
                    let jsonString = String(data: data, encoding: String.Encoding.utf8)
                    print("Failure Response: \(String(describing: jsonString))")
                    self.sendLog(apiName: "product/transaction/appstore", log: String(describing: jsonString))
                }
                
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameters) else {
                    completion([])
                    return
                }
                
                if !responseData.isSuccess {
                    completion([])
                    return
                }
                
                if let listUserTransaction = responseData.objectData?["list_original_transaction_id"] as? [String] {
                    completion(listUserTransaction)
                    return
                }
                
                completion([])
                return
        }
    }
    
    //MARK: - App Intros
    
    func getAppIntroVideos(completion:@escaping (Bool, String, [VideoDataSource]) -> ()) {
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/app/intro_videos"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/app/intro_videos",
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count == 0 {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                let videos = Mapper<VideoDataSource>().mapArray(JSONArray: responseData.objectList)
                completion(responseData.isSuccess, responseData.message, videos)
                
        }
    }
    
    //MARK: - App Reviews
    func getAppReview(completion:@escaping (Bool, String, [ReviewDataSource])-> ()) {
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/app/reviews"), tag: "API-Request", level: .default)
       
        self.alamofireManager.request(kBaseURL+"/app/reviews",
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count == 0 {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                let reviews = Mapper<ReviewDataSource>().mapArray(JSONArray: responseData.objectList)
                completion(responseData.isSuccess, responseData.message, reviews)
                
        }
    }
    
    //MARK: - Home Page APIs
    func getDailyPageNewVideos(completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session",[])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID",[])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/home/new_videos"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/home/new_videos",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: responseData.objectList)
                completion(responseData.isSuccess, responseData.message, listVideos)
        }
    }
    
    func getAllUpSells(page: Int, limit: Int, completion:@escaping (Bool, String, PagingDataSource?, [UpSellDataSource])-> ()) {
        let _ = self.getReferenceUpSell(referenceVideoID: "", page: page, limit: limit) { (isSuccess,error, paging, listUpSell) in
            completion(isSuccess, error, paging, listUpSell)
        }
    }
    
    func searchAll(page: Int, limit: Int, keyword: String,
                     focusAreaIDs: [String],
                     completion:@escaping (Bool, String, PagingDataSource?,[VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil, [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["search_keyword":keyword,
                         "focus_areas":focusAreaIDs,
                         "limit": String(limit),
                         "page": String(page)] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/search"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/search",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    completion(responseData.isSuccess, responseData.message, paging, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
        }
    }
    
    func searchOldMobility(page: Int, limit: Int, keyword: String,
                     focusAreaIDs: [String],
                     completion:@escaping (Bool, String, PagingDataSource?,[VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil, [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["search_keyword":keyword,
                         "focus_areas":focusAreaIDs,
                         "limit": String(limit),
                         "page": String(page)] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/home/old_mobility_wod"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/home/old_mobility_wod",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    completion(responseData.isSuccess, responseData.message, paging, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
        }
    }
    
    //MARK: - Daily Page APIs
    func dailySearch(listFocus: [String],
                     listEquipment: [String],
                     minValue : Int,
                     maxValue : Int,
                     limit: Int, page: Int,
                     completion:@escaping (Bool, String, PagingDataSource?, [VideoDataSource])-> ())
    {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil, [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["focus_areas":listFocus,
                         "focus_equipment": listEquipment,
                         "min_duration": minValue,
                         "max_duration": maxValue,
                         "limit": limit,
                         "page": page] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/search_daily"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/search_daily",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideo = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    completion(responseData.isSuccess, responseData.message, paging, listVideo)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
        }
    }
    
    func getDailyPageFeatureVideos(filterBy: Int,
                                   completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session",[])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID",[])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        var parametters = ["min_duration":filterBy*60,
                           "max_duration":(filterBy + 10)*60]
        
        if filterBy == 0 {
            parametters = ["min_duration":0,
                           "max_duration":600000]
        } else if filterBy == 1800 {
            parametters = ["min_duration":1800,
                           "max_duration":600000]
        }
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/home/feature_video"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametters), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/home/feature_video",
            method: .get,
            parameters: parametters,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametters) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count > 0 {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: responseData.objectList)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                } else {
                    completion(responseData.isSuccess, responseData.message, [])
                }
        }
    }
    
//    func listMaintenanceVideo(listFocus: [String],
//                              minValue : Int,
//                              maxValue : Int,
//                              limit: Int, page: Int,
//                              completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
//        guard let accessToken = self.sessionDataSource?.accessToken else {
//            completion(false, "Fail to get user session", [])
//            return
//        }
//
//        guard let userID = self.sessionDataSource?.userID else {
//            completion(false, "Fail to get user ID", [])
//            return
//        }
//
//        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
//
//        let parameter = ["focus_areas":listFocus,
//                         "min_duration": minValue,
//                         "max_duration": maxValue,
//                         "limit": limit,
//                         "page": page] as [String : Any]
//
//        self.alamofireManager.request(kBaseURL+"/\(userID)/home/daily_maintenance",
//            method: .get,
//            parameters: parameter,
//            encoding: URLEncoding.default,
//            headers: headers).responseJSON
//            { (response:DataResponse<Any>) in
//                guard let responseData = self.handleResponseDict(response: response) else {
//                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
//                    return
//                }
//
//                if !responseData.isSuccess {
//                    completion(responseData.isSuccess, responseData.message, [])
//                    return
//                }
//
//                if responseData.objectList.count > 0 {
//                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: responseData.objectList)
//                    completion(responseData.isSuccess, responseData.message, listVideos)
//                    return
//                }
//
//                completion(responseData.isSuccess, responseData.message, [])
//        }
//    }
    
    func getBestUpSeller(completion:@escaping (Bool, String, [UpSellDataSource])-> ()) {
            guard let accessToken = self.sessionDataSource?.accessToken else {
                completion(false,"Fail to get user session", [])
                return
            }
            
            guard let userID = self.sessionDataSource?.userID else {
                completion(false,"Fail to get user ID", [])
                return
            }
            
            let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
            
            let parameter = ["page": 1,
                             "limit": 20]
            
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/upsell/best_seller"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/upsell/best_seller",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                    guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
    //                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""),[])
                        return
                    }
                    
                    if !responseData.isSuccess {
                        completion(responseData.isSuccess, responseData.message, [])
                        return
                    }
                    
                    guard let objectDict = responseData.objectData else {
                        completion(responseData.isSuccess, responseData.message, [])
                        return
                    }
                    
                    if let arrayDict = objectDict["list_data"] as? [[String:Any]] {
                        let listUpsel = Mapper<UpSellDataSource>().mapArray(JSONArray: arrayDict)
                        completion(responseData.isSuccess, responseData.message, listUpsel)
                        return
                    }
                    
                    completion(responseData.isSuccess, responseData.message, [])
            }
        }
    
    //MARK: - Pain
    func getGettingStartedPainVideos(painID: String,
                                     completion:@escaping (Bool, String, VideoDataSource?)-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["pain_area_id":painID,
                         "limit":10] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/pain/getting_started"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/pain/getting_started",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                let gettingstartedVideo = Mapper<VideoDataSource>().map(JSON: objectDict)
                completion(responseData.isSuccess, responseData.message, gettingstartedVideo)
        }
    }
    
    func getUnderstandingPainVideos(painID: String,
                                    completion:@escaping (Bool, String, [VideoDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["pain_area_id":painID,
                         "limit":30,
                         "filter":"under"] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/pain/understanding_pain"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/pain/understanding_pain",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getAdvancedPainVideos(painID: String,
                               completion:@escaping (Bool, String, [VideoDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["pain_area_id":painID,
                         "limit":30,
                         "filter":"advanced"] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/pain/understanding_pain"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/pain/understanding_pain",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getMobilityRXVideos(painID: String,
                             completion:@escaping (Bool, String, [VideoDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["pain_area_id":painID,
                         "limit":30] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/pain/mobility_rx"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/pain/mobility_rx",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    //MARK: - Workouts
    func getUserRecommendationEquipments(completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/equipments"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/equipments",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getUserRecommendationWorkouts(completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/workouts"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/workouts",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getUserRecommendationSports(completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/sports"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/sports",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(true, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getUserRecommendationArchetypes(completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/archetypes"), tag: "API-Request", level: .default)

        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/archetypes",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(true, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    //MARK: -
    
    func getWorkoutCategories( limit : Int,
                               page: Int,
                               completion:@escaping (Bool, String, [CategoryDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["limit": limit,
                         "page": page] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/workouts_categories"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/collection/workouts_categories",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count > 0 {
                    var listCollections = Mapper<CategoryDataSource>().mapArray(JSONArray: responseData.objectList)
                    
                    var index = 0
                    for collection in listCollections {
                        collection.collectionSlug = "workouts"
                        listCollections[index] = collection
                        
                        index += 1
                    }
                    
                    completion(responseData.isSuccess, responseData.message, listCollections)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getSportCategories(limit: Int,
                            page: Int,
                            completion:@escaping (Bool, String, [CategoryDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["limit": limit,
                         "page": page] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/sports_categories"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/collection/sports_categories",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count > 0 {
                    var listCollections = Mapper<CategoryDataSource>().mapArray(JSONArray: responseData.objectList)
                    
                    var index = 0
                    for collection in listCollections {
                        collection.collectionSlug = "sports"
                        listCollections[index] = collection
                        
                        index += 1
                    }
                    
                    completion(responseData.isSuccess, responseData.message, listCollections)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getArchetypeCategories(limit : Int,
                                page: Int,
                                completion:@escaping (Bool, String, [CategoryDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["limit": limit,
                         "page": page] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/archetypes_categories"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/collection/archetypes_categories",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count > 0 {
                    var listCollections = Mapper<CategoryDataSource>().mapArray(JSONArray: responseData.objectList)
                    
                    var index = 0
                    for collection in listCollections {
                        collection.collectionSlug = "archetypes"
                        listCollections[index] = collection
                        
                        index += 1
                    }
                    
                    completion(responseData.isSuccess, responseData.message, listCollections)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getListWarmUp(limit : Int,
                       page: Int, completion:@escaping (Bool, String, [VideoDataSource])-> ())  -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["filter_category_id":1999,
                         "limit": limit,
                         "page": page] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/all"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/collection/all",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
        return request
    }
    //MARK: -
    
    func getListSuggestionVideoByCategory(categoryID: Int,
                                          listEquipments: [Int],
                                          listFocusArea: [Int],
                                          minDuration: Int,
                                          maxDuration: Int,
                                          prePostFilter: Int,
                                          collectionSlug: String,
                                          completion:@escaping (Bool, String, [VideoDataSource])-> ())  {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["limit":3,
                         "page":1,
                         "category_id": categoryID,
                         "equipment_ids":listEquipments,
                         "focus_areas":listFocusArea,
                         "min_duration":minDuration,
                         "max_duration":maxDuration,
                         "pre_post_filter":prePostFilter,
                         "collection_slug":collectionSlug] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/suggestion_videos"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)

        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/suggestion_videos",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["suggestion_videos"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func getListRelatedVideoByCategory(categoryID: Int,
                                       listEquipments: [Int],
                                       listFocusArea: [Int],
                                       minDuration: Int,
                                       maxDuration: Int,
                                       prePostFilter: Int,
                                       collectionSlug: String, limit: Int, page: Int,
                                       completion:@escaping (Bool, String, PagingDataSource?, [VideoDataSource])-> ())  {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil,  [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["limit":limit,
                         "page":page,
                         "category_id": categoryID,
                         "equipment_ids":listEquipments,
                         "focus_areas":listFocusArea,
                         "min_duration":minDuration,
                         "max_duration":maxDuration,
                         "pre_post_filter":prePostFilter,
                         "collection_slug":collectionSlug] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/related_videos"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/related_videos",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message,nil, [])
                    return
                }
                
                if let arrayDict = objectDict["post_related_videos"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    completion(responseData.isSuccess, responseData.message, paging, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
        }
    }
    
    //MARK: - Momenent Guide
    func getVideoImovementGuide(categoryID: Int,
                                       completion:@escaping (Bool, String, VideoDataSource?)-> ())  {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["category_id": categoryID] as [String : Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/collection/movement_guide"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/collection/movement_guide",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                if let objectDict = responseData.objectData {
                    let videoData = Mapper<VideoDataSource>().map(JSON: objectDict)
                    completion(responseData.isSuccess, responseData.message, videoData)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil)
        }
    }
    //MARK: - Mobility
    
    func getUserMobilityPoint(completion:@escaping (Bool, String, UserMobilityDataSource)-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", UserMobilityDataSource.init(JSONString: "{}")!)
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", UserMobilityDataSource.init(JSONString: "{}")!)
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/mobility"), tag: "API-Request", level: .default)
        
        return self.alamofireManager.request(kBaseURL+"/\(userID)/user/mobility",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), UserMobilityDataSource.init(JSONString: "{}")!)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, UserMobilityDataSource.init(JSONString: "{}")!)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, UserMobilityDataSource.init(JSONString: "{}")!)
                    return
                }
                
                if let userMobility = Mapper<UserMobilityDataSource>().map(JSON: objectDict) {
                    completion(responseData.isSuccess, responseData.message, userMobility)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, UserMobilityDataSource.init(JSONString: "{}")!)
        }
    }
    
    func getKellyRecommendationVideo(completion:@escaping (Bool, String, VideoDataSource?)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/kelly_recommend_video"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/kelly_recommend_video",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let videoData = Mapper<VideoDataSource>().map(JSON: objectDict) else {
                    completion(responseData.isSuccess, responseData.message,nil)
                    return
                }
                completion(responseData.isSuccess, responseData.message,videoData)
        }
    }
    
    func getMobilityIntroVideo(completion:@escaping (Bool, String, VideoDataSource?)-> ())
    {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/mobility_intro_video"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/mobility_intro_video",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let videoData = Mapper<VideoDataSource>().map(JSON: objectDict) else {
                    completion(responseData.isSuccess, responseData.message,nil)
                    return
                }
                completion(responseData.isSuccess, responseData.message,videoData)
        }
    }
    
    func getSignUpIntroVideo(completion:@escaping (Bool, String, VideoDataSource?)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/app/sign_up_intro_video"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/app/sign_up_intro_video",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
                    //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let videoData = Mapper<VideoDataSource>().map(JSON: objectDict) else {
                    completion(responseData.isSuccess, responseData.message,nil)
                    return
                }
                completion(responseData.isSuccess, responseData.message,videoData)
        }
    }
    
    func getListMobilityVideoSource(completion:@escaping (Bool, String)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/mobility_test"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/user/mobility_test",
                                      method: .get,
                                      parameters: nil,
                                      encoding: URLEncoding.default,
                                      headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                                        guard let responseData = self.handleResponseDict(response: response) else {
                                            //                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                                            return
                                        }
                                        
                                        if !responseData.isSuccess {
                                            completion(responseData.isSuccess, responseData.message)
                                            return
                                        }
                                        
                                        guard let objectDict = responseData.objectData else {
                                            completion(responseData.isSuccess, responseData.message)
                                            return
                                        }
                                        
                                        if let listShoulder = objectDict["shoulder_videos"] as? [[String:Any]] {
                                            let listShouderVideo = Mapper<MobilityTestVideo>().mapArray(JSONArray: listShoulder)
                                            if _AppCoreData.listShouderVideo.count != 0 {
                                                if _AppCoreData.listShouderVideo.first?.selectedResult == 0 {
                                                    _AppCoreData.insertShoulderVideo(list: listShouderVideo)
                                                }
                                            } else {
                                                _AppCoreData.insertShoulderVideo(list: listShouderVideo)
                                            }
                                        }
                                        
                                        if let listTrunk = objectDict["trunk_videos"] as? [[String:Any]] {
                                            let listTrunkVideo = Mapper<MobilityTestVideo>().mapArray(JSONArray: listTrunk)
                                            if _AppCoreData.listTrunkVideo.count != 0 {
                                                if _AppCoreData.listTrunkVideo.first?.selectedResult == 0 {
                                                    _AppCoreData.insertTruckVideo(list: listTrunkVideo)
                                                }
                                            } else {
                                                _AppCoreData.insertTruckVideo(list: listTrunkVideo)
                                            }
                                        }
                                        
                                        if let listHip = objectDict["hip_videos"] as? [[String:Any]] {
                                            let listHipVideo = Mapper<MobilityTestVideo>().mapArray(JSONArray: listHip)
                                            if _AppCoreData.listHipVideo.count != 0 {
                                                if _AppCoreData.listHipVideo.first?.selectedResult == 0 {
                                                    _AppCoreData.insertHipVideo(list: listHipVideo)
                                                }
                                            } else {
                                                _AppCoreData.insertHipVideo(list: listHipVideo)
                                            }
                                        }
                                        
                                        if let listAnkle = objectDict["ankle_videos"] as? [[String:Any]] {
                                            let listAnkleVideo = Mapper<MobilityTestVideo>().mapArray(JSONArray: listAnkle)
                                            if _AppCoreData.listAnkleVideo.count != 0 {
                                                if _AppCoreData.listAnkleVideo.first?.selectedResult == 0 {
                                                    _AppCoreData.insertAnkleVideo(list: listAnkleVideo)
                                                }
                                            } else {
                                                _AppCoreData.insertAnkleVideo(list: listAnkleVideo)
                                            }
                                        }
                                        
                                        completion(responseData.isSuccess, responseData.message)
                                        
                                      }
    }
    
    func sendMobilityResult(newUserResult: UserMobilityDataSource,
                            completion:@escaping (Bool, String)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = newUserResult.toJSON()
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/mobility_result"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/user/mobility_result",
            method: .post,
            parameters: parameter,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
                
        }
    }
    
    func getMobilitySuggestionVideo(completion:@escaping (Bool, String, [[VideoDataSource]])-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/mobility_videos"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/user/mobility_videos",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                var listVideos : [[VideoDataSource]] = []
                
                //trunk video index 0
                var listTrunkVideo : [VideoDataSource] = []
                if let listTrunkVideoDict = objectDict["trunk_videos"] as? [[String : Any]] {
                    listTrunkVideo = Mapper<VideoDataSource>().mapArray(JSONArray: listTrunkVideoDict )
                }
                listVideos.append(listTrunkVideo)
                
                //shoulder video index 1
                var listShoulderVideo : [VideoDataSource] = []
                if let listShoulderVideoDict = objectDict["shoulder_videos"] as? [[String : Any]] {
                    listShoulderVideo = Mapper<VideoDataSource>().mapArray(JSONArray: listShoulderVideoDict )
                }
                listVideos.append(listShoulderVideo)
                
                //hip video index 2
                var listHipVideo : [VideoDataSource] = []
                if let listHipVideoDict = objectDict["hip_videos"] as? [[String : Any]] {
                    listHipVideo = Mapper<VideoDataSource>().mapArray(JSONArray: listHipVideoDict )
                }
                listVideos.append(listHipVideo)
                
                //ankle video index 3
                var listAnkleVideo : [VideoDataSource] = []
                if let listAnkleVideoDict = objectDict["ankle_videos"] as? [[String : Any]] {
                    listAnkleVideo = Mapper<VideoDataSource>().mapArray(JSONArray: listAnkleVideoDict )
                }
                listVideos.append(listAnkleVideo)
                
                completion(responseData.isSuccess, responseData.message,listVideos)
                
        }
    }
    
    //MARK: - Bonus Content
    
    func getListBonusVideo(bonusID: Int,
                           page: Int,
                           limit: Int,
                           completion:@escaping (Bool, String, PagingDataSource?, [VideoDataSource])-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil, [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["bonus_id":bonusID,
                         "page":page,
                         "limit":limit]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/bonus"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/bonus",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, paging, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
                
        }
        
        return request
    }
    
    //MARK: - User Profile Page
    
    func getListNotification(completion:@escaping (Bool, String, [UserNotificationDataSource])-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/notifications"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/notifications",
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["data"] as? [[String:Any]] {
                    let listNotifications = Mapper<UserNotificationDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listNotifications)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
                
        }
    }
    
    func setNotificationAsRead(completion:@escaping (Bool, String)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/notifications/mark"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/notifications/mark",
            method: .post,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
                
        }
    }
    
    func getUserHelp(completion:@escaping (Bool, String, String)-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", "")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", "")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/help"), tag: "API-Request", level: .default)

        self.alamofireManager.request(kBaseURL+"/\(userID)/user/help",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), "")
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, "")
                    return
                }
                
                guard let htmlString = responseData.objectData?["html_code"] as! String? else {
                    completion(responseData.isSuccess, responseData.message, "")
                    return
                }
                completion(responseData.isSuccess, responseData.message,htmlString )
                
        }
    }
    
    func getAppPrivacyPolicy(completion:@escaping (Bool, String, String)-> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", "")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", "")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/user/privacy_policy"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/user/privacy_policy",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), "")
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, "")
                    return
                }
                
                guard let htmlString = responseData.objectData?["html_code"] as! String? else {
                    completion(responseData.isSuccess, responseData.message, "")
                    return
                }
                completion(responseData.isSuccess, responseData.message,htmlString )
                
        }
    }
    
    //MARK: - User Progress
    
    func getUserHistoriesVideo(page: Int, limit: Int,completion:@escaping (Bool, String, PagingDataSource?, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil, [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["page":page,
                         "limit":limit]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/activity/history"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/activity/history",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    
                    let listVideo = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, paging, listVideo)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
                
        }
    }
    
    func getUserArchivermentBagde(completion:@escaping (Bool, String, [UserArchivementDataSource], Int) -> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [], 0)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [], 0)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/activity/user_archivement"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/activity/user_archivement",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [], 0)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [], 0)
                    return
                }
        
                var listArchiverments : [UserArchivementDataSource] = []
                var userPoint = 0
                
                if let arrayDict = objectDict["user_archiverments"] as? [[String:Any]] {
                    listArchiverments = Mapper<UserArchivementDataSource>().mapArray(JSONArray: arrayDict)
                }
                
                if let  userPointValue = objectDict["user_streak_point"] as? Int {
                    userPoint = userPointValue
                }
                
                completion(responseData.isSuccess, responseData.message, listArchiverments, userPoint)
        }
    }
    
     func trackingUserStreak(completion:@escaping (Bool, String)-> ()) {
            guard let accessToken = self.sessionDataSource?.accessToken else {
                completion(false, "Fail to get user session")
                return
            }
            
            guard let userID = self.sessionDataSource?.userID else {
                completion(false, "Fail to get user ID")
                return
            }
            
            let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
            
            bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/activity/tracking_user_streak"), tag: "API-Request", level: .default)
        
            self.alamofireManager.request(kBaseURL+"/\(userID)/activity/tracking_user_streak",
                method: .post,
                parameters: nil,
                encoding: URLEncoding.default,
                headers: headers).responseJSON
                { (response:DataResponse<Any>) in
                    guard let responseData = self.handleResponseDict(response: response) else {
                        return
                    }
                    
                    if !responseData.isSuccess {
                        completion(responseData.isSuccess, responseData.message)
                        return
                    }
                    
                    completion(responseData.isSuccess, responseData.message)
                    
            }
        }
    
    func getGlobalLeaderboard(completion:@escaping (Bool, String, UserProfileRank?, [UserProfileRank])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil, [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil, [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/activity/global_leaderboard"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/activity/global_leaderboard",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil, [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil,[])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil,[])
                    return
                }
                
                var userRank = UserProfileRank.init(JSONString: "{}")!
                if let userRankDict = objectDict["current_user"] as? [String: Any] {
                    userRank = Mapper<UserProfileRank>().map(JSON: userRankDict)!
                }
                
                var listUserRank : [UserProfileRank] = []
                if let arrayDict = responseData.objectData?["all_user"] as? [[String:Any]] {
                    listUserRank = Mapper<UserProfileRank>().mapArray(JSONArray: arrayDict)
                }
                
                completion(responseData.isSuccess, responseData.message, userRank, listUserRank)
        }
    }
    
    //MARK: - Favorite
    func getListFavoriteVideo(completion:@escaping (Bool, String, [VideoDataSource])-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", [])
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", [])
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/favorite/list"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/favorite/list",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), [])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if let arrayDict = objectDict["list_video"] as? [[String:Any]] {
                    let listVideos = Mapper<VideoDataSource>().mapArray(JSONArray: arrayDict)
                    completion(responseData.isSuccess, responseData.message, listVideos)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, [])
        }
    }
    
    func addVideoToFavorite(videoID: Int,
                            completion:@escaping (Bool, String)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parametter = ["video_id": videoID] as [String:Any]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/favorite/add"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/favorite/add",
            method: .post,
            parameters: parametter,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametter) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
    }
    
    func removeVideoFromFavorite(videoID: Int,
                                 completion:@escaping (Bool, String)-> ()) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session")
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID")
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/favorite/remove/\(videoID)"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/favorite/remove/\(videoID)",
            method: .delete,
            parameters: nil,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""))
                    return
                }
                
                completion(responseData.isSuccess, responseData.message)
        }
    }
    
    //MARK: - Video Player
    func getVideoInfo(videoID: Int,
                      completion:@escaping (Bool, String, VideoDataSource?)-> ()) -> Request? {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/video/info/\(videoID)"), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/video/info/\(videoID)",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let videoData = Mapper<VideoDataSource>().map(JSON: objectDict) else {
                    completion(responseData.isSuccess, responseData.message,nil)
                    return
                }
                completion(responseData.isSuccess, responseData.message,videoData)
                
        }
        
        return request
    }
    
    func getVideoDownloadableLink(videoData: VideoDataSource,
                                  completion:@escaping(Bool, String, VideoDownloadedDataSource?) -> ()) {
        
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false, "Fail to get user session", nil)
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false, "Fail to get user ID", nil)
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/video/download/\(videoData.videoID)"), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/video/download/\(videoData.videoID)",
            method: .get,
            parameters: nil,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response) else {
//                    completion(false, NSLocalizedString("kAPIFailToParse", comment: ""), nil)
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil)
                    return
                }
                
                guard let videoDownloadData = Mapper<VideoDownloadedDataSource>().map(JSON: objectDict) else {
                    completion(responseData.isSuccess, responseData.message,nil)
                    return
                }
                completion(responseData.isSuccess, responseData.message,videoDownloadData)
                
        }
    }
    
    func getReferenceVideo (referenceVideoID: String,
                            completion:@escaping (Bool, String, [VideoDataSource])-> ()) -> Request?  {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session",[])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID",[])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parametter = ["video_id":referenceVideoID]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/video/reference_videos"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametter), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/video/reference_videos",
            method: .get,
            parameters: parametter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametter) else {
//                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, [])
                    return
                }
                
                if responseData.objectList.count > 0 {
                    let listVideo = Mapper<VideoDataSource>().mapArray(JSONArray: responseData.objectList)
                    completion(responseData.isSuccess, responseData.message,listVideo)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message,[])
        }
        return request
    }
    
    func getReferenceUpSell(referenceVideoID: String,
                            page: Int,
                            limit: Int,
                            completion:@escaping (Bool, String, PagingDataSource?, [UpSellDataSource])-> ()) -> Request?  {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            completion(false,"Fail to get user session", nil, [])
            return nil
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            completion(false,"Fail to get user ID", nil, [])
            return nil
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parameter = ["reference_video_id":referenceVideoID,
                         "page":String(page),
                         "limit":String(limit)]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/upsell"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parameter), tag: "API-Request", level: .default)
        
        let request = self.alamofireManager.request(kBaseURL+"/\(userID)/upsell",
            method: .get,
            parameters: parameter,
            encoding: URLEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parameter) else {
//                    completion(false,NSLocalizedString("kAPIFailToParse", comment: ""),[])
                    return
                }
                
                if !responseData.isSuccess {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                guard let objectDict = responseData.objectData else {
                    completion(responseData.isSuccess, responseData.message, nil, [])
                    return
                }
                
                if let arrayDict = objectDict["list_data"] as? [[String:Any]] {
                    let listUpsel = Mapper<UpSellDataSource>().mapArray(JSONArray: arrayDict)
                     let paging = Mapper<PagingDataSource>().map(JSON: objectDict)!
                    completion(responseData.isSuccess, responseData.message, paging, listUpsel)
                    return
                }
                
                completion(responseData.isSuccess, responseData.message, nil, [])
        }
        return request
    }
    
    //MARK: - Send log - Tracking
    
    func trackingVideoWatch(videoData: VideoDataSource,
                            trackingPercent: Double) {
        guard let accessToken = self.sessionDataSource?.accessToken else {
            return
        }
        
        guard let userID = self.sessionDataSource?.userID else {
            return
        }
        
        let headers: HTTPHeaders = ["Authorization": "Bearer " + accessToken]
        
        let parametter: [String : Any] = [
            "video_id": videoData.videoID,
            "watched_percent": trackingPercent]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/\(userID)/tracking/watch"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/\(userID)/tracking/watch",
            method: .post,
            parameters: parametter,
            encoding: JSONEncoding.default,
            headers: headers).responseJSON
            { (response:DataResponse<Any>) in
                guard let responseData = self.handleResponseDict(response: response, requestParam: parametter) else {
                    return
                }
                
                if responseData.isSuccess {
                    print("Tracking success video ID \(videoData.videoID) at \(trackingPercent) %")
                } else {
                    print("Tracking fail video ID \(videoData.videoID) at \(trackingPercent) %")
                }
        }
    }
    
    func sendLog(apiName: String,
                 log: Any?) {
        
        let value = ["json":"\(String(describing: log))",
            "api_name":"apiName"]
        let parametter = ["json":value]
        
        bfprint(String(format:"Lucas-API-Request-URL: %@", kBaseURL+"/log/ios"), tag: "API-Request", level: .default)
        bfprint(String(format:"Lucas-API-Request-Param: %@", parametter), tag: "API-Request", level: .default)
        
        self.alamofireManager.request(kBaseURL+"/log/ios",
                                      method: .post,
                                      parameters: parametter,
                                      encoding: JSONEncoding.default,
                                      headers: nil).responseJSON
            { (response:DataResponse<Any>) in
                
                // Do nothing
        }
    }
    
    private func trackingUserPremium() {
        
        guard let userProfile = self.userProfile else {
            return
        }
        
        let curentTime = NSDate().timeIntervalSince1970
        
        if userProfile.userPlan != "Free Trial" {
            return
        }
        
        let userPlanExpriedDate = userProfile.userPlanExpriedDate - 86400 // 86400: 24tiếng
        if Int(curentTime)  > userPlanExpriedDate
        {
            let timeFireAtDate = Date.init(timeIntervalSince1970: TimeInterval(userPlanExpriedDate))
            self.userPlanTimer = Timer.init(fireAt: timeFireAtDate,
                                            interval: 0,
                                            target: self,
                                            selector: #selector(warningExpiredUserPlan),
                                            userInfo: nil,
                                            repeats: false)
            
            let content = UNMutableNotificationContent()
            content.title = NSLocalizedString("kFreemiumWarning", comment: "")
            content.body = NSLocalizedString("kFreemiumExpiredMessage", comment: "")
            content.sound = UNNotificationSound.default
            content.badge = 1
            
            let triggerDate = Calendar.current.dateComponents([.year,.month,.day,.hour,.minute,.second,], from: timeFireAtDate)
            
            _ = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)
        }
    }
    
    
    let networkReachabilityManager = Alamofire.NetworkReachabilityManager(host: "www.apple.com")
    
    func checkForReachability() {
        self.networkReachabilityManager?.listener = { status in
            
            NotificationCenter.default.post(name: kNetwordHasChangeNotification, object: nil)
            
            switch status {
            case .notReachable:
                //Show error here (no internet connection)
                _NavController.presentAlertForNetworkRechability()
                break
            case .reachable(_):
                
                break
            case .unknown: break
                //Hide error here
            }
        }
        
        self.networkReachabilityManager?.startListening()
    }
    
    func checkNetWork() {
        let reachabilityManager = NetworkReachabilityManager()

        reachabilityManager?.startListening()
        reachabilityManager?.listener = { _ in
                if let isNetworkReachable = reachabilityManager?.isReachable,
                    isNetworkReachable == true {
                    //Internet Available
                } else {
                    _NavController.presentAlertForNetworkRechability()
                    //Internet Not Available"
                }
            }
    }
    
    func getStatusQuiz() -> Bool {
        return self.statusQuiz
    }
    
    //MARK: - Process Video Duration UI
    func timeAttributedString(seconds: Int,
                              color: UIColor,
                              fontActive: UIFont,
                              fontInactive: UIFont) -> NSAttributedString {
        var timeString: String = ""
        var hour: Int = 0
        var min: Int = 0
        var sec: Int = 0
        
        if seconds >= 3600 {
            // Hour + minutes
            hour = Int(seconds / 3600)
            min = Int((seconds % 3600) / 60)
            timeString = "\(hour)h \(min)m"
        } else if seconds >= 60 {
            // Minutes + seconds
            min = Int(seconds / 60)
            sec = seconds % 60
            timeString = "\(min)m \(sec)s"
        } else {
            // Seconds
            sec = seconds
            timeString = "\(sec)s"
        }
        
        var firstBold: Int = 0
        var secondBold: Int = 0
        let attributedString = NSMutableAttributedString(string: timeString, attributes: [
          .font: fontInactive,
          .foregroundColor: color
        ])
        
        if hour > 0 {
            firstBold = String(hour).count
            secondBold = String(min).count
            attributedString.addAttribute(.font, value: fontActive, range: NSMakeRange(firstBold + 2, secondBold))
        } else if min > 0 {
            firstBold = String(min).count
            secondBold = String(sec).count
            attributedString.addAttribute(.font, value: fontActive, range: NSMakeRange(firstBold + 2, secondBold))
        } else {
            firstBold = String(sec).count
        }
        attributedString.addAttribute(.font, value: fontActive, range: NSMakeRange(0, firstBold))
        
        return attributedString
    }
}
