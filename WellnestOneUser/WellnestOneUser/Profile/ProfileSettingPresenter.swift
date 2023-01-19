//
//  ProfileSettingPresenter.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 17/11/22.
//

import Foundation
class ProfileSettingPresenter: NSObject {
    private var interfaceVC : ProfileSettingViewController?

    convenience init(viewController: ProfileSettingViewController) {
        self.init()
        self.interfaceVC = viewController
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
    func logout(account: IAccount?) {
        account?.logout(completion: { (error) in
            self.interfaceVC?.updateUIbyLogout()
        })
    }
    func deleteAccount(account: IAccount?) {
        account?.deleteAccount(completion: { (error) in
            if error == nil {
                self.logout(account: account)
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
}

