//
//  Doctor.swift
//  Prod
//
//  Created by Nihar Jagad on 28/11/22.
//  Copyright © 2022 Wellnest Inc. All rights reserved.
//

import Foundation
struct Doctor: Decodable {
    var id: Int?
    var firstName: String?
    var lastName: String?
    var qualification: String?
    var fullName: String? {
        get {
            if self.firstName?.starts(with: "Dr.") ?? false || self.firstName?.contains("Wellnest") ?? false {
                return (self.firstName?.capitalizingFirstLetter() ?? "") + " " + (self.lastName?.capitalizingFirstLetter() ?? "")
            } else {
                let first = "Dr. " + (self.firstName?.capitalizingFirstLetter() ?? "") + " "
                let last = (self.lastName?.capitalizingFirstLetter() ?? "")
                return first + last
            }
        }
    }
    var phoneNumber: String?
    var countryCode: Int?
    init(from decoder: Decoder) throws {
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.id                     = try? container?.decodeIfPresent(Int.self, forKey: .id)
        self.firstName        = try? container?.decodeIfPresent(String.self, forKey: .firstName)
        self.lastName        = try? container?.decodeIfPresent(String.self, forKey: .lastName)
        self.qualification        = try? container?.decodeIfPresent(String.self, forKey: .qualification)
        self.phoneNumber        = try? container?.decodeIfPresent(String.self, forKey: .phoneNumber)
        self.countryCode            = try? container?.decodeIfPresent(Int.self, forKey: .countryCode)
    }
    enum CodingKeys: String, CodingKey {
        case id
        case firstName
        case lastName
        case qualification
        case phoneNumber
        case countryCode
    }
}
