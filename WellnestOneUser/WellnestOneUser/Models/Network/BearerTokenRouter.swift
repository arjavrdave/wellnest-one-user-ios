//
//  BearerTokenRouter.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Alamofire

enum BearerTokenRouter: URLRequestConvertible {

    case refereshToken (IBearerToken)
    
    var method: HTTPMethod {
        return .post
    }
    
    var path: String {
        return "/api/Account/RefreshToken"
    }
    
    var parameters: IBearerToken {
        switch self {
        case .refereshToken(let token):
            return token
        }
    }
    
    func asURLRequest() throws -> URLRequest {
        let url = try AppConfiguration.baseURLPath.asURL()
        
        var request = URLRequest(url: url.appendingPathComponent(path))
        request.httpMethod = method.rawValue
        request.timeoutInterval = TimeInterval(10 * 1000)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        

        request.httpBody = parameters.convertToJSONEncoder()

        if AppConfiguration.debugOn {
            print("===== URL Request =====")
            print(request.url?.absoluteString ?? "Invalid URL")
            print(request.httpBody?.convertDataToJSON() ?? "No Parameters")
            print("===== Request End =====")
       }
        return try URLEncoding.default.encode(request ,with: nil)
    }
}
