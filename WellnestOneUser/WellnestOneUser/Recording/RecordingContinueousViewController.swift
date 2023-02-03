//
//  RecordingContinueousViewController.swift
//  Wellnest Technician
//
//  Created by Mohit Kokwani on 24/03/22.
//  Copyright © 2022 Wellnest Inc. All rights reserved.
//

import UIKit
import WellnestBLE
import SwinjectStoryboard

class RecordingContinueousViewController: UIParentViewController, RecordingDelegate {
    
    var recording : IRecordings?
    
    @IBOutlet weak var viewLineHeader: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    

    @IBOutlet weak var lblRecordTimer: UILabel!
    @IBOutlet weak var lblTestDate: UILabel!
    
    @IBOutlet var viewLineCharts: [RealTimeVitalChartView]!
    
    
    @IBOutlet weak var viewRecording: UIViewShadow!
    
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    var recordingStorage = Array.init(repeating: [Double](), count: 12)
    var isReRecordFlow = false
    var timer: Timer?
    var timeInsSeconds = 10
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setupView()
        self.communicationHandler.recordingDelegate = self
        self.communicationHandler.startRecording()
        if let peripheralJSON = UserDefaults.standard.object(forKey: "peripheral") as? String {
            let decoodedPeripheral = peripheralJSON.decodable(WellnestPeripheral.self)
            self.recording?.ecgDeviceId = decoodedPeripheral?.id ?? 0
        }
        self.lblRecordTimer.text = String(format:
                                            "%02d:%02d",
                                            (timeInsSeconds % 3600) / 60,
                                            (timeInsSeconds % 60)
                                        )
        self.timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(updateTimer), userInfo: nil, repeats: true)
        // Do any additional setup after loading the view.
        initChart()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for charts in viewLineCharts {
            charts.updateChartSize()
        }
    }
    
    func initChart() {
        let spec = Spec(oneSecondDataCount: 500,
                        visibleSecondRange: 3,
                        refreshGraphInterval: 0.1,
                        vitalMaxValue: 0.5,
                        vitalMinValue: -0.5)
        for charts in viewLineCharts {
            charts.setRealTimeSpec(spec: spec)
        }
        
    }
    
    func getLiveRecording(rawData: [[Double]]) {
        for index in 0..<12 {
            self.recordingStorage[index].append(rawData[index][0])
        }
        if recordingStorage[0].count == 3 {
            self.medianFiltering()
        }
    }
    
    func medianFiltering() {
        for index in 0..<recordingStorage.count {
            let median = recordingStorage[index].median()
            viewLineCharts[index].dataHandler.enqueue(value: median)
            recordingStorage[index].remove(at: 0)
        }
    }
    
    func recordingCompleted(rawData: Data, parsedData: [[Double]]) {
        UILoader.stopAnimating()
        if communicationHandler.isConnected() {
            self.recording?.recordingRawData = rawData
            
            var viewControllerList = [UIViewController]()
            let storyBL = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
            let vcL = storyBL.instantiateViewController(withIdentifier: String.init(describing: HomeViewController.self)) as! HomeViewController
            viewControllerList.append(vcL)
            
            let storyBR = SwinjectStoryboard.create(name: "Recording", bundle: Bundle.main, container: self.initialize.container)
            let vcR = storyBR.instantiateViewController(withIdentifier: String.init(describing: RecordingPreviewViewController.self)) as! RecordingPreviewViewController
            vcR.recording = self.recording
            vcR.pageType = .withoutPatient
            viewControllerList.append(vcR)
            
            self.navigationController?.setViewControllers(viewControllerList, animated: true)
        }
    }
    
    func recordingDisrupted() {
        print("Recording Disrupted")
    }
    
    func setupView(){
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd MMM, yyyy | h:mm a"
        let currentDate = Date()
        let dateStr = dateFormatter.string(from: currentDate)
        self.lblTestDate.text = dateStr
        
        self.lblRecordTimer.layer.cornerRadius = 5
        self.lblRecordTimer.layer.masksToBounds = true
        if let image = UIImage(named: "ecg_graph")?.resizableImage(withCapInsets: .zero) {
            for charts in viewLineCharts {
                charts.backgroundColor = UIColor(patternImage: image)
            }
        }
        for charts in viewLineCharts {
            charts.lineColor = UIColor.black
            charts.valueCircleIndicatorColor = UIColor.black
        }
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        UIAlertUtil.alertWith(title: "STOP RECORDING", message: "Are you sure you want to stop ECG Recording?", OkTitle: "Yes",cancelTitle: "No",viewController: self) { (index) in
            if index == 1 {
                self.timer?.invalidate()
                self.communicationHandler.stopRecording(wantData: false)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        for charts in viewLineCharts {
            charts.dataHandler.stop()
        }
    }
    @objc func updateTimer() {
        self.timeInsSeconds -= 1
        if timeInsSeconds == 0 {
            self.timer?.invalidate()
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
                self.communicationHandler.stopRecording(wantData: true)
                UILoader.startAnimating()
            })
        }
        self.lblRecordTimer.text = String(format:
            "%02d:%02d",
            (timeInsSeconds % 3600) / 60,
            (timeInsSeconds % 60)
        )
        
    }
    
}
