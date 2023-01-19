//
//  BearerToken.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Alamofire

class BearerToken: IBearerToken {
    var text: String?
    
    var token: String?
    
    var validity: Date?
    
    var refreshToken: String?
    
    var isNewUser: Bool?
    
    var id: Int?
    
    init() {

        if let bearerToken = UserDefaults.bearerToken {
            self.token = bearerToken.token
            self.validity = bearerToken.validity
            self.refreshToken = bearerToken.refreshToken
            self.text = bearerToken.text
            self.isNewUser = bearerToken.isNewUser
            self.id = bearerToken.id
        }
    }
        
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.token = try? container.decodeIfPresent(String.self, forKey: .token)
        self.validity = try? container.decodeIfPresent(Date.self, forKey: .validity)
        self.refreshToken = try? container.decodeIfPresent(String.self, forKey: .refreshToken)
        self.text = try? container.decodeIfPresent(String.self, forKey: .text)
        self.isNewUser = try? container.decodeIfPresent(Bool.self, forKey: .isNewUser)
        self.id = try? container.decodeIfPresent(Int.self, forKey: .id)
    }
    
    enum CodingKeys: String, CodingKey {
        case token
        case validity
        case refreshToken
        case text
        case isNewUser
        case id
    }
    

    func getToken() -> String? {
        if let token = self.token {
            return "Bearer " + token
        }
        return nil
    }
    
    func refreshToken(completion: @escaping ResponseStringCompletionHandler) {
        if self.refreshToken != nil || self.token == nil {
            let error = NSError(domain: NSCocoaErrorDomain, code: 400, userInfo: [NSLocalizedDescriptionKey: "The token or refresh token is not available."]) as Error
//            let error = NSError(domain: NSCocoaErrorDomain, code: 400, userInfo: ["text":"The token or refresh token is not available."])
            let resultError = Result<String>.failure(error)
            let dataResponse = DataResponse<String>(request: nil, response: nil, data: nil, result: resultError)
            completion(dataResponse)
        }
        else {
            
            /*
                This is a specific case where we don't want to use IAlamoRequest since its specific to refreshing token
                IAlamoRequest will be using IAuthHandler which in turn might use this implementation to refresh token
                To avoid cyclic calling of refresh token we will use Alamofire.request directly
             */
            Alamofire.request(BearerTokenRouter.refereshToken(self)).validate().responseString { (response) in
                if response.result.isSuccess {
                    if let jsonString = response.result.value {
                        if let bearerToken = jsonString.convertJSONToClass(type: BearerToken.self) {
                            bearerToken.saveToken()
                        }
                    }
                }
                completion(response)
            }
        }
    }

    func saveToken() {
        UserDefaults.standard.setBearerToken(token: self)

        // TODO: Change below code when Validity and Refresh Token comes to play.
        //We will only save the bearer token if all the properties are valid
//        if(self.validity != nil && self.token != nil && self.refreshToken != nil){
//        }
    }
    
    
}
