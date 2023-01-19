//
//  IBearerToken.swift
//  SameHere
//
//  Created by Mayank Verma on 27/01/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import UIKit

protocol IBearerToken: Codable {
    var text            : String?   { get set }
    var token           : String?   { get set }
    var validity        : Date?     { get set }
    var refreshToken    : String?   { get set }
    var isNewUser       : Bool?     { get set }
    var id              : Int?      { get set }
    func getToken() -> String?
    func refreshToken(completion: @escaping ResponseStringCompletionHandler)
    func saveToken()
}
