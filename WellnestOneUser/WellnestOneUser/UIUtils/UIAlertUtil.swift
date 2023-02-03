//
//  UIAlertUtil.swift
//  SameHere
//
//  Created by Mayank Verma on 11/03/20.
//  Copyright © 2020 Royale Cheese. All rights reserved.
//

import Foundation
import UIKit

class UIAlertUtil {
    
    /// Show Error using error, viewcontroller and return NumberCompletionHandler
    class func show(error: Error?, viewController: UIViewController, With completion:@escaping NumberCompletionHandler) {
        if let errorMessage = error?.localizedDescription {
            if errorMessage == "FORCE_UPDATE" {
                self.alertWith(title: "Update Available".localized(), message: "There is a newer version of Saiyarti available. Please update to continue using it.".localized(), OkTitle: "Update", viewController: viewController) { (index) in
                    if index == 0 {
                        UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            exit(0)
                        }
                    } else if index == 1 {
                        if let url = URL(string: "itms-apps://itunes.apple.com/app/id1459650287"),
                        UIApplication.shared.canOpenURL(url){
                            UIApplication.shared.open(url, options: [:]) { (completed) in
                                UIControl().sendAction(#selector(NSXPCConnection.suspend), to: UIApplication.shared, for: nil)
                                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                    exit(0)
                                }
                            }
                        }
                    }
                }

            } else {
                self.alertWith(title: "Error!", message: errorMessage, viewController: viewController, With: completion)
            }
        }
    }
    
    /// Show alert using title, message, viewcontroller and return NumberCompletionHandler
    class func alertWith(title: String, message: String, viewController: UIViewController, With completion:@escaping NumberCompletionHandler) {
        self.alertWith(title: title, message: message, OkTitle: "Ok", viewController: viewController, With: completion)
    }
    
    /// Show alert using title, message, OkTitle, viewcontroller and return NumberCompletionHandler
    class func alertWith(title: String, message: String, OkTitle: String, viewController: UIViewController, With completion:@escaping NumberCompletionHandler) {
        self.alertWith(title: title, message: message, OkTitle: OkTitle, cancelTitle: "", viewController: viewController, With: completion)
    }
    
//    class func alertWithTextField(title: String, message: String, OkTitle: String, cancelTitle: String, viewController: UIViewController,placeHolderText:String,isSecuredText: Bool, With completion:@escaping NumberCompletionHandler) {
//        // Number Completion ok = 1, cancel = 0
//        let alertController = UIAlertController(title: title.localized(), message: message.localized(), preferredStyle: .alert)
//        let okAction = UIAlertAction(title: OkTitle.localized(), style: .default) { (action) in
//            completion(1)
//        }
//        alertController.addAction(okAction)
//        let textField = UITextField.init
//        
//        if cancelTitle.count > 0 {
//            let cancelAction = UIAlertAction(title: cancelTitle.localized(), style: .cancel) { (action) in
//                completion(0)
//            }
//            alertController.addAction(cancelAction)
//        }
//        DispatchQueue.main.async {
//            viewController.present(alertController, animated: true, completion: nil)
//        }
//    }

    
    /// Show alert using title, message, OkTitle, CancelTitle, viewcontroller and return NumberCompletionHandler
    class func alertWith(title: String, message: String, OkTitle: String, cancelTitle: String, viewController: UIViewController, With completion:@escaping NumberCompletionHandler) {
        // Number Completion ok = 1, cancel = 0
        let alertController = UIAlertController(title: title.localized(), message: message.localized(), preferredStyle: .alert)
        let okAction = UIAlertAction(title: OkTitle.localized(), style: .default) { (action) in
            completion(1)
        }
        alertController.addAction(okAction)
        
        if cancelTitle.count > 0 {
            let cancelAction = UIAlertAction(title: cancelTitle.localized(), style: .cancel) { (action) in
                completion(0)
            }
            alertController.addAction(cancelAction)
        }
        DispatchQueue.main.async {
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
    
    /// Show alertWithImagePicker using title, message, viewcontroller and return GrantCompletionHandler
    class func alertWithImagePicker(title: String, message: String, viewController: (UIViewController & UIImagePickerControllerDelegate & UINavigationControllerDelegate), With completion:@escaping NumberCompletionHandler) {
        
        self.alertWithAction(title: title, message: message, buttonTitles: ["Camera", "Gallery"], viewController: viewController, With: { (index) in
            let imagePickerController = UIImagePickerController()
            imagePickerController.delegate = viewController
            imagePickerController.mediaTypes = ["public.image"]
            switch index {
            case 1 :
                UIPermission.CheckCameraPermission { (isGranted) in
                    DispatchQueue.main.async {
                        if isGranted {
                            DispatchQueue.main.async {
                                if UIImagePickerController.isSourceTypeAvailable(.camera) {
                                    imagePickerController.sourceType = .camera
                                    imagePickerController.allowsEditing = true
                                    imagePickerController.showsCameraControls = true
                                    imagePickerController.cameraDevice = (UIImagePickerController.isCameraDeviceAvailable(.rear)) ? .rear : .front
                                    
                                    viewController.present(imagePickerController, animated: true, completion: {
                                        completion(index)
                                    })
                                } else {
                                    UIAlertUtil.alertWith(title: "Error", message: CommonError.Error_CameraDetect, viewController: viewController, With: { (_) in })
                                }
                            }
                        } else {
                            DispatchQueue.main.async {
                                UIAlertUtil.alertWith(title: "Permission Error", message: CommonError.Error_CameraPermission, viewController: viewController, With: { (_) in
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (_) in })
                                })
                            }
                        }
                    }
                }
                break
            case 2:
                DispatchQueue.main.async {
                    UIPermission.CheckGalleryPermission(with: { (isGranted) in
                        if isGranted {
                            DispatchQueue.main.async {
                                imagePickerController.sourceType = .photoLibrary
                                imagePickerController.allowsEditing = true
                                viewController.present(imagePickerController, animated: true, completion: {
                                    completion(index)
                                })
                            }
                        } else {
                            DispatchQueue.main.async {
                                UIAlertUtil.alertWith(title: "Permission Error", message: CommonError.Error_GalleryPermission, viewController: viewController, With: { (_) in
                                    UIApplication.shared.open(URL(string: UIApplication.openSettingsURLString)!, options: [:], completionHandler: { (_) in })
                                })
                            }
                        }
                    })
                }
                break
            default:
                completion (index)
                break
            }
        })
    }
    
    /// Show alertWithAction using title, message, buttonTitles, viewcontroller and return NumberCompletionHandler

    class func alertWithAction(title: String, message: String, buttonTitles: [String], viewController: UIViewController, With completion:@escaping NumberCompletionHandler) {
        let alertController = UIAlertController(title: title.localized(), message: message.localized(), preferredStyle: .actionSheet)
        
        
        for index in 0..<buttonTitles.count {
            let action = UIAlertAction(title: buttonTitles[index].localized(), style: .default) { (action) in
                completion(index + 1)
            }
            alertController.addAction(action)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel".localized(), style: .cancel) { (action) in
            completion(0)
        }
        alertController.addAction(cancelAction)
        
        DispatchQueue.main.async {
//            UILoader.stopAnimating()
            viewController.present(alertController, animated: true, completion: nil)
        }
    }
}
