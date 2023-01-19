//
//  GetInTouchRouter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 07/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
class GetInTouchPresenter: NSObject {

    private var interfaceVC : GetInTouchViewController?
    
    convenience init(viewController: GetInTouchViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    func getInTouch(account: IPatient?) {
        account?.getInTouch(completion: { (error) in
            if error == nil {
                self.interfaceVC?.UpdateUIBySuccess()
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
}
