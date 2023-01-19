//
//  UIPermission.swift
//  SameHere
//
//  Created by Mayank Verma on 11/03/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Foundation
import UIKit
import AVFoundation
import Photos

class UIPermission {
    class func CheckCameraPermission(with completion: @escaping GrantCompletionHandler) {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            completion(true)
            break
        default:
            AVCaptureDevice.requestAccess(for: .video) { (success) in
                completion(success)
            }
            break
        }
    }
    
    class func CheckGalleryPermission(with completion: @escaping GrantCompletionHandler) {

        switch PHPhotoLibrary.authorizationStatus() {
        case .authorized:
            completion(true)
            break
        default:
            PHPhotoLibrary.requestAuthorization { (status) in
                completion (status == .authorized)
            }
            break
        }
        
    }
}
