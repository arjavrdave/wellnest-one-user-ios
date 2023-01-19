//
//  GettingTouchThanksViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 03/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit

class GettingTouchThanksViewController: UIViewController {

    
    @IBOutlet weak var lblWellnestLink: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnWellnestLinkTapped(_ sender: UIButton) {
        guard let url = URL(string: "https://www.wellnest.tech") else { return }
        UIApplication.shared.open(url)
    }
    
}
