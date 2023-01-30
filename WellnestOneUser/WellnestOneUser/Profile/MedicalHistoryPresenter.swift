//
//  MedicalHistoryPresenter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 04/08/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import UIKit
class MedicalHistoryPresenter: NSObject {
    private var interfaceVC : MedicalHistoryViewController?

    convenience init(viewController: MedicalHistoryViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    func createProfile(account: IAccount?, image: UIImage?, storage: IStorage?) {
        account?.createProfile(completion: { error in
            if error == nil {
                if let id = account?.profileId, let imageUpload = image {
                    var storageobj = storage
                  //  storageobj?.id = id
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
    func getMedicalHistory(medicalHistory: IUserMedicalHistory?) {
        medicalHistory?.getMedicalHistory(completion: { response, error in
            if error == nil {
                if let medicalHistory = response {
                    self.interfaceVC?.updateUIBy(medicalHistory: medicalHistory)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    
    func updateMedicalHistory(medicalHistory: IUserMedicalHistory?) {
        medicalHistory?.updateMedicalHistory { (error) in
            if error == nil {
                self.interfaceVC?.updateUIBySuccess()
            } else {
                self.interfaceVC?.showError(error: error)
            }
        }
    }
}

