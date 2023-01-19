//
//  PreRecordingConnectionViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 03/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import WellnestBLE
import SwinjectStoryboard

enum RecordingType {
    case standardECG
    case continueousECG
}

class PreRecordingConnectionViewController: UIParentViewController, StatusDelegate, UIScrollViewDelegate {
    
    var recording : IRecordings?
    
    @IBOutlet weak var imageBattery: UIImageView!
    @IBOutlet weak var imageBatteryStatus: UIProgressView!
    
    @IBOutlet weak var imageConnections: UIImageView!
    @IBOutlet weak var viewReadyRec: UIViewShadow!
    
    @IBOutlet weak var btnRecordECG: UIButtonSoftUI!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var scrollView: UIScrollView!
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    var isReRecordFlow = false
    var recordingType: RecordingType = .standardECG
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.communicationHandler.statusDelegate = self
        self.communicationHandler.getBatteryStatus()
        self.scrollView.delegate = self
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.communicationHandler.getElectrodeStatus()
        }
        if self.recording?.id != nil {
            self.btnRecordECG.setTitle("    Re-Record ECG", for: .normal)
        } else {
            self.btnRecordECG.setTitle("    Record ECG", for: .normal)
        }
        
        let transform : CGAffineTransform = CGAffineTransform(scaleX: 1.0, y: 2.3)
        self.imageBatteryStatus.transform = transform
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func pageControlValueChanged(_ sender: UIPageControl) {
            let pageSize: CGSize = self.scrollView.bounds.size
            let pageOrigin: CGPoint = CGPoint(x: CGFloat(sender.currentPage) * pageSize.width, y: 0.0)

            // Scroll to corresponding page when current page index of page control is changed
            self.scrollView.scrollRectToVisible(CGRect(origin: pageOrigin, size: pageSize), animated: true)
        }
    @IBAction func btnRecordTapped(_ sender: UIButton) {
        if communicationHandler.isConnected() {
            let storyB = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: CheckConnectionViewController.self)) as! CheckConnectionViewController
            vc.recording = self.recording
            vc.isReRecordFlow = self.isReRecordFlow
            vc.recordingType = recordingType
            self.navigationController?.pushViewController(vc, animated: true)
            
        } else {
            UIAlertUtil.alertWith(title: "Alert", message: "Device is disconnected. Please connect and try again.", viewController: self) { (_) in
                let viewControllers: [UIViewController] = self.navigationController!.viewControllers as [UIViewController]
                self.navigationController!.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
            }
        }
    }
    
    func didGetBatteryStatus(batteryLevel: Int8, chargingLevel: Int8) {
        print("Battery level ", batteryLevel , " Charging level"  , chargingLevel)
        
        if batteryLevel < 2 {
            UIAlertUtil.alertWith(title: "Low Battery", message: "Please charge your ECG device for accurate results.", viewController: self) { result in
                print("doe")
            }
            self.imageBatteryStatus.progress = 0.1
            self.imageBatteryStatus.progressTintColor = UIColor(red: 225/255, green: 87/255, blue: 87/255, alpha: 1) // Red
        } else if batteryLevel < 4  {
            self.imageBatteryStatus.progress = 0.25
            self.imageBatteryStatus.progressTintColor = UIColor(red: 235/255, green: 160/255, blue: 59/255, alpha: 1) //Yellow
        } else {
            self.imageBatteryStatus.progress = 1.0
            self.imageBatteryStatus.progressTintColor = UIColor(red: 0, green: 189/255, blue: 127/255, alpha: 1) // Green
        }
    }
    
    func didGetElectrodeStatus(electrodeStatus: Array<UInt8>) {
        
        let e1 = electrodeStatus.first
        let data = String.init(describing: e1 ?? UInt8.init())

        print("data",data)
        let d2 = Int.init(data)
        let b2 = String.init((d2 ?? 0), radix: 2, uppercase: false)
        print("Printing value",b2) // "10101"

        var index = 0
        var readySum = 0
        
        if electrodeStatus.count == 2 {
            let e2 = electrodeStatus.last
            let data = String.init(describing: e2 ?? UInt8.init())
            let d3 = Int.init(data)
            let b3 = String.init((d3 ?? 0), radix: 2, uppercase: false)
            let status2 = Int.init(String.init(b3[0])) ?? 0
            readySum = readySum + Int(status2)
        }
        for stat in b2 {
            let status = Int.init(String.init(stat)) ?? 0
            if index == 6{
                readySum = readySum + Int(status)
                
            } else if index == 7 {
                readySum = readySum + Int(status)

            } else if index == 5 {
                readySum = readySum + Int(status)

            } else if index == 4 {
                readySum = readySum + Int(status)

            } else if index == 3 {
                readySum = readySum + Int(status)

            } else if index == 2 {
                readySum = readySum + Int(status)

            } else if index == 1 {
                readySum = readySum + Int(status)

            } else if index == 0 {
                readySum = readySum + Int(status)

            }
            index += 1
            
        }
        
        self.viewReadyRec.backgroundColor = readySum == 9 ? UIColor.colorGreen : UIColor.colorRed
        
        
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // Update current page index of page control
        let pageIndex = Int(max(0.0, round(scrollView.contentOffset.x / scrollView.bounds.width)))
        if pageIndex != self.pageControl.currentPage {
            self.pageControl.currentPage = pageIndex
            self.pageControl.updateCurrentPageDisplay()
        }
    }
}
