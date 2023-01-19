//
//  UILoader.swift
//  wellnest-ios
//
//  Created by Rakib Royale on 14/12/18.
//  Copyright © 2018 WellNest. All rights reserved.
//

import UIKit
import Lottie

class UILoader: UIView {

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
        UILoader.startAnimatingWith()
    }
    class func startAnimatingWith() {
        var loaderView = AnimationView()
        let animation = Animation.named("loader")
        loaderView.animation = animation
        loaderView.loopMode = LottieLoopMode.loop
        loaderView.play()
        
        for loader in self.viewController.view.subviews {
            if loader is AnimationView {
                loaderView = loader as! AnimationView
                break
            }
        }
        
        if loaderView.frame.equalTo(CGRect.zero) {
            loaderView.frame = self.viewController.view.frame
            loaderView.backgroundColor = UIColor.black.withAlphaComponent(0.8)
            
            loaderView.transform = .identity
            self.viewController.view.addSubview(loaderView)
        }
    }
    
    
    class func stopAnimating() {
        var loaderView = AnimationView()
        for loader in self.viewController.view.subviews {
            if loader is AnimationView {
                loaderView = loader as! AnimationView
                break
            }
        }
        loaderView.stop()
        DispatchQueue.main.async {
            loaderView.removeFromSuperview()
        }

    }
    
    class private func getImageList() -> [UIImage] {
        return []
    }
}
