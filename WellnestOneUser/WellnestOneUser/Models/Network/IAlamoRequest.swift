//
//  IAlamoRequest.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//


import Alamofire

protocol IAlamoRequest {
    
    var authHandler: IAuthHandler? { get set }
    func makeRequest(url: URLRequestConvertible) -> DataRequest
}
