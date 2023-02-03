//
//  CreateProfilePresenter.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 11/11/22.
//

import Foundation
import UIKit
class CreateProfilePresenter: NSObject {
    private var interfaceVC : CreateProfileViewController?

    convenience init(viewController: CreateProfileViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    func createProfile(account: IAccount?, image: UIImage?, storage: IStorage?) {
        account?.createProfile(completion: { error in
            if error == nil {
                if let id = account?.id, let imageUpload = image {
                    var storageobj = storage
                    storageobj?.id = id
                    self.getSASTokenForUser(account: account, image: imageUpload, storage: storageobj)
                } else {
                    self.interfaceVC?.updateUIBySuccess()
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    func getSASTokenForUser(account: IAccount?, image: UIImage, storage: IStorage?) {
        storage?.getUploadTokenForUser(completion: { (storage, error) in
            if error == nil {
                if let sasToken = storage?.sasToken {
                    self.uploadUserPhoto(account: account, image: image, sasToken: sasToken)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    func uploadUserPhoto(account: IAccount?, image: UIImage, sasToken: String) {
        if let id = account?.profileId {
            AzureUtil.shared.uploadProfilePhoto(profileId: id, sasToken: sasToken, image: image) { (error) in
                
                if error == nil {
                    self.interfaceVC?.updateUIBySuccess()
                } else {
                    self.interfaceVC?.showError(error: error)
                }
            }
        }
    }
}
