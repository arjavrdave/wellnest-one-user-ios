//
//  UpdateRequired.swift
//  Wellnest Technician
//
//  Created by Nihar Jagad on 04/04/22.
//  Copyright © 2022 Wellnest Inc. All rights reserved.
//

import Foundation
struct UpdateRequired: Codable {
    var isOldVersion: Bool?
    var text: String?
}
