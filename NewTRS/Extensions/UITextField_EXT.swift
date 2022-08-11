//
//  UITextField_EXT.swift
//  NewTRS
//
//  Created by Luu Lucas on 6/28/20.
//  Copyright © 2020 Luu Lucas. All rights reserved.
//

import UIKit

class TextField: UITextField {

    let padding = UIEdgeInsets(top: 0, left: 25, bottom: 0, right: 5)

    override open func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override open func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
}

extension UITextField {
    func isValidEmail() -> Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"

        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self.text)
    }
    
    func isValidPassword() -> Bool {
        
        guard let text = self.text else {
            return false
        }
        
        if text.count  < 8 {
            return false
        }
        
        if text.count > 16 {
            return false
        }
        
        let password = NSPredicate(format: "SELF MATCHES %@ ", "^(?=.*[a-z])(?=.*[$@$#!%*?&.])(?=.*[A-Z]).{8,16}$")
        
        return password.evaluate(with: text)
    }
    
    func disableAutoFillStrongPassword() {
        if #available(iOS 12.0, *) {
            textContentType = .oneTimeCode
        } else {
            textContentType = .init(rawValue: "")
        }
    }
}
