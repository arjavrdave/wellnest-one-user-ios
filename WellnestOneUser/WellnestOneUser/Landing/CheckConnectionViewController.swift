//
//  CheckConnectionViewController.swift
//  Wellnest Technician
//
//  Created by Nihar Jagad on 01/11/22.
//  Copyright © 2022 Wellnest Inc. All rights reserved.
//

import UIKit
import Firebase
import WellnestBLE
import FirebaseRemoteConfig
import SwinjectStoryboard
class CheckConnectionViewController: UIParentViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak  var constraitHeightTableView: NSLayoutConstraint!
    @IBOutlet weak var lblDeviceReady: UILabel!
    var defaultValue: [String: Any?] = [
        "active": true,
          "messages": [
            "Processing your request",
            "Checking your device connection",
            "Securing network",
            "Checking electrode connections",
            "Fetching data",
            "Calibrating the device",
            "Encrypting data",
            "Getting your device ready"
          ],
          "msgTime": 2000,
          "successTime": 300,
          "errorMsg": "Please verify your connections!",
          "threshold": -0.8
    ]
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    var recording: IRecordings?
    var isReRecordFlow: Bool = false
    var recordingType: RecordingType = .standardECG
    var actualParameters: [String: Any]?
    var currentStep: Int = -1
    var totalStep: Int = 0
    var timer: Timer?
    var threshold: Double = 0.0
    var averageArray = Array.init(repeating: 0.0, count: 12)
    private var n: Int = 1
    private var isThresholdReached = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.addObserver(self, forKeyPath: "contentSize", options: .new, context: nil)
        
        self.communicationHandler.recordingDelegate = self
        self.communicationHandler.startRecording()
        let settings = RemoteConfigSettings()
        settings.minimumFetchInterval = 0
        RemoteConfig.remoteConfig().configSettings = settings
        
        RemoteConfig.remoteConfig().setDefaults(defaultValue as? [String: NSObject])
        RemoteConfig.remoteConfig().fetch { status, error in
            if let error = error {
                print("Got an error fetching remote values \(error)")
                return
            }
            RemoteConfig.remoteConfig().activate { _, _ in
                self.actualParameters = RemoteConfig.remoteConfig().configValue(forKey: "ECGChecklist").stringValue?.convertJSONToDictionary()
                DispatchQueue.main.async {
                    self.tableView.reloadData()
                    
                    if let parameters = self.actualParameters {
                        if let threshold = parameters["threshold"] as? Double {
                            self.threshold = threshold
                        }
                        if let messages = parameters["messages"] as? [String] {
                            self.totalStep = messages.count
                        }
                        if let msgTime = parameters["msgTime"] as? Int {
                            self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(msgTime) / 1000.0), target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
                            self.timer?.addObserver(self, forKeyPath: "timeInterval", context: nil)
                        }
                    }
                }
            }
        }
        // Do any additional setup after loading the view.
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.tableView.removeObserver(self, forKeyPath: "contentSize")
    }
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if(keyPath == "contentSize"){
            if let newvalue = change?[.newKey]
            {
                DispatchQueue.main.async {
                    let newsize  = newvalue as! CGSize
                    self.constraitHeightTableView.constant = newsize.height
                }
                
            }
        }
    }
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func fireTimer() {
        if currentStep < totalStep {
            self.currentStep += 1
            if currentStep == totalStep {
                self.lblDeviceReady.textColor = UIColor.black
            } else {
                self.tableView.reloadRows(at: [IndexPath.init(item: self.currentStep, section: 0)], with: .automatic)
            }
        } else {
            self.timer?.invalidate()
            self.timer = nil
            if self.isThresholdReached {
                let storyB = SwinjectStoryboard.create(name: "Recording", bundle: Bundle.main, container: self.initialize.container)
                let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: RecordingContinueousViewController.self)) as! RecordingContinueousViewController
                vc.recording = self.recording
                vc.isReRecordFlow = self.isReRecordFlow
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                self.communicationHandler.stopRecording(wantData: false)
                if let parameters = self.actualParameters {
                    if let errorMessage = parameters["errorMsg"] as? String {
                        UIAlertUtil.alertWith(title: "Error", message: errorMessage , OkTitle: "Ok", viewController: self) { result in
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                }
            }
        }
    }
}
extension CheckConnectionViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let parameters = self.actualParameters {
            if let messages = parameters["messages"] as? [String] {
                return messages.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ConnectionStepTableViewCell", for: indexPath) as! ConnectionStepTableViewCell
        guard let parameters = self.actualParameters, let messages = parameters["messages"] as? [String] else {
            return cell
        }
        if indexPath.row == self.currentStep {
            cell.setupCell(stepTitle: messages[indexPath.row], isStepSelected: true)
        } else {
            cell.setupCell(stepTitle: messages[indexPath.row], isStepSelected: false)
        }
        
        return cell
        
    }
}

extension CheckConnectionViewController: RecordingDelegate {
    func recordingCompleted(rawData: Data, parsedData: [[Double]]) { }
    
    func recordingDisrupted() { }
    
    func getLiveRecording(rawData: [[Double]]) {
        for i in 0..<12 {
            self.averageArray[i] = (Double(self.n - 1) * self.averageArray[i] + rawData[i][0]) / Double(self.n)
        }
        let flag = self.averageArray.allSatisfy { $0 >= threshold }
        if flag {
            self.communicationHandler.stopRecording(wantData: false)
            self.isThresholdReached = true
            if let parameters = self.actualParameters {
                if let successTime = parameters["successTime"] as? Int {
                    self.timer?.invalidate()
                    self.timer = nil
                    self.timer = Timer.scheduledTimer(timeInterval: TimeInterval(Double(successTime) / 1000.0), target: self, selector: #selector(self.fireTimer), userInfo: nil, repeats: true)
                }
            }
        }
        self.n += 1
    }
}
