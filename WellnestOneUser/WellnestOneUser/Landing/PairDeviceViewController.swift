//
//  PairDeviceViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 22/11/22.
//

import UIKit
import SwinjectStoryboard
class PairDeviceViewController: UIParentViewController {

    var recording: IRecordings?
    var isReRecordFlow: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    @IBAction func btnNextTapped(_ sender: UIButton) {
        let storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: PairDeviceListViewController.self)) as! PairDeviceListViewController
        vc.recording = self.recording
        vc.isReRecordFlow = self.isReRecordFlow
        self.navigationController?.pushViewController(vc, animated: true)
    }
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }

}
