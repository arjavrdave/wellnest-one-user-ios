//
//  AlamoRequest.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Alamofire

class AlamoRequest: SessionDelegate, IAlamoRequest {
    
    var authHandler: IAuthHandler?
    
    init(auth: IAuthHandler) {
        self.authHandler = auth
    }
    
    func makeRequest(url: URLRequestConvertible) -> DataRequest {
        let serverTrustPolicies: [String: ServerTrustPolicy] = [
            "wellest.tech" : .disableEvaluation,
        ]
        
        var sessionManager = SessionManager ( // Make sure you keep a reference of this guy somewhere
            serverTrustPolicyManager: ServerTrustPolicyManager (
                policies: serverTrustPolicies
            )
        )

        sessionManager = Alamofire.SessionManager.default // Original
        sessionManager.adapter = self.authHandler
        sessionManager.retrier = self.authHandler
        return sessionManager.request(url).validate()
    }
}
