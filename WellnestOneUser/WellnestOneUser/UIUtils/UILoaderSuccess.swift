//
//  UILoaderSuccess.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 20/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit

class UISuccessLoader: UIView {

    private static let imageViewTag = 99

    private static var viewController: UIViewController {
        get {
            let appDelegate = UIApplication.shared.delegate
            var vc = appDelegate?.window??.rootViewController
            
            if vc is UINavigationController {
                vc = (vc as! UINavigationController).visibleViewController
            }
            return vc!
        }
    }
    
    class func startAnimating() {
        UISuccessLoader.startAnimatingWith(message: "")
    }
    class func startAnimatingWith(message: String) {
        var loaderView = UISuccessLoader()
        
        for loader in self.viewController.view.subviews {
            if loader is UISuccessLoader {
                loaderView = loader as! UISuccessLoader
                break
            }
        }
        
        if loaderView.frame.equalTo(CGRect.zero) {
            loaderView.frame = self.viewController.view.frame
            if #available(iOS 13.0, *) {
                loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            } else {
                loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.4)
            }
            loaderView.transform = .identity
            self.viewController.view.addSubview(loaderView)
        }
        
        var viewImage = loaderView.viewWithTag(self.imageViewTag)
        
        if viewImage == nil {
            
            viewImage = UIView.init(frame: CGRect.init(x: 0, y: 0, width: self.viewController.view.frame.width / 1.5, height: self.viewController.view.frame.width / 1.5))
            if #available(iOS 13.0, *) {
                viewImage?.backgroundColor = UIColor.systemBackground
            } else {
                viewImage?.backgroundColor = UIColor.white
            }
            viewImage?.center = self.viewController.view.center
            viewImage?.tag = self.imageViewTag
            loaderView.layer.shadowColor = UIColor.gray.cgColor
            loaderView.layer.shadowOpacity = 0.4
            loaderView.layer.shadowRadius = 5
            loaderView.layer.shadowOffset = CGSize.init(width: 4, height: 4)
            loaderView.layer.masksToBounds = true
            viewImage?.layer.cornerRadius = 10
            viewImage?.clipsToBounds = true

            let imageGIF = UIImageView.init(frame: CGRect.init(x: 0, y: 20, width: self.viewController.view.frame.width / 1.5, height: (self.viewController.view.frame.width / 2) - 50))
            imageGIF.image = UIImage.gifImageWithName("confirmation_small", duration: 6)
            imageGIF.contentMode = .scaleAspectFit
            imageGIF.clipsToBounds = true
            viewImage?.addSubview(imageGIF)
            
            let label = UILabel.init(frame: CGRect.init(x: 0, y: imageGIF.frame.maxY, width: viewImage?.frame.width ?? 0, height: 100))
            label.numberOfLines = 0
            label.backgroundColor = UIColor.clear
            label.textColor = UIColor.colorFrom(hexString: "#666666")
            label.text = message 
            label.font = UIFont.Helvetica_Bold(fontSize: 18)
            label.textAlignment = .center
            
            viewImage?.addSubview(label)
            loaderView.addSubview(viewImage!)

            loaderView.layoutIfNeeded()


        }
        
        UIView.animate(withDuration: 0.2, animations: {
            viewImage?.transform = CGAffineTransform.init(scaleX: 1.2, y: 1.2)
        }) { (isCompleted) in
            if isCompleted {
                UIView.animate(withDuration: 0.2, animations: {
                    viewImage?.transform = CGAffineTransform.identity
                })
            }
        }
        
        let deadlineTime = DispatchTime.now() + .milliseconds(3600)
        DispatchQueue.main.asyncAfter(deadline: deadlineTime) {
            self.stopAnimating()
        }
    }
    
    @objc func sentButtonTapp() {
        UISuccessLoader.stopAnimating()
    }
    
    class func stopAnimating() {
        var loaderView = UISuccessLoader()
        for loader in self.viewController.view.subviews {
            if loader is UISuccessLoader {
                loaderView = loader as! UISuccessLoader
                break
            }
        }
        DispatchQueue.main.async {
            loaderView.removeFromSuperview()
        }
    }
    
    class private func getImageList() -> [UIImage] {
        return []
    }
}
