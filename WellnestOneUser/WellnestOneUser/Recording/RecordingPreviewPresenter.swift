//
//  RecordingPreviewPresenter.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 24/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import Foundation
class RecordingPreviewPresenter : NSObject {
    
    var interfaceVC : RecordingPreviewViewController?
    var shouldLoaderStop = false
    private var count = 0
    convenience init(viewController : RecordingPreviewViewController) {
        self.init()
        self.interfaceVC = viewController
    }
    
    func getUploadTokenForRecording(storage: IStorage?, recording: IRecordings?) {
        storage?.getUploadTokenForECG(completion: { (storage, error) in
            if error == nil {
                if let st = storage {
                    if let fileName = recording?.fileName, let token = st.sasToken, let recordingData = recording?.recordingRawData{
                        self.updateRecordingAzure(fileN: fileName, token: token, dataRecording: recordingData, rec: recording)
                    }
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    
    func getTokenforRecording(storage: IStorage?) {
        storage?.getReadTokenForECG(completion: { (storage, error) in
            if error == nil {
                if let storageR = storage {
                    self.getRecordingData(fileName: self.interfaceVC?.storage?.fileName ?? "" , sasToken: storageR.sasToken ?? "")
                    //self.interfaceVC?.updateUIby(storage: storageR)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    
    func getRecordingForID(recording : IRecordings?) {
        recording?.getRecording(completion: { (recordingResp, error) in
            if error == nil {
                if let recordingData = recordingResp {
                    self.interfaceVC?.storage?.fileName = recordingData.fileName
                    self.getTokenforRecording(storage: self.interfaceVC?.storage)
                    self.interfaceVC?.updateUIBy(recording: recordingData)
                    self.interfaceVC?.updateUIByUpdatedCreated(recording: recordingData)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }

        })
    }
    
    func getRecordingData(fileName: String, sasToken: String) {
        let azureCloud = AzureUtil.shared
        azureCloud.getRecordingData(sasToken: sasToken, uuid: fileName) { (data, error) in
            if error == nil && data != nil {
                if let dataRecording = data {
                    self.interfaceVC?.recording?.recordingRawData = dataRecording
                    self.interfaceVC?.filterAndDisplayData()
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        }
    }

    
    func updateRecording(recordings: IRecordings?) {
        recordings?.updateRecording(completion: { (recording,error) in
            if error == nil {
                if let rec = recording {
                    self.interfaceVC?.updateUIByUpdatedCreated(recording: rec)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    
    func updateRecordingAzure(fileN : String, token: String, dataRecording: Data, rec: IRecordings?) {
        AzureUtil.shared.saveToECGRRecordingContainer(uuid: fileN, sasToken: token, recordingData: dataRecording) { (error) in
            if error == nil {
                DispatchQueue.global(qos: .background).async {
                    self.getReadToken { response, error in
                        if let sasToken = response?.sasToken {
                            AzureUtil.shared.isRecordingExists(sasToken: sasToken, uuid: fileN) { response, error in
                                if (response ?? 200 ) >= 400 {
                                    if self.count == 1 {
                                        self.interfaceVC?.updateUIbyUploadingError()
                                    } else {
                                        self.count += 1
                                        self.updateRecordingAzure(fileN: fileN, token: token, dataRecording: dataRecording, rec: rec)
                                    }
                                }
                            }
                        }
                    }
                }
                if rec?.id == nil {
                    self.createRecording(recording: rec)
                } else {
                    self.updateRecording(recordings: rec)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        }
    }
    
    func reRecordRecording(recording: IRecordings?) {
        recording?.reRecordRecording(completion: { (error) in
            if error == nil {
                //self.interfaceVC?.updateUIbyReRecordNotification()
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    
    func createRecording(recording: IRecordings?) {
        recording?.createRecordings(completion: { (recording, error) in
            if error == nil {
                if let rec = recording {
                    self.interfaceVC?.updateUIByUpdatedCreated(recording: rec)
                }
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    
    func getReadToken(objectCallback: @escaping ObjectCompletionHandler<Storage>) {
        
        if let storage = self.interfaceVC?.storage {
            storage.getReadTokenForECG(completion: { (storage, error) in
                objectCallback(storage, error)
            })
        }
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
    func sendForFeedback(recording: IRecordings?) {
        recording?.sendForFeedback(completion: { error in
            if error == nil {
                self.interfaceVC?.updateUIBySendForAnalysis()
            } else {
                self.interfaceVC?.showError(error: error)
            }
        })
    }
    func getReadSignatureSASToken(storage: IStorage?) {
        storage?.getReadTokenForSignature(completion: { (storage, error) in
            if error == nil {
                if let token = storage?.sasToken {
                    self.interfaceVC?.sasTokenForReadSignature = token
                    self.interfaceVC?.getSignature()
                }
            } else {
                self.interfaceVC?.currentLoadedStages += 1
                self.interfaceVC?.showError(error: error)
            }
        })
    }
}

