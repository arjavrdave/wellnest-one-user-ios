//
//  HomeRecordPresenter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 10/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import UIKit
class HomeViewPresenter: NSObject {

    private var interfaceVC : HomeViewController?
    
    convenience init(viewController: HomeViewController) {
        self.init()
        self.interfaceVC = viewController
    }
        
    func getRecordings(recording: IRecordings?) {
        recording?.getRecordings(completion: { (recordingList, error) in
            if error == nil {
                if let recordings = recordingList {
                    self.interfaceVC?.updateUIby(recordings: recordings)
                }
            } else {
                self.interfaceVC?.showError(error: error!)
                self.interfaceVC?.refreshControl.endRefreshing()
            }
        })
    }
    
    func searchRecording(recording: IRecordings?) {
        recording?.getRecordings(completion: { (recordingList, error) in
            if error == nil {
                if let recordings = recordingList {
                    self.interfaceVC?.updateUIBy(searchedRecordings: recordings)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    func getSASToken(storage : IStorage?) {
        storage?.getReadTokenForUser { (storage, error) in
            if error == nil {
                SASTokenPublicRead = storage?.sasToken ?? ""
            } else {
                self.interfaceVC?.showError(error: error)
            }
        }
    }
}


