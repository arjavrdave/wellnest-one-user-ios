//
//  CreateProfileViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 10/11/22.
//

import UIKit
import SwinjectStoryboard
import SDWebImage
class CreateProfileViewController: UIParentViewController {
    
    var account: IAccount?
    var storage: IStorage?
    @IBOutlet weak var txtFirstName: UITextField!
    @IBOutlet weak var txtLastName: UITextField!
    @IBOutlet weak var txtPhoneNo: UITextField!
    @IBOutlet weak var txtEmail: UITextField!
    @IBOutlet weak var txtDateOfBirth: UITextField!
    @IBOutlet weak var txtHeight: UITextField!
    @IBOutlet weak var txtWeight: UITextField!
    @IBOutlet weak var segmentGender: UISegmentedControl!
    @IBOutlet weak var segmentWeight: UISegmentedControl!
    @IBOutlet weak var segmentHeight: UISegmentedControl!
    @IBOutlet weak var birthdatePicker: UIDatePicker!
    @IBOutlet weak var heightPicker: UIPickerView!
    @IBOutlet weak var weightPicker: UIPickerView!
    @IBOutlet weak var btnNext: UIButton!
    @IBOutlet weak var btnAddProfile: UIButton!
    @IBOutlet weak var btnEditProfile: UIButton!
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var segmentDegreeOfSmoking: UISegmentedControl!
    @IBOutlet weak var segmentDegreeOfTobacco: UISegmentedControl!
    @IBOutlet weak var segmentLevelOfExercise: UISegmentedControl!
    @IBOutlet weak var lblTitle: UILabel!
    private var dataHeightInFeet: [[String]] = [(1...12).map(String.init), ["Feet"], (0...11).map(String.init), ["Inches"]]
    private var dataHeightInCms: [[String]] = [(0...394).map(String.init), ["Cms"]]
    private var dataWeightInKgs: [[String]] = [(0...226).map(String.init), ["Kgs"], (0...9).map(String.init), ["Grams"]]
    private var dataWeightInLbs: [[String]] = [(0...499).map(String.init), ["Lbs"]]
    private var levelMeasurments = ["Never","Low", "Med", "High"]
    private var isDateSelected: Bool = false
    private var heightUnitSelected: HeightUnits = .Ft
    private var weightUnitSelected: WeightUnits = .Kg
    private var selectedHeightInCms: Int = 167
    private var selectedWeightInLbs: Int = 132
    private var selectedGender: String = "Male"
    private var selectedDob = Date()
    
    var callBack: ((Bool) -> Void)?
    var pageType: CreateEditPageType = .create
    var presenter: CreateProfilePresenter?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.txtFirstName.delegate = self
        self.txtLastName.delegate = self
        self.txtEmail.delegate = self
        self.txtPhoneNo.delegate = self
        self.txtEmail.delegate = self
        self.txtDateOfBirth.delegate = self
        self.txtWeight.delegate = self
        self.txtHeight.delegate = self
        self.txtPhoneNo.isUserInteractionEnabled = false
        
        self.btnNext.isUserInteractionEnabled = false
        self.heightPicker.delegate = self
        self.heightPicker.dataSource = self
        
        self.weightPicker.delegate = self
        self.weightPicker.dataSource = self
        
        self.imgProfile.layer.cornerRadius = self.imgProfile.layer.frame.height / 2
        self.btnEditProfile.layer.cornerRadius = self.btnEditProfile.layer.frame.height / 2
        segmentHeight.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentHeight.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
    
        segmentWeight.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentWeight.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentGender.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        segmentDegreeOfSmoking.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentDegreeOfSmoking.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        segmentDegreeOfTobacco.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentDegreeOfTobacco.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        segmentLevelOfExercise.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentLevelOfExercise.setTitleTextAttributes([.foregroundColor: UIColor.black], for: .normal)
        
        birthdatePicker.minimumDate = Calendar.current.date(byAdding: .year, value: -200, to: Date())
        birthdatePicker.maximumDate = Date.init()
        
