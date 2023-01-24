//
//  Constants.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Foundation
import Alamofire
import UIKit

typealias ResponseStringCompletionHandler = (DataResponse<String>) -> Void
typealias ErrorCompletionHandler = (Error?) -> Void
typealias ListCompletionHandler<T> = (_ dataList: [T]?, _ error: Error?) -> Void
typealias ObjectCompletionHandler<T> = (_ response: T?, _ error: Error?) -> Void
typealias MultipleCompletionHandler<T,T1> = (_ response: T?, _ response: T1?, _ error: Error?) -> Void
typealias StringCompletionHandler = (_ text: String?, _ error: Error?) -> Void
typealias NumberCompletionHandler = (_ result: Int) -> Void
typealias GrantCompletionHandler = (_ isGranted: Bool) -> Void
typealias RegexCompletionHandler = (_ result: RegexType) -> Void

var SASTokenPublicRead = ""

enum NotificationType : String {
    case add_partner = "add_partner"
    case re_record = "re_record"
    case recording_feedback = "recording_feedback"
    case recording_forwarded = "recording_forwarded"
    case ADDED_PARTNER = "added_partner"
}

enum RegexType {
    case Success
    case None
    case Upper
    case Lower
    case Number
    case SpecialChar
    case Length
    //    case NoEmail
    
    var description: String {
        switch self {
        case .None:
            return "Password can not be blank."
        case .Upper:
            return "At least 1 uppercase letter is required in password."
        case .Lower:
            return "At least 1 lowercase letter is required in password."
        case .Number:
            return "At least 1 numeric character is required in password."
        case .SpecialChar:
            return "At least 1 special character is required in password."
        case .Length:
            return "The password should be minimum \(CommonConfiguration.PasswordLengthMinimum) characters."
            //        case .NoEmail:
        //            return "Password cannot be same as email."
        default:
            return ""
        }
    }
}
enum CommonConfiguration {
    static var PasswordLengthMinimum = 6
    static var PasswordLengthMaximum = 16
    
    static var DATE_FORMATTER_ISO_Convert_ForDOB: DateFormatter {
        get {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return formatter
        }
    }
    static var DATE_FORMATTER_ISO_Convert: DateFormatter {
        get {
            let formatter = DateFormatter()
            formatter.calendar = Calendar(identifier: .iso8601)
            formatter.locale = Locale(identifier: "en_US_POSIX")
            formatter.timeZone = TimeZone(secondsFromGMT: 0)
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS"
            return formatter
        }
    }
    static let Error_FirstName = "Enter valid first name"
    static let Error_LastName = "Enter valid last name"
    static let Error_Email = "Enter valid email address"
    static let Error_Phone = "Enter valid phone number"
    static let Error_Password = "Enter valid password"
    static let Error_OTP = "Enter valid Code"
    static let Error_Birthdate = "Enter valid Birthdate"
    static let Error_Height = "Height should be more than 0"
    static let Error_Weight = "Weight should be more than 0"
    static let Error_Bmr = "Body to mass ratio should not be 0"
    
    static let urgent_action_required = "Urgent Action Required"
    static let action_required_not_urgent = "Action Required (Not Urgent)"
    static let no_action_required = "No Action Required"

    static let PDF_Width : CGFloat = 841.89
    static let PDF_Height : CGFloat = 595.28
    
    static let Wellnest_AppVersion : String = "Wellnest One v"

}



enum AppConfiguration {
    
    static let debugOn = true
    
    private static var bundleEnvironment : [String : String] {
        get {
            let bundle = Bundle.main
            return bundle.object(forInfoDictionaryKey: "LSEnvironment") as! [String : String]
        }
    }
        
    static var baseURLPath: String {
        let bundle = Bundle.main
        print("BASE URL , \(bundle.infoDictionary?["baseUrl"])")
        return bundle.infoDictionary?["baseUrl"] as! String
    }
    static var apiKey: String {
        let bundle = Bundle.init(for: AppDelegate.self)
        return bundle.infoDictionary?["apiKey"] as! String
    }
    
    static var apiPassword: String {
        let bundle = Bundle.init(for: AppDelegate.self)
        return bundle.infoDictionary?["apiPassword"] as! String
    }
    
    static var azureBaseUrl: String {
        let bundle = Bundle.main
        return bundle.infoDictionary?["azureBaseUrl"] as! String
    }
    
    static var azureStorageName: String {
        let bundle = Bundle.main
        return bundle.infoDictionary?["azureStorageName"] as! String
    }
    
    static var amplitudeKey: String {
        let bundle = Bundle.main
        return bundle.infoDictionary?["amplitudeKey"] as! String
    }
    static var versionName: String {
        let bundle = Bundle.main
        return bundle.infoDictionary?["CFBundleShortVersionString"] as! String
    }
    static var versionCode: String {
        let bundle = Bundle.main
        return bundle.object(forInfoDictionaryKey: kCFBundleVersionKey as! String) as! String
    }
    static var wellnestShopUrl: String {
        let shopUrl = "https://www.wellnest.tech/shop"
        return shopUrl 
    }
    static var wellnestAppUrl: String {
        let appUrl = "https://apps.apple.com/in/app/wellnest-one/id6444249671"
        return appUrl
    }
}

enum CommonError {
    static let Error_FirstName          = "Please note that special characters and spaces are not allowed. Please re-enter your name."
    static let Error_Email              = "Please enter a valid email address."
    static let Error_Phone              = "Please note that special characters and spaces are not allowed. Please re-enter your phone number."
    static let Error_Gender             = "Please enter valid gender"
    static let Error_Password           = "Please make sure the following conditions are met while creating your password:"
    static let Error_OTP                = "Please enter valid Code"
    static let Error_Birthdate          = "Please enter valid Date of Birth"
    static let Error_CivilCardNumber    = "Please enter valid Civil Id number"

    static let Error_CameraDetect       = "We are not able to detect camera on your device. Please try again."
    static let Error_CameraPermission   = "You haven't provided access to Camera. Allow access for Camera from iPhone settings."
    static let Error_GalleryPermission  = "You haven't provided access to Photos. Allow access for Photos from iPhone settings."
    
    
}

enum HeightUnits {
    case Cm
    case Ft
}

enum WeightUnits {
    case Kg 
    case Lbs 
}

enum CreateEditPageType {
    case create
    case edit
}
enum RecordingPreviewPageType {
    case withoutPatient
    case recordingCompleted
    case sentForAnalysis
    case analysisReceived
    
}
