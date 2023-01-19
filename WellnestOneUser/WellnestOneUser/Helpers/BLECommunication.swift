//
//  BLECommunication.swift
//  Wellnest Technician
//
//  Created by Arjav on 25/08/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import WellnestBLE

open class CommunicationModule: NSObject {
    public static func getCommunicationHandler() -> CommunicationProtocol {
        #if DEBUG
            return CommunicationFactory.getCommunicationHandler()
        #else
            return CommunicationFactory.getCommunicationHandler()
        #endif
    }
}
