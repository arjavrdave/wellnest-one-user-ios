//
//  ChooseMemberPresenter.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 17/12/22.
//

import Foundation
//
//  RecordingPreviewPresenter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 24/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import Foundation
class ChooseMemberPresenter : NSObject {
    
    var interfaceVC : ChooseMemberViewController?
    convenience init(viewController : ChooseMemberViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    
    
    func linkFamilyMember(patient: IPatient?, recordingId: Int) {
        patient?.linkFamilyMember(recordingId: recordingId, completion: { error in
            if error == nil {
                self.interfaceVC?.updateUIByLinkMemberSuccess()
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    func getAccount(account: IAccount?) {
        account?.getAccount(completion: { (account, error) in
            if error == nil {
                if let acc = account {
                    self.interfaceVC?.updateUIby(account: acc)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
}

