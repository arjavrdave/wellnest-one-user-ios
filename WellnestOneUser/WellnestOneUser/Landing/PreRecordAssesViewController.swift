//
//  PreRecordingAssesmentViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 03/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import WellnestBLE
import Amplitude
import Reachability

class PreRecordAssesViewController: UIParentViewController, PeripheralDelegate, UIScrollViewDelegate {

    
    var reasonString: String = ""
    var recording: IRecordings?
    var isReRecordFlow: Bool = false
    
    @IBOutlet weak var viewBottom: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var btnRoutineCheckUp: UIButton!
    @IBOutlet weak var btnPreOperative: UIButton!
    @IBOutlet weak var btnPreLifeIns: UIButton!
    @IBOutlet weak var btnMediclaim: UIButton!
    @IBOutlet weak var btnPreEmployment: UIButton!
    @IBOutlet weak var btnSymtomatic: UIButton!
    @IBOutlet weak var btnChestPain: UIButton!
    @IBOutlet weak var btnUneasiness: UIButton!
    @IBOutlet weak var btnJawPain: UIButton!
    @IBOutlet weak var btnUpperBackPain: UIButton!
    @IBOutlet weak var btnPalpitation: UIButton!
    @IBOutlet weak var btnVomiting: UIButton!
    @IBOutlet weak var btnUnexplainedP: UIButton!
    @IBOutlet weak var btnBreathlessness: UIButton!
    @IBOutlet weak var btnOnExersion: UIButton!
    @IBOutlet weak var btnOthers: UIButton!
    @IBOutlet weak var txtViewOthers: UITextView!
    @IBOutlet weak var heightTxtViewOthers: NSLayoutConstraint!
    
    var communicationHandler: CommunicationProtocol = CommunicationModule.getCommunicationHandler()
    @IBOutlet weak var viewLineHeader: UIView!
    var reachability: Reachability?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.communicationHandler.peripheralDelegate = self;
        self.scrollView.delegate = self
        self.viewLineHeader.isHidden = true
        self.txtViewOthers.layer.cornerRadius = 5
        self.txtViewOthers.layer.borderColor = UIColor.colorFrom(hexString:"DDDDDD").cgColor
        self.txtViewOthers.layer.borderWidth = 1.0
    }
    
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            self.viewLineHeader.isHidden = false
        } else {
            self.viewLineHeader.isHidden = true
        }
    }

    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnRoutineCheckUpTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnPreOperativeTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnPreLifeInTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnPreMediclamTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnPreEmployTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnSymptomaticTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected

    }
    
    @IBAction func btnChestPTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnUneasinessTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnJawPainTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnUpperBPTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnPalpitationTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnVomitingTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnUnexplainedTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnBreathlessTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnOnExertionTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    @IBAction func btnOthersTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        self.heightTxtViewOthers.constant = sender.isSelected ? 80 : 0
    }
    @IBAction func btnNextTapped(_ sender: UIButton) {
        self.recording?.reason = ""
        self.reasonString = ""
        
        self.recording?.routineCheckUp = self.btnRoutineCheckUp.isSelected
        self.recording?.preOperativeAssessment = self.btnPreOperative.isSelected
        self.recording?.preLifeInsurance = self.btnPreLifeIns.isSelected
        self.recording?.preMediClaim = self.btnMediclaim.isSelected
        self.recording?.preEmployment = self.btnPreEmployment.isSelected
        self.recording?.chestPain = self.btnChestPain.isSelected
        self.recording?.uneasiness = self.btnUneasiness.isSelected
        self.recording?.jawPain = self.btnJawPain.isSelected
        self.recording?.upperBackPain = self.btnUpperBackPain.isSelected
        self.recording?.palpitation = self.btnPalpitation.isSelected
        self.recording?.vomiting = self.btnVomiting.isSelected
        self.recording?.unexplainedPerspiration = self.btnUnexplainedP.isSelected
        self.recording?.breathlessnessOnExertion = self.btnBreathlessness.isSelected
        self.recording?.breathlessnessOnResting = self.btnOnExersion.isSelected
        self.recording?.symptomatic = self.btnSymtomatic.isSelected
        if btnOthers.isSelected {
            self.recording?.others = self.txtViewOthers.text
        }
        if self.recording?.breathlessnessOnExertion ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Breathlessness on Exertion") : self.reasonString.append("Breathlessness on Exertion")
        }
        if self.recording?.breathlessnessOnResting ?? false{
            self.reasonString.count != 0 ? self.reasonString.append(", Breathlessness on Resting") : self.reasonString.append("Breathlessness on Resting")
        }
        if self.recording?.chestPain ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Chest Pain") : self.reasonString.append("Chest Pain")
        }
        if self.recording?.jawPain ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Jaw Pain") : self.reasonString.append("Jaw Pain")
        }
        if self.recording?.palpitation ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Palpitaion") : self.reasonString.append("Palpitaion")
        }
        if self.recording?.preEmployment ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Pre-Employment") : self.reasonString.append("Pre-Employment")
        }
        if self.recording?.preLifeInsurance ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Pre-Life Insurance") : self.reasonString.append("Pre-Life Insurance")
        }
        if self.recording?.preMediClaim ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Pre-Mediclaim") : self.reasonString.append("Pre-Mediclaim")
        }
        if self.recording?.preOperativeAssessment ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Pre-Operative Assessment") : self.reasonString.append("Pre-Operative Assessment")
        }
        if self.recording?.routineCheckUp ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Routine Checkup") : self.reasonString.append("Routine Checkup")
        }
        if self.recording?.uneasiness ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Uneasiness") : self.reasonString.append("Uneasiness")
        }
        if self.recording?.unexplainedPerspiration ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Unexplained Perspiration") : self.reasonString.append("Unexplained Perspiration")
        }
        if self.recording?.upperBackPain ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Upper Back Pain") : self.reasonString.append("Upper Back Pain")
        }
        if self.recording?.vomiting ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Vomiting") : self.reasonString.append("Vomiting")
        }
        if self.recording?.symptomatic ?? false {
            self.reasonString.count != 0 ? self.reasonString.append(", Symptomatic") : self.reasonString.append("Symptomatic")
        }
        if self.recording?.others?.trim().isEmpty ?? false {
            self.reasonString.count != 0 && self.recording?.others != "" ? self.reasonString.append(", \(self.recording?.others?.trim() ?? "")") : self.reasonString.append("\(self.recording?.others?.trim() ?? "")")
        }
        self.recording?.reason = self.reasonString
        let storyB = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: PreRecordingConnectionViewController.self)) as! PreRecordingConnectionViewController
        vc.recording = self.recording
        vc.isReRecordFlow = self.isReRecordFlow
        self.navigationController?.pushViewController(vc, animated: true)
        
    }
    
    func updateUIby(account: Account) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        
    }
    
    func didDisconnect(peripheral: WellnestPeripheral?, error: NSError?) {
        self.showError(error: error)
    }
    
    func didDiscoverPeripherals(peripherals: [WellnestBLE.WellnestPeripheral]){
        print("DISCOVERED")
    }

    func authentication(peripheral: WellnestBLE.WellnestPeripheral?, error: String?){
        
    }
    
    
    
}
