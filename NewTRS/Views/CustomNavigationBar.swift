//
//  CustomNavigationBar.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/3/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class CustomNavigationBar: UIView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension UIViewController {

    /**
     *  Height of status bar + navigation bar (if navigation bar exist)
     */

    var topbarHeight: CGFloat {
        if #available(iOS 13.0, *) {
            return UIApplication.shared.statusBarFrame.size.height +
            (self.navigationController?.navigationBar.frame.height ?? 0.0)
        } else {
            return (self.navigationController?.navigationBar.frame.height ?? 0.0)
        }
    }
}