        self.txtDateOfBirth.inputView = UIView()
        self.txtDateOfBirth.inputAccessoryView = UIView()
        
        self.txtHeight.inputView = UIView()
        self.txtHeight.inputAccessoryView = UIView()
        
        self.txtWeight.inputView = UIView()
        self.txtWeight.inputAccessoryView = UIView()
        
        if pageType == .edit {
            self.isDateSelected = true
            self.btnNext.isUserInteractionEnabled = true
            self.btnNext.backgroundColor = UIColor.colorGreen
            self.btnNext.setTitle("Save", for: .normal)
            
            if let url = URL.init(string: AzureUtil.shared.getProfileImageURL(id: account?.profileId ?? "", sasToken: SASTokenPublicRead)) {
                self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "ic_user"), options: .fromCacheOnly, completed: nil)
            }
            
            self.txtFirstName.text = self.account?.firstName
            self.txtLastName.text = self.account?.lastName
            
            if self.account?.dateOfBirth?.contains("Z") == false {
                self.account?.dateOfBirth?.append("Z")
            }
            let formatter = DateFormatter.init()
            formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sssZ"
            let date = formatter.date(from: self.account?.dateOfBirth ?? "")
            let dateFormatter = DateFormatter.init()
            dateFormatter.dateFormat = "d MMM yyyy"
            self.txtDateOfBirth.text = dateFormatter.string(from: date ?? Date.init())
            self.selectedDob = date ?? Date.init()
            self.birthdatePicker.date = date ?? Date.init()
            self.txtEmail.text = self.account?.email
            
            if self.account?.gender?.capitalizingFirstLetter() == "Male" {
                self.segmentGender.selectedSegmentIndex = 0
            } else if self.account?.gender?.capitalizingFirstLetter() == "Female" {
                self.segmentGender.selectedSegmentIndex = 1
            } else if self.account?.gender?.capitalizingFirstLetter() == "Other" {
                self.segmentGender.selectedSegmentIndex = 2
            }
            
            self.segmentHeight.selectedSegmentIndex = self.account?.heightUnit == "Ft" ? 0 : 1
            self.segmentWeight.selectedSegmentIndex = self.account?.weightUnit == "Kg" ? 0 : 1
            self.heightUnitSelected = self.account?.heightUnit == "Ft" ? .Ft : .Cm
            self.weightUnitSelected = self.account?.weightUnit == "Kg" ? .Kg : .Lbs
            
            self.selectedHeightInCms = Int(self.account?.height ?? 0.0)
            self.selectedWeightInLbs = self.convertGmsToLbs(grams: Int(self.account?.weight ?? 0.0))
            
            self.segmentDegreeOfSmoking.selectedSegmentIndex = self.levelMeasurments.firstIndex(of: self.account?.smoking?.capitalizingFirstLetter() ?? "") ?? 0
            self.segmentDegreeOfTobacco.selectedSegmentIndex = self.levelMeasurments.firstIndex(of: self.account?.tobaccoUse?.capitalizingFirstLetter() ?? "") ?? 0
            self.segmentLevelOfExercise.selectedSegmentIndex = self.levelMeasurments.firstIndex(of: self.account?.exerciseLevel?.capitalizingFirstLetter() ?? "") ?? 0
            
            self.btnAddProfile.isHidden = true
            self.btnEditProfile.isHidden = false
            
            self.lblTitle.text = "Edit Profile"
        } else {
            self.btnNext.isUserInteractionEnabled = false
            
            self.btnAddProfile.isHidden = false
            self.btnEditProfile.isHidden = true
            
            self.lblTitle.text = "Create Profile"
        }
        self.setWeightInPicker()
        self.setHeightInPicker()
        self.txtPhoneNo.text = self.account?.phoneNumber
        self.txtPhoneNo.textColor = UIColor.colorDisable
        
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = CreateProfilePresenter(viewController: self)
        
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    @IBAction func weightUnitChanged(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
            self.weightUnitSelected = sender.selectedSegmentIndex == 0 ? .Kg : .Lbs
            self.weightPicker.reloadAllComponents()
            self.setWeightInPicker()
        }
    }
    
    @IBAction func heightUnitChanged(_ sender: UISegmentedControl) {
        DispatchQueue.main.async {
            self.heightUnitSelected = sender.selectedSegmentIndex == 0 ? .Ft : .Cm
            self.heightPicker.reloadAllComponents()
            self.setHeightInPicker()
        }
    }
    @IBAction func genderChanged(_ sender: UISegmentedControl) {
        self.selectedGender = sender.titleForSegment(at: sender.selectedSegmentIndex) ?? "Male"
    }
    @IBAction func dateValueChanged(_ sender: UIDatePicker) {
        self.isDateSelected = true
        if (txtFirstName.text != nil && txtFirstName.text!.trim().count > 0) && (txtLastName.text != nil && txtLastName.text!.trim().count > 0) {
            self.btnNext.backgroundColor = UIColor.colorGreen
            self.btnNext.isUserInteractionEnabled = true
        } else {
            self.btnNext.backgroundColor = UIColor.colorButton
            self.btnNext.isUserInteractionEnabled = false
        }
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d MMM yyyy"
        self.selectedDob = sender.date
        self.txtDateOfBirth.text = dateFormatter.string(from: sender.date)
    }
    private func setWeightInPicker() {
        if self.weightUnitSelected == .Kg {
            let (kg, grams) = self.convertLbsToKg(lbs: self.selectedWeightInLbs)
            let indexForGram = grams / 100
            self.weightPicker.selectRow(kg, inComponent: 0, animated: false)
            self.weightPicker.selectRow(indexForGram, inComponent: 2, animated: false)
            self.txtWeight.text = "\(kg).\(indexForGram)"
        } else {
            self.weightPicker.selectRow(self.selectedWeightInLbs, inComponent: 0, animated: false)
            self.txtWeight.text = "\(self.selectedWeightInLbs)"
        }
    }
    @IBAction func btnProfilePhotoTapped(_ sender: UIButton) {
        //self.isPictureSelectionGoingOn = true
        UIAlertUtil.alertWithImagePicker(title: "Account's profile photo", message: "Select photo from", viewController: self) { (_) in }
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        if pageType == .edit {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.popToRootViewController(animated: true)
        }
    }
    
    @IBAction func btnNextOrSaveTapped(_ sender: UIButton) {
        if self.txtFirstName.text?.trim().isValidName() == false {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid First Name", viewController: self) { (_) in }
            return
        }
        if self.txtLastName.text?.trim().isValidName() == false {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid Last Name", viewController: self) { (_) in }
            return
        }
        if (self.txtEmail?.text?.trim() != "") && !(self.txtEmail?.text?.trim().isValidEmail() ?? false) {
            UIAlertUtil.alertWith(title: "Alert", message: "Please enter valid email", viewController: self) { (_) in }
            return
        }
        
        self.account?.firstName = self.txtFirstName.text
        self.account?.lastName = self.txtLastName.text
        
        let format = ISO8601DateFormatter.init()
        let dateString = format.string(from: self.selectedDob)
        self.account?.dateOfBirth = dateString
        
        self.account?.email = self.txtEmail.text
        self.account?.gender = self.segmentGender.titleForSegment(at: self.segmentGender.selectedSegmentIndex) ?? "Male"
        self.account?.height = Double(self.selectedHeightInCms)
        self.account?.heightUnit = self.segmentHeight.titleForSegment(at: self.segmentHeight.selectedSegmentIndex) ?? "Cm"
        
        let (kg , grams) = self.convertLbsToKg(lbs: self.selectedWeightInLbs)
        self.account?.weight = Double(kg * 1000 + grams)
        self.account?.weightUnit = self.segmentWeight.titleForSegment(at: self.segmentWeight.selectedSegmentIndex) ?? "Lbs"
        self.account?.smoking = self.segmentDegreeOfSmoking.titleForSegment(at: self.segmentDegreeOfSmoking.selectedSegmentIndex) ?? "Never"
        self.account?.tobaccoUse = self.segmentDegreeOfTobacco.titleForSegment(at: self.segmentDegreeOfTobacco.selectedSegmentIndex) ?? "Never"
        self.account?.exerciseLevel = self.segmentLevelOfExercise.titleForSegment(at: self.segmentLevelOfExercise.selectedSegmentIndex) ?? "Never"
        if pageType == .edit {
            DispatchQueue.main.async {
                UILoader.startAnimating()
            }
            self.presenter?.createProfile(account: self.account, image: self.imgProfile.image, storage: self.storage)
        } else {
            self.account?.profileId = UUID().uuidString
            let storyB = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: MedicalHistoryViewController.self)) as! MedicalHistoryViewController
            vc.account = account
            vc.userProfile = self.imgProfile.image
            vc.pageType = .create
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        
    }
    func updateUIBySuccess() {
        if let callBack = self.callBack {
            callBack(true)
        }
        DispatchQueue.main.async {
            UILoader.stopAnimating()
            self.navigationController?.popViewController(animated: true)
        }
        
    }
    private func setHeightInPicker() {
        if self.heightUnitSelected == .Ft {
            let (feet, inches) = self.convertCmsToFeet(cms: self.selectedHeightInCms)
            self.heightPicker.selectRow(feet - 1, inComponent: 0, animated: false)
            self.heightPicker.selectRow(inches, inComponent: 2, animated: false)
            self.txtHeight.text = "\(feet)'\(inches)\""
        } else {
            self.heightPicker.selectRow(self.selectedHeightInCms, inComponent: 0, animated: false)
            self.txtHeight.text = "\(self.selectedHeightInCms)"
        }
    }
    private func setLevel(in segment: UISegmentedControl, value: String) {
        segment.selectedSegmentIndex = self.levelMeasurments.firstIndex(of: value) ?? 0
    }
}
extension CreateProfileViewController: UITextFieldDelegate {
    func textFieldDidChangeSelection(_ textField: UITextField) {
        if (txtFirstName.text != nil && txtFirstName.text!.trim().count > 0) && (txtLastName.text != nil && txtLastName.text!.trim().count > 0) && isDateSelected {
            self.btnNext.backgroundColor = UIColor.colorGreen
            self.btnNext.isUserInteractionEnabled = true
        } else {
            self.btnNext.backgroundColor = UIColor.colorButton
            self.btnNext.isUserInteractionEnabled = false
        }
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtPhoneNo {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let fullString = text.replacingCharacters(in: textRange, with: string)
                let allowedChars = CharacterSet(charactersIn: "0123456789").inverted
                if fullString.rangeOfCharacter(from: allowedChars) == nil {
                    if fullString.numbersOnly().isLessThan(maxLength: 13) {
                        textField.text = fullString
                    }
                }
                return false
            }
        } else if textField == self.txtDateOfBirth || textField == self.txtWeight || textField == self.txtHeight {
            return false
        }
        return true
    }
    func textFieldDidBeginEditing(_ textField: UITextField) {
        if textField == txtDateOfBirth {
            self.birthdatePicker.isHidden = false
            self.weightPicker.isHidden = true
            self.heightPicker.isHidden = true
        }
        else if textField == txtHeight {
            self.birthdatePicker.isHidden = true
            self.weightPicker.isHidden = true
            self.heightPicker.isHidden = false
        } else if textField == txtWeight {
            self.birthdatePicker.isHidden = true
            self.weightPicker.isHidden = false
            self.heightPicker.isHidden = true
        } else {
            self.birthdatePicker.isHidden = true
            self.weightPicker.isHidden = true
            self.heightPicker.isHidden = true
        }
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.birthdatePicker.isHidden = true
        self.weightPicker.isHidden = true
        self.heightPicker.isHidden = true
    }
}
extension CreateProfileViewController: UIPickerViewDelegate, UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        if pickerView == self.heightPicker {
            return heightUnitSelected == .Ft ? dataHeightInFeet.count : dataHeightInCms.count
        } else {
            return weightUnitSelected == .Kg ? dataWeightInKgs.count : dataWeightInLbs.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView == self.heightPicker {
            return heightUnitSelected == .Ft ? dataHeightInFeet[component].count : dataHeightInCms[component].count
        } else {
            return weightUnitSelected == .Kg ? dataWeightInKgs[component].count : dataWeightInLbs[component].count
        }
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView == self.heightPicker {
            return heightUnitSelected == .Ft ? dataHeightInFeet[component][row] : dataHeightInCms[component][row]
        } else {
            return weightUnitSelected == .Kg ? (component == 2 ? ".\(dataWeightInKgs[component][row])00" : dataWeightInKgs[component][row]) : dataWeightInLbs[component][row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView == self.heightPicker {
            if heightUnitSelected == .Ft {
                let feet = dataHeightInFeet[0][pickerView.selectedRow(inComponent: 0)]
                let inches = dataHeightInFeet[2][pickerView.selectedRow(inComponent: 2)]
                self.txtHeight.text = "\(feet)'\(inches)\""
                self.selectedHeightInCms = self.convertFeetToCms(feet: Int(feet) ?? 0, inches: Int(inches) ?? 0)
            } else {
                let cms = dataHeightInCms[0][pickerView.selectedRow(inComponent: 0)]
                self.txtHeight.text = "\(cms)"
                self.selectedHeightInCms = Int(cms) ?? 0
            }
        } else {
            if weightUnitSelected == .Kg {
                let kg = Int(dataWeightInKgs[0][pickerView.selectedRow(inComponent: 0)]) ?? 0
                let grams = (Int(dataWeightInKgs[2][pickerView.selectedRow(inComponent: 2)]) ?? 0)
                self.txtWeight.text = "\(kg).\(grams)"
                self.selectedWeightInLbs = self.convertKgToLbs(kg: kg, gram: grams*100)
            } else {
                let lbs = Int(dataWeightInLbs[0][pickerView.selectedRow(inComponent: 0)]) ?? 0
                self.txtWeight.text = "\(lbs)"
                self.selectedWeightInLbs = lbs
            }
        }
    }
    func convertGmsToKg(gms: Int) -> (Int, Int) {
        var gram = gms
        let kg = gram / 1000
        gram = gram - (kg * 1000)
        return (kg,gram)
    }

    func convertFeetToCms(feet: Int, inches: Int) -> Int {
        let data1 = Double(feet) * 30.48
        let data2 = Double(inches) * 2.54
        let result = data1 + data2
        let integerResult = Int.init(result)
        return integerResult
    }
    
    func convertCmsToFeet(cms: Int) -> (Int,Int) {
        let INCH_IN_CM: Float = 2.54

        let numInches = Int(roundf(Float(cms) / INCH_IN_CM))
        let feet = numInches / 12
        let inches = numInches % 12
        return (feet,inches)
    }
    
    func convertKgToLbs(kg: Int, gram: Int) -> Int {
        let data1 = Double(kg) * 2.205
        let data2 = Double(gram) / 453.6
        let result = data1 + data2
        let integerResult = Int.init(result)
        return integerResult
    }
    
    func convertLbsToKg(lbs: Int) -> (Int,Int) {
        var gram = Double(lbs) * 453.6
        let kg = gram / 1000
        gram = gram - Double((Int(kg) * 1000))
        
        return (Int(kg),Int(gram))
    }
    
    func convertGmsToLbs(grams: Int) -> Int {
        let result = Double(grams) / 453.6
        let integerResult = Int.init(result)
        return integerResult
    }
}
extension CreateProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) {
            let image = info[UIImagePickerController.InfoKey.originalImage] as! UIImage
            //let resizedImage = image.sd_resizedImage(with: CGSize(width: 400, height: 400 * image.size.height / image.size.width), scaleMode: .aspectFit)
            //self.recording?.patientImage = resizedImage?.jpegData(compressionQuality: 0.5)
            
            //self.selectedImage = image
            
            self.imgProfile.image = image
            self.imgProfile.contentMode = .scaleAspectFill
            self.btnAddProfile.isHidden = true
            //self.isPictureSelectionGoingOn = false
        }
    }
}
