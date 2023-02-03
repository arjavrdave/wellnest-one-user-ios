//
//  LoginPresenter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 08/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
class LoginPresenter: NSObject {

    private var interfaceVC : LoginViewController?
    
    convenience init(viewController: LoginViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    func login(account: IAccount?) {
        account?.login(completion: { (error) in
            if error == nil {
                self.interfaceVC?.updateUIbyResponse(isSuccess: true)
            } else {
                if error!.localizedDescription != "FORCE_UPDATE" {
                    self.interfaceVC?.updateUIbyResponse(isSuccess: false)
                }
                self.interfaceVC?.showError(error: error)
            }
        })
    }
}
