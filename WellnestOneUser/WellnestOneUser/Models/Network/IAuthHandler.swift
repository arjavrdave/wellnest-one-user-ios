//
//  IAuthHandler.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Alamofire

protocol IAuthHandler: RequestRetrier, RequestAdapter {
    var bearerToken : IBearerToken?   { get set }
    
}
