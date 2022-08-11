//
//  UIFont_EXT.swift
//  NewTRS
//
//  Created by yaya on 25/02/2021.
//  Copyright © 2021 Luu Lucas. All rights reserved.
//

import UIKit

enum FontWeight: String {
    case regular        = "HurmeGeometricSans3-Regular"
    case semibold       = "HurmeGeometricSans3-Semibold"
    case bold           = "HurmeGeometricSans3-Black"

}

func setFontSize (size: CGFloat, weight: FontWeight) -> UIFont {
    return UIFont.init(name: weight.rawValue, size: size)!
}
