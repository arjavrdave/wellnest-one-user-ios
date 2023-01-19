//
//  UIButtonUtil.swift
//  SameHere
//
//  Created by Mayank Verma on 03/02/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Foundation
import UIKit

@IBDesignable
class UIButtonRoundCorners : UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0.0 {
        didSet {
            UpdateUI()
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 0.0 {
        didSet {
            UpdateUI()
        }
    }
    @IBInspectable var isBorder : Bool = false {
        didSet {
            UpdateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UpdateUI()
    }
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    func UpdateUI() {
        if self.isBorder {
            self.layer.borderWidth = 1
        }
        
        self.layer.shadowOpacity = 0.5
        self.layer.shadowColor = UIColor.colorButton.cgColor
        self.layer.shadowRadius = self.shadowRadius
//        self.layer.masksToBounds = false
        self.layer.borderColor = UIColor.colorButton.cgColor

        self.layer.cornerRadius = self.cornerRadius == 0.0 ? self.frame.height / 2 : self.cornerRadius
        self.layoutIfNeeded()
    }
}

@IBDesignable
class UIButtonSoftUI : UIButton {
    @IBInspectable var shadowRadius : CGFloat = 4 {
        didSet {
            updateUI()
        }
    }
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }

    override func layoutIfNeeded() {
        updateUI()
    }
    
    func updateUI() {
        self.layer.masksToBounds = false

        let cornerRadius: CGFloat = self.frame.height / 2
        self.layer.cornerRadius = cornerRadius
        self.clipsToBounds = true
        self.layer.masksToBounds = false
        let darkShadow = CALayer()
        darkShadow.frame = bounds
        darkShadow.backgroundColor = backgroundColor?.cgColor
        darkShadow.shadowColor = UIColor.colorFrom(hexString: "BBBBBB").cgColor
        darkShadow.cornerRadius = cornerRadius
        darkShadow.shadowOffset = CGSize(width: shadowRadius, height: shadowRadius)
        darkShadow.shadowOpacity = 1
        darkShadow.shadowRadius = shadowRadius
        self.layer.insertSublayer(darkShadow, at: 0)

        let lightShadow = CALayer()
        lightShadow.frame = bounds
        lightShadow.backgroundColor = backgroundColor?.cgColor
        lightShadow.shadowColor = UIColor.white.cgColor
        lightShadow.cornerRadius = cornerRadius
        lightShadow.shadowOffset = CGSize(width: -shadowRadius, height: -shadowRadius)
        lightShadow.shadowOpacity = 1
        lightShadow.shadowRadius = shadowRadius
        self.layer.insertSublayer(lightShadow, at: 0)
        
    }
}


enum ProceedStatus : String {
    case disable
    case enable
    case error
}

@IBDesignable
class UIButtonProceedForward : UIButton {
    
    var status : ProceedStatus = .disable {
        didSet {
            updateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
    }
    
    func updateUI() {
       switch status {
        case .disable:
            self.isUserInteractionEnabled = false
            self.setImage(UIImage(named: "next_button_disable"), for: .normal)
            break
        case .enable:
            self.isUserInteractionEnabled = true
            self.setImage(UIImage(named: "next_button"), for: .normal)
            break
        case .error:
            self.isUserInteractionEnabled = false
            self.setImage(UIImage(named: "next_button_invalid"), for: .normal)
            break
        }
    }
}


