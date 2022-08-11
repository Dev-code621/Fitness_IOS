//
//  UIImageView_EXT.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/7/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

extension UIImageView {
    func getPixelColorAt(point:CGPoint) -> UIColor{

        let pixel = UnsafeMutablePointer<CUnsignedChar>.allocate(capacity: 4)
        let colorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.premultipliedLast.rawValue)
        let context = CGContext(data: pixel, width: 1, height: 1, bitsPerComponent: 8, bytesPerRow: 4, space: colorSpace, bitmapInfo: bitmapInfo.rawValue)

        context!.translateBy(x: -point.x, y: -point.y)
        layer.render(in: context!)
        let color:UIColor = UIColor(red: CGFloat(pixel[0])/255.0,
                                    green: CGFloat(pixel[1])/255.0,
                                    blue: CGFloat(pixel[2])/255.0,
                                    alpha: CGFloat(pixel[3])/255.0)

        return color
    }
}

extension UIImageView {
       func flash(numberOfFlashes: Float) {
          let flash = CABasicAnimation(keyPath: "opacity")
          flash.duration = 0.2
          flash.fromValue = 1
          flash.toValue = 0.1
          flash.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
          flash.autoreverses = true
          flash.repeatCount = numberOfFlashes
          layer.add(flash, forKey: nil)
      }
}

extension UIImageView {
    
    func setImage( url: URL, placeholder: UIImage) {
        
        self.sd_imageTransition = .fade
        self.sd_setImage(with: url, placeholderImage: placeholder)
        
        contentMode = .scaleAspectFill
        layer.masksToBounds = true
    }
}

