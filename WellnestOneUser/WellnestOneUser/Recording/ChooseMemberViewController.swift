//
//  ChooseMemberViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 25/11/22.
//

import UIKit
import SDWebImage
import SwinjectStoryboard
class ChooseMemberViewController: UIParentViewController {

    var patient: IPatient?
    var recording: IRecordings?
    var account: IAccount?
    var storage: IStorage?
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var viewAddMember: UIView!
    @IBOutlet weak var viewDarkBkg: UIView!
    
    @IBOutlet weak var txtName: UITextField!
    @IBOutlet weak var txtAge: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var btnSave: UIButton!
    
    var selectedGender = "Male"
    var presenter: ChooseMemberPresenter?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.presenter = ChooseMemberPresenter(viewController: self)
        self.viewAddMember.isHidden = true
        self.viewDarkBkg.isHidden = true
        self.viewAddMember.layer.cornerRadius = 10
        self.imgProfile.layer.cornerRadius = self.imgProfile.frame.height / 2
        self.setupAddMemberView()
        if let account = UserDefaults.account {
            self.account = account
            self.lblName.text = account.fullName
            if let url = URL.init(string: AzureUtil.shared.getProfileImageURL(id: account.profileId ?? "", sasToken: SASTokenPublicRead)) {
                self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "ic_user"), completed: nil)
            }
        } else {
            UILoader.startAnimating()
            self.presenter?.getAccount(account: self.account)
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = ChooseMemberPresenter(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        self.selectedGender = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Male"
    }
    @IBAction func btnSaveTapped(_ sender: UIButton) {
        if self.txtName.text?.trim().isValidName() == false {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid First Name", viewController: self) { (_) in }
            return
        }
        if let arrayNames = self.txtName.text?.split(separator: " "), arrayNames.isEmpty != true {
            self.patient?.patientFirstName = String(arrayNames[0])
            if arrayNames.count > 1 {
                let lastNameString = arrayNames[1...].joined(separator: " ")
                self.patient?.patientLastName = lastNameString
            }
        }
        let age = Int(self.txtAge.text ?? "")
        let birthDate = Calendar.current.date(byAdding: .year, value: (0 - (age ?? 0) - 1), to: Date())

        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        let dateString = formatter.string(from: birthDate!)
        self.patient?.patientDateOfBirth = dateString
        
        self.patient?.patientGender = self.selectedGender
        self.patient?.phoneNumber = self.txtPhoneNo.text
        self.presenter?.linkFamilyMember(patient: self.patient, recordingId: self.recording?.id ?? 0)
    }
    @IBAction func btncloseAddmemberView(_ sender: UIView) {
        self.viewAddMember.isHidden = true
        self.viewDarkBkg.isHidden = true
    }
    @IBAction func btnLinkReportTapped(_ sender: UIButton) {
        self.patient?.patientFirstName = self.account?.firstName
        self.patient?.patientLastName = self.account?.lastName
        self.patient?.patientDateOfBirth = self.account?.dateOfBirth
        self.patient?.patientGender = self.account?.gender
        self.patient?.phoneNumber = self.account?.phoneNumber
        UILoader.startAnimating()
        self.presenter?.linkFamilyMember(patient: self.patient, recordingId: self.recording?.id ?? 0)
        
    }
    @IBAction func btnAddMemberTapped(_ sender: UIButton) {
        self.viewDarkBkg.isHidden = false
        self.viewAddMember.isHidden = false
    }
    @IBAction func btnCancelTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    func updateUIByLinkMemberSuccess() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        let storyB = SwinjectStoryboard.create(name: "Recording", bundle: nil, container: self.initialize.container)
        let vc = storyB.instantiateViewController(withIdentifier: String(describing: RecordingPreviewViewController.self)) as! RecordingPreviewViewController
        vc.recording = self.recording
        vc.pageType = .recordingCompleted
        vc.patient = self.patient
        self.navigationController?.pushViewController(vc, animated: true)
    }
    func setupAddMemberView() {
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        self.txtAge.delegate = self
        self.txtPhoneNo.delegate = self
        self.txtName.delegate = self
    }
    func updateUIby(account: Account) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        self.account = account
        self.lblName.text = account.fullName
        if let url = URL.init(string: AzureUtil.shared.getProfileImageURL(id: account.profileId ?? "", sasToken: SASTokenPublicRead)) {
            self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "ic_user"), completed: nil)
        }
    }
}
extension ChooseMemberViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (txtName.text != nil && txtName.text!.trim().count > 0) && (txtAge.text != nil && txtAge.text!.trim().count > 0) {
            self.btnSave.backgroundColor = UIColor.colorGreen
            self.btnSave.isUserInteractionEnabled = true
        } else {
            self.btnSave.backgroundColor = UIColor.colorButton
            self.btnSave.isUserInteractionEnabled = false
        }
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtPhoneNo || textField == txtAge {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let fullString = text.replacingCharacters(in: textRange, with: string)
                let allowedChars = CharacterSet(charactersIn: "0123456789").inverted
                if fullString.rangeOfCharacter(from: allowedChars) == nil {
                    let maxLength = textField == self.txtPhoneNo ? 13 : 3
                    if fullString.numbersOnly().isLessThan(maxLength: maxLength) {
                        textField.text = fullString
                    }
                }
                return false
            }
        }
        return true
    }
}
