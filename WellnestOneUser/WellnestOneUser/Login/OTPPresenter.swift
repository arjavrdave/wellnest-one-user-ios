//
//  OTPPresenter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 08/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import UIKit
import Amplitude

class OTPPresenter: NSObject {

    private var interfaceVC : OTPViewController?
    
    convenience init(viewController: OTPViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    func verifyOTP(account: IAccount? ) {
        account?.verifyOTP(completion: { (bearerToken, error) in
            if error == nil {
                self.interfaceVC?.updateUIBySuccess()
            } else {
                self.interfaceVC?.updateUIbyError(error: error)
            }
        })
    }
    
    func resendOTP(account: IAccount?) {
        account?.resendVerificationOTP(completion: { (error) in
            if error == nil {
                self.interfaceVC?.updateUIbyOTPResent()
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
}
