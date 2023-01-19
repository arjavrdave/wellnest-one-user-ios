//
//  AuthHandler.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Alamofire

class AuthHandler: IAuthHandler {
    var bearerToken: IBearerToken?

    init(bearer: IBearerToken) {
        self.bearerToken = bearer
    }
    
    /// Intercept 401 and do an OAuth2 authorization.

    func should(_ manager: SessionManager, retry request: Request, with error: Error, completion: @escaping RequestRetryCompletion) {

        if let response = request.task?.response as? HTTPURLResponse, response.statusCode == 401, let _ = request.request {
            self.bearerToken?.refreshToken(completion: { (response) in
                completion(response.result.isSuccess, 0)
            })
        }
        else {
            completion(false, 0.0)   // not a 401, not our problem
        }

    }
    
    /// Sign the request with the access token.
    func adapt(_ urlRequest: URLRequest) throws -> URLRequest {
        var request = urlRequest

        if let bearerToken = self.bearerToken?.getToken() {
            request.addValue(bearerToken, forHTTPHeaderField: "Authorization")
        }
        request.addValue("utf-8", forHTTPHeaderField: "Accept-Encoding")
        request.addValue("Application/json", forHTTPHeaderField: "Content-Type")
        request.addValue(AppConfiguration.apiKey, forHTTPHeaderField: "apiKey")
        request.addValue(AppConfiguration.apiPassword, forHTTPHeaderField: "apiPassword")
        request.addValue(AppConfiguration.versionName, forHTTPHeaderField: "versionName")
        request.addValue(AppConfiguration.versionCode, forHTTPHeaderField: "versionCode")
        request.addValue("ios", forHTTPHeaderField: "platform")
        request.timeoutInterval = 60
        return request
    }
    
    
    
}
