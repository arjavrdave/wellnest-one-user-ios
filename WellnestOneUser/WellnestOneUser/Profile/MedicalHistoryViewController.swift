//
//  MedicalHistoryViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 03/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import Amplitude
import CoreData

class MedicalHistoryViewController: UIParentViewController, UITextViewDelegate, UIScrollViewDelegate {
    
    var account: IAccount?
    var storage: IStorage?
    var medicalHistory : IUserMedicalHistory?
    @IBOutlet weak var viewLineHeader: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var txtVComment: UITextView!
    
    @IBOutlet weak var btnBloodPressure: UIButton!
    @IBOutlet weak var btnDiabetes: UIButton!
    @IBOutlet weak var btnHypothyroidism: UIButton!
    @IBOutlet weak var btnLipidIssue: UIButton!
    @IBOutlet weak var btnKidneyProblem: UIButton!
    @IBOutlet weak var btnStroke: UIButton!
    @IBOutlet weak var btnHeartProblem: UIButton!
    
    @IBOutlet weak var lblCount: UILabel!
    
    @IBOutlet weak var btnYes: UIButton!
    @IBOutlet weak var btnNo: UIButton!
    var presenter: MedicalHistoryPresenter?
    var userProfile: UIImage?
    var pageType: CreateEditPageType = .create
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNoTapped(UIButton.init())
        self.txtVComment.delegate = self
        self.scrollView.delegate = self
        self.viewLineHeader.isHidden = true
        self.presenter = MedicalHistoryPresenter(viewController: self)
        if pageType == .edit {
            DispatchQueue.main.async {
                UILoader.stopAnimating()
            }
            self.presenter?.getMedicalHistory(medicalHistory: self.medicalHistory)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = MedicalHistoryPresenter(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y > 0 {
            self.viewLineHeader.isHidden = false
        } else {
            self.viewLineHeader.isHidden = true
        }
    }

    func textViewDidChange(_ textView: UITextView) {
        self.lblCount.text = "\(textView.text.count)/240"
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UILoader.stopAnimating()
    }

    
    @IBAction func btnBackTappedTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnBloodPressureTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnDiabetesTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnHypothyroidTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnLipidIssueTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnKidneyTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnStrokeTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnHeartTapped(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
    }
    
    @IBAction func btnYesTapped(_ sender: UIButton) {
        self.btnYes.isSelected = true
        self.btnNo.isSelected = false
        
        self.medicalHistory?.siblingHeartProblem = true

    }
    
    @IBAction func btnNoTapped(_ sender: UIButton) {
        self.btnYes.isSelected = false
        self.btnNo.isSelected = true
        
        self.medicalHistory?.siblingHeartProblem = false
    }
    
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        self.medicalHistory?.bloodPressure = self.btnBloodPressure.isSelected
        self.medicalHistory?.diabetes = self.btnDiabetes.isSelected
        self.medicalHistory?.hypothyroidism = self.btnHypothyroidism.isSelected
        self.medicalHistory?.lipidsIssue = self.btnLipidIssue.isSelected
        self.medicalHistory?.kidneyProblem = self.btnKidneyProblem.isSelected
        self.medicalHistory?.stroke = self.btnStroke.isSelected
        self.medicalHistory?.heartProblem = self.btnHeartProblem.isSelected
        self.medicalHistory?.healthComment = self.txtVComment.text.trim()
        self.medicalHistory?.patientId = self.account?.id
        self.account?.userMedicalHistory = self.medicalHistory
        DispatchQueue.main.async {
            UILoader.startAnimating()
        }
        if pageType == .edit {
            self.presenter?.updateMedicalHistory(medicalHistory: self.medicalHistory)
        } else {
            self.presenter?.createProfile(account: self.account, image: self.userProfile, storage: self.storage)
        }
        
        
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if textView.text.count > 240 {
            return false
        } else {
            return true
        }
    }

    
    func updateUIBySuccess() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
            if self.pageType == .edit {
                self.navigationController?.popViewController(animated: true)
            } else {
                let storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
                let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: HomeViewController.self)) as! HomeViewController
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        }
    }
    
    func updateUIBy(medicalHistory: IUserMedicalHistory) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        self.btnBloodPressure.isSelected = medicalHistory.bloodPressure ?? false
        self.btnDiabetes.isSelected = medicalHistory.diabetes ?? false
        self.btnHypothyroidism.isSelected = medicalHistory.hypothyroidism ?? false
        self.btnLipidIssue.isSelected = medicalHistory.lipidsIssue ?? false
        self.btnKidneyProblem.isSelected = medicalHistory.kidneyProblem ?? false
        self.btnStroke.isSelected = medicalHistory.stroke ?? false
        self.btnHeartProblem.isSelected = medicalHistory.heartProblem ?? false
        self.txtVComment.text = medicalHistory.healthComment ?? ""
        self.lblCount.text = "\(self.txtVComment.text.count)/240"
        if medicalHistory.siblingHeartProblem ?? false {
            self.btnYesTapped(UIButton.init())
        } else {
            self.btnNoTapped(UIButton.init())
        }
    }

}
