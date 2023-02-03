//
//  GetInTouchViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 09/12/22.
//

import UIKit
import SwinjectStoryboard
class GetInTouchViewController: UIParentViewController {

    var patient: IPatient?
    
    @IBOutlet weak var txtFullName: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var txtFSubjectPicker: UITextfieldPicker!
    @IBOutlet weak var txtFNote: UITextViewRoundCorner!
    
    @IBOutlet weak var lblCountryCode: UILabel!
    
    @IBOutlet weak var sViewFullName: UIStackView!
    @IBOutlet weak var sViewEmail: UIStackView!
    @IBOutlet weak var sViewPhoneNo: UIStackView!
    
    var subjects = ["Want to purchase ECG 12L",
        "Just bought new 12L & want to register as a user",
        "I have been registered but there is a verification error",
        "Want to subscribe to Wellnest's newsletter",
        "Want to know more about Wellnest",
        "Other"]
    
    var selectedCountryCode = 91
    var selectedCountryName = "India"
    var selectedCountryIdentifier = "IN"
    var selectedSubjects = String()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.sViewFullName.layer.cornerRadius = self.sViewFullName.frame.height / 2
        self.sViewEmail.layer.cornerRadius = self.sViewEmail.frame.height / 2
        self.sViewPhoneNo.layer.cornerRadius = self.sViewPhoneNo.frame.height / 2
        self.txtFSubjectPicker.layer.cornerRadius = self.txtFSubjectPicker.frame.height / 2
        self.selectedSubjects = self.subjects[0]
        self.txtFullName.delegate = self
        self.txtEmail.delegate = self
        self.txtPhoneNo.delegate = self
        self.txtFNote.delegate = self
        self.txtFSubjectPicker.pickerDelegate = self
        self.txtFSubjectPicker.dataList = self.subjects
        self.txtPhoneNo.keyboardType = .numberPad
        self.txtEmail.keyboardType = .emailAddress
        
    }
    @IBAction func btnCountryTapped(_ sender: UIButton) {
        let stryB = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
        let vc = stryB.instantiateViewController(withIdentifier: String.init(describing: CountryCodeViewController.self)) as! CountryCodeViewController
        vc.delegate = self
        vc.selectedCountryName = self.selectedCountryName
        vc.selectedCountryIdentifier = self.selectedCountryIdentifier
        self.present(vc, animated: true, completion: nil)
    }
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func btnSubmit(_ sender: UIButton) {
        if self.txtFullName.text?.trim() == ""{
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter you fullname", viewController: self) { (_) in }
            return
        }
        if !(self.txtFullName.text?.trim().isValidName() ?? false) {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid fullname", viewController: self) { (_) in }
            return
        }
        
        if (self.txtEmail.text?.trim() != ""
        ) && !(self.txtEmail.text?.trim().isValidEmail() ?? false){
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid email", viewController: self) { (_) in }
            return
        }

        if self.txtPhoneNo.text?.trim().isValidPhone() == false {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid number", viewController: self) { (_) in }
            return
        }
        
//        if self.selectedSubjects == "" {
//            UIAlertUtil.alertWith(title: "Alert", message: "Please select your subject", viewController: self) { (_) in }
//            return
//        }
        if let arrayNames = self.txtFullName.text?.split(separator: " "), arrayNames.isEmpty != true {
            self.patient?.patientFirstName = String(arrayNames[0])
            if arrayNames.count > 1 {
                let lastNameString = arrayNames[1...].joined(separator: " ")
                self.patient?.patientLastName = lastNameString
            }
        }
        self.patient?.email = self.txtEmail.text?.trim()
        self.patient?.phoneNumber = self.txtPhoneNo.text?.trim()
        self.patient?.countryCode = self.selectedCountryCode
        self.patient?.subject = self.selectedSubjects
        self.patient?.notes = self.txtFNote.text?.trim()
        
        UILoader.startAnimating()
        let presenter = GetInTouchPresenter.init(viewController: self)
        presenter.getInTouch(account: self.patient)
    }
}
extension GetInTouchViewController: UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == self.txtPhoneNo {
            self.sViewPhoneNo.layer.borderWidth = 1.0
        } else if textField == self.txtFullName {
            self.sViewFullName.layer.borderWidth = 1.0
        } else if textField == self.txtEmail {
            self.sViewEmail.layer.borderWidth = 1.0
        }
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField == self.txtPhoneNo {
            self.sViewPhoneNo.layer.borderWidth = 0.0
        } else if textField == self.txtFullName {
            self.sViewFullName.layer.borderWidth = 0.0
        } else if textField == self.txtEmail {
            self.sViewEmail.layer.borderWidth = 0.0
        }
    }
    func UpdateUIBySuccess() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        let storyBoard = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyBoard.instantiateViewController(withIdentifier: String.init(describing: GettingTouchThanksViewController.self)) as! GettingTouchThanksViewController
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
extension GetInTouchViewController: UITextViewDelegate {
    func textViewDidBeginEditing(_ textView: UITextView) {
        self.txtFNote.layer.borderWidth = 1.0
        self.txtFNote.layer.borderColor = UIColor.colorFrom(hexString: "111111").cgColor
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        self.txtFNote.layer.borderWidth = 0.0
    }
}
extension GetInTouchViewController: UITextfieldPickerDelegate {
    func didChange(value: String, index: Int, picker: UITextfieldPicker) {
        if picker == self.txtFSubjectPicker {
            self.selectedSubjects = value
        }
    }
    
    func didEndEditing(value: String, index: Int, picker: UITextfieldPicker) {
        if picker == self.txtFSubjectPicker {
            self.selectedSubjects = value
        }
    }
}
extension GetInTouchViewController: ProtoCountryCode {
    func countryCodeSelected(countryCode: String, code: String, countryName: String) {
        self.selectedCountryCode = countryCode.numbersOnly().int ?? 91
        self.selectedCountryName = countryName
        self.selectedCountryIdentifier = code
        self.lblCountryCode.text = "+\(self.selectedCountryCode)"
    }
}
