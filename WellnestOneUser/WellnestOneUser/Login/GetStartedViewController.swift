//
//  GetStartedViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 03/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import Amplitude

class GetStartedViewController: UIParentViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnGetInTouchTapped(_ sender: UIButton) {

        UIView.animate(withDuration: 0.2) {
            self.view.layoutIfNeeded()

        } completion: { (_) in
            let storyB = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: GetInTouchViewController.self)) as! GetInTouchViewController
            self.navigationController?.pushViewController(vc, animated: false)
        }
    }
    
    @IBAction func btnLoginSignupTapped(_ sender: UIButton) {
        let storyB = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: LoginViewController.self)) as! LoginViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
