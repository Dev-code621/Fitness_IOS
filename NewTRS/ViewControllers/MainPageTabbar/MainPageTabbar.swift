//
//  MainPageTabbar.swift
//  NewTRS
//
//  Created by Luu Lucas on 5/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class MainPageTabbar: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UINavigationBar.appearance().backgroundColor = .clear
        UINavigationBar.appearance().isTranslucent = false
        UINavigationBar.appearance().shadowImage = UIImage()
        UINavigationBar.appearance().tintColor = UIColor.init(hexString: "1d00ff")
        
        UITabBar.appearance().backgroundColor = .white
        UITabBar.appearance().isTranslucent = false
        UITabBar.appearance().tintColor = UIColor.init(hexString: "1d00ff")
        
        UIBarButtonItem.appearance().setTitleTextAttributes(
        [
            NSAttributedString.Key.font : setFontSize(size: 12, weight: .regular),
            NSAttributedString.Key.foregroundColor : UIColor.init(hexString: "666666")!,
        ], for: .normal)
        
        let dailyNav = UINavigationController.init(rootViewController: VC_MainPageDaily())
        dailyNav.tabBarItem = UITabBarItem(title: "Daily",
                                           image: UIImage.init(named: "daily_tabbar_icon"),
                                           tag: 0)
        
        let painNav = UINavigationController.init(rootViewController: VC_MainPagePain())
        painNav.tabBarItem = UITabBarItem(title: "Pain-Body Part",
                                          image: UIImage.init(named: "pain_tabbar_icon"),
                                          tag: 1)
        
        let workoutsNav = UINavigationController.init(rootViewController: VC_MainPageWorkouts())
        workoutsNav.tabBarItem = UITabBarItem(title: "Prep/Recover",
                                              image: UIImage.init(named: "workout_tabbar_icon"),
                                              tag: 2)
        
        let mobilityNav = UINavigationController.init(rootViewController: VC_MainPageMobility())
        mobilityNav.tabBarItem = UITabBarItem(title: "Mobility Test",
                                              image: UIImage.init(named: "mobility_tabbar_icon"),
                                              tag: 3)
        
        let bonusNav = UINavigationController.init(rootViewController: VC_MainPageBonusContents())
        bonusNav.tabBarItem = UITabBarItem(title: "Bonus Content",
                                           image: UIImage.init(named: "bonus_content_tabbar_icon"),
                                           tag: 4)
        bonusNav.tabBarItem.isEnabled = false
                
        self.viewControllers = [dailyNav,painNav,workoutsNav,mobilityNav,bonusNav]
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(setActiveTabbar),
                                               name: kUserProfileHasChangeNotification,
                                               object: nil)
        self.setActiveTabbar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func setActiveTabbar() {
        
        if _AppDataHandler.getUserProfile().isFreemiumUser() {
            return
        }
        
        if let listViewController = self.viewControllers {
            for viewController in listViewController {
                viewController.tabBarItem.isEnabled = true
            }
        }
        
        if self.selectedIndex == 2 || self.selectedIndex == 4 {
            self.selectedIndex = 0
        }
    }
    
}
