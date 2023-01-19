//
//  SplashViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 23/04/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SwiftJWT
import SwinjectStoryboard
import WellnestBLE

class SplashViewController: UIParentViewController {
    
    @IBOutlet weak var imageWave: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let window = UIApplication.shared.windows.first
        let topPadding = window?.safeAreaInsets.top
        
        self.scrollView.setContentOffset(CGPoint.init(x: (self.imageWave.bounds.maxX - UIScreen.main.bounds.width), y:  -(topPadding ?? 0)), animated: false)
        
        UIView.animate(withDuration: 2, animations: {
            self.scrollView.scrollRectToVisible(self.imageWave.frame, animated: true)
            self.view.layoutIfNeeded()
        }) { (complete) in
            if UserDefaults.bearerToken == nil {
                let storyboard = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
                let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: GetStartedViewController.self)) as! GetStartedViewController
                self.navigationController?.setViewControllers([vc], animated: true)
                
            } else {
                let storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
                let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: HomeViewController.self)) as! HomeViewController
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        }
    }
}
