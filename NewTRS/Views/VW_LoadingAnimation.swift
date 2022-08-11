//
//  VW_LoadingAnimation.swift
//  NewTRS
//
//  Created by Luu Lucas on 7/1/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class VW_LoadingAnimation: UIView
{
    let opacityView         = UIView()
    let circleRatation      = UIImageView()
    var animationTimer      : Timer?

    override init(frame: CGRect) {
        super.init(frame: frame)
        
        opacityView.backgroundColor = .black
        opacityView.layer.opacity = 0.5
        self.addSubview(opacityView)
        opacityView.snp.makeConstraints { (make) in
            make.center.size.equalToSuperview()
        }
        
        circleRatation.image = UIImage.init(named: "lunch_app_image")
        circleRatation.contentMode = .scaleAspectFit
        self.addSubview(circleRatation)
        circleRatation.snp.makeConstraints { (make) in
            make.centerX.equalToSuperview()
            make.centerY.equalToSuperview()
            make.height.width.equalTo(250)
        }
        
        circleRatation.transform =
            CGAffineTransform.identity.scaledBy(x: 0.001, y: 0.001)
        
        animationTimer = Timer.scheduledTimer(timeInterval: 1.5, target: self, selector: #selector(jumpingAnimation), userInfo: nil, repeats: true)
        
    }
    
    deinit {
        animationTimer?.invalidate()
    }
    
    @objc func jumpingAnimation() {
        
        UIView.animate(withDuration: 0.3 / 1.5, animations: {
            self.circleRatation.transform =
                CGAffineTransform.identity.scaledBy(x: 1.1, y: 1.1)
        }) { finished in
            UIView.animate(withDuration: 0.3 / 2, animations: {
                self.circleRatation.transform = CGAffineTransform.identity.scaledBy(x: 0.9, y: 0.9)
            }) { finished in
                UIView.animate(withDuration: 0.3 / 2, animations: {
                    self.circleRatation.transform = CGAffineTransform.identity
                })
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
