//
//  AccountRouter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 07/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import Alamofire

enum AccountRouter: URLRequestConvertible {
 
    
    case login(Account)
    case verifyOTP(Account)
    case createProfile (Account)
    case deleteAccount(Account)
    case linkFamilyMember(Account, Int)
    
    case getInTouch(Account)
    case resendVerificationCode(Account)
    case getAccount(Account)
    case logout(Account)
    case registerFCM(Account)
    

    
    var method: HTTPMethod {
        switch self {
        case .login(_),.logout(_),.verifyOTP(_),.registerFCM(_),.getInTouch(_):
            return .post
        case .getAccount(_):
            return .get
        case .resendVerificationCode(_), .createProfile(_), .linkFamilyMember(_,_):
            return .put
        case .deleteAccount(_):
            return .delete
        }
    }
    
    var path: String {
        switch self {
        case .createProfile(_):
            return "/api/Patient/Profile"
        case .login(_) :
            return "/api/Account/LoginAsUser"
        case .verifyOTP(_):
            return "/api/Account/VerifyOtpForUser"
        case .resendVerificationCode(_):
            return "/api/Account/ResendVerificationCode"
        case .deleteAccount(_):
            return "/api/Account"
        case .linkFamilyMember(_,let recordingId):
            return "/api/Patient/LinkFamilyMember/\(recordingId)"
            
        case .getInTouch(_):
            return "/api/Account/GetInTouch"
        case .getAccount(_):
            return "/api/Account"
        case .logout(_):
            return "/api/Account/Logout"
        case .registerFCM(_):
            return "/api/Account/RegisterFCM"
        }
    }
    
    var parameters: Account {
        switch self {
        case .createProfile(let account):
            return account
        case .login(let account):
            return account
        case .verifyOTP(let account):
            return account
        case .resendVerificationCode(let account):
            return account
        case .deleteAccount(let account):
            return account
        case .linkFamilyMember(let account, _):
            return account
            
        case .getInTouch(let account):
            return account
        case .getAccount(let account):
            return account
        case .logout(let account):
            return account
        case .registerFCM(let account):
            return account
        }
    }

    public func asURLRequest() throws -> URLRequest {
        let url = try AppConfiguration.baseURLPath.asURL()
        
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        switch self {
        case .login(_),.logout(_),.verifyOTP(_),.getInTouch(_),.registerFCM(_),.resendVerificationCode(_), .createProfile(_), .linkFamilyMember(_, _):
            request.httpBody = self.parameters.convertToJSONEncoder()
        default:
            break
        }
        if AppConfiguration.debugOn {
            print("===== URL Request =====")
            print(request.url?.absoluteString ?? "Invalid URL")
            print(request.httpBody?.convertDataToJSON() ?? "No Parameters")
            print("===== Request End =====")
        }

        return try URLEncoding.default.encode(request ,with: nil)
    }
}

