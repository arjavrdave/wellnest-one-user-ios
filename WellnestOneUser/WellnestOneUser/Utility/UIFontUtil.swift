//
//  UIFontUtil.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 24/04/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit

let Montserrat = "Montserrat-"
let Helvetica = "Helvetica"
let Roboto = "Roboto-"

extension UIFont {
    
    class func Montserrat_Light(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Montserrat)Light", size: fontSize)!
    }
    class func Montserrat_Regular(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Montserrat)Regular", size: fontSize)!
    }
    class func Montserrat_Medium(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Montserrat)Medium", size: fontSize)!
    }
    class func Montserrat_Bold(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Montserrat)Bold", size: fontSize)!
    }

    class func Helvetica_Light(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Helvetica)-Light", size: fontSize)!
    }
    class func Helvetica_Regular(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Helvetica)", size: fontSize)!
    }
    class func Helvetica_Bold(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Helvetica)-Bold", size: fontSize)!
    }
    
    class func Roboto_Regular(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Roboto)Regular", size: fontSize)!
    }
    class func Roboto_Medium(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Roboto)Medium", size: fontSize)!
    }
    class func Roboto_Bold(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Roboto)Bold", size: fontSize)!
    }
    class func Roboto_Italic(fontSize : CGFloat) -> UIFont {
        return UIFont(name: "\(Roboto)Italic", size: fontSize)!
    }
}
