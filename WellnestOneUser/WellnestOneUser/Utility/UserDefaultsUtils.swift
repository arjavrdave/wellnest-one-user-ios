//
//  UserDefaultsUtils.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Foundation

extension UserDefaults {
    static var bearerToken: IBearerToken? {
        get {
            if let tokenData = UserDefaults.standard.data(forKey: "bearerToken") {
                if let bearerToken = tokenData.convertDataToClass(type: BearerToken.self) {
                    return bearerToken
                }
            }
            return nil
        }
    }
    
    static var fcmToken: String? {
        get {
            if let token = UserDefaults.standard.object(forKey: "fcmToken") as? String {
                return token
            }
            return nil
        }
    }

     func setFCMToken(fcmToken: String?) {
         if let token = fcmToken {
             UserDefaults.standard.set(token, forKey: "fcmToken")
         } else {
             UserDefaults.standard.removeObject(forKey: "fcmToken")
         }
         UserDefaults.standard.synchronize()
     }

    func setBearerToken(token: IBearerToken?) {
        if let tokenData = token?.convertToJSONEncoder() {
            UserDefaults.standard.set(tokenData, forKey: "bearerToken")
        } else {
            UserDefaults.standard.removeObject(forKey: "bearerToken")
        }
        UserDefaults.standard.synchronize()
    }
    
    func setAccount(account: IAccount?) {
        if let accountData = account?.convertToJSONEncoder() {
            UserDefaults.standard.set(accountData, forKey: "account")
        } else {
            UserDefaults.standard.removeObject(forKey: "account")
        }
        UserDefaults.standard.synchronize()
    }
    
    static var account: IAccount? {
        get {
            if let accountData = UserDefaults.standard.data(forKey: "account") {
                if let account = accountData.convertDataToClass(type: Account.self) {
                    return account
                }
            }
            return nil
        }
    }
}
extension Notification.Name {
    static let landingNotification =  Notification.Name(rawValue: "landingNotification")
    static let dashbaordNotification =  Notification.Name(rawValue: "dashbaordNotification")
}
