//
//  ProfileSettingViewController.swift
//  WellnestOneUser
//
//  Created by Nihar Jagad on 17/11/22.
//

import UIKit
import SDWebImage
import SwinjectStoryboard
import FirebaseMessaging
class ProfileSettingViewController: UIParentViewController {
    
    var account: IAccount?
    var storage: IStorage?
    
    @IBOutlet weak var imgProfile: UIImageView!
    @IBOutlet weak var lblName: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var lblAgeGender: UILabel!
    @IBOutlet weak var lblHeight: UILabel!
    @IBOutlet weak var lblHeightUnit: UILabel!
    @IBOutlet weak var lblWeight: UILabel!
    @IBOutlet weak var lblWeightUnit: UILabel!
    @IBOutlet weak var lblBMI: UILabel!
    @IBOutlet weak var lblSmoking: UILabel!
    @IBOutlet weak var lblTobacco: UILabel!
    @IBOutlet weak var lblExercise: UILabel!
    @IBOutlet weak var lblAppVersion: UILabel!
    
    var presenter: ProfileSettingPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.imgProfile.layer.cornerRadius = self.imgProfile.layer.frame.height / 2
        DispatchQueue.main.async {
            UILoader.startAnimating()
        }
        self.presenter = ProfileSettingPresenter(viewController: self)
        self.presenter?.getAccount(account: self.account)
        displayAppVersion()
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = ProfileSettingPresenter(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    func displayAppVersion(){
        lblAppVersion.text = CommonConfiguration.Wellnest_AppVersion + AppConfiguration.versionName
    }
    func updateUIby(account: Account) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        self.account = account
        if let url = URL.init(string: AzureUtil.shared.getProfileImageURL(id: account.profileId ?? "", sasToken: SASTokenPublicRead)) {
            self.imgProfile.sd_setImage(with: url, placeholderImage: UIImage.init(named: "ic_user"),options: .fromLoaderOnly, completed: nil)
        }
        self.lblName.text = account.fullName
        self.lblPhoneNumber.text = "+\(account.countryCode ?? 91) " + "\(account.phoneNumber ?? "")"
        
        
        if account.dateOfBirth?.contains("Z") == false {
            account.dateOfBirth?.append("Z")
        }
        let formatter = DateFormatter.init()
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:sssZ"
        let date = formatter.date(from: account.dateOfBirth ?? "")
        let ageComponents = Calendar.current.dateComponents([.year], from: date ?? Date(), to: Date())
        let age = ageComponents.year
        self.lblAgeGender.text = "\(age ?? 0) Years | \(account.gender ?? "")"
        
        self.lblBMI.text = "\(account.bmi ?? 0.0)"
        self.lblSmoking.text = account.smoking?.capitalizingFirstLetter()
        self.lblTobacco.text = account.tobaccoUse?.capitalizingFirstLetter()
        self.lblExercise.text = account.exerciseLevel?.capitalizingFirstLetter()
        
        if account.heightUnit == "Ft" {
            let cmsValue = Int.init(account.height ?? 0.0)
            let (feet, inches) = self.convertCmsToFeet(cms: cmsValue)
            self.lblHeight.text = "\(feet)ft \(inches)in"
            self.lblHeightUnit.text = ""
        } else {
            let cmsValue = Int.init(account.height ?? 0.0)
            self.lblHeight.text = "\(cmsValue)"
            self.lblHeightUnit.text = "Cm"
        }
        
        if account.weightUnit == "Kg" {
            let gramValue = Int.init(account.weight ?? 0.0)
            let (kgSelected, gramSelected) = convertGmsToKg(gms: gramValue)
            self.lblWeight.text = "\(kgSelected).\(gramSelected)"
            self.lblWeightUnit.text = "Kg"
        } else {
            let gramValue = Int.init(account.weight ?? 0.0)
            let lbsSelected = convertGmsToLbs(grams: gramValue)
            self.lblWeight.text = "\(lbsSelected)"
            self.lblWeightUnit.text = "Lbs"
        }

    }
    @IBAction func btnEditProfileTapped(_ sender: UIButton) {
        let storyboard = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: CreateProfileViewController.self)) as! CreateProfileViewController
        vc.account = self.account
        vc.pageType = .edit
        vc.callBack = { isUpdated in
            if isUpdated {
                let presenter = ProfileSettingPresenter(viewController: self)
                presenter.getAccount(account: self.account)
            }
        }
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnEditMedicalHistoryTapped(_ sender: UIButton) {
        let storyB = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: MedicalHistoryViewController.self)) as! MedicalHistoryViewController
        vc.pageType = .edit
        vc.account = self.account
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func btnLogoutTapped(_ sender: UIButton) {
        UIAlertUtil.alertWith(title: "Logout", message: "Are you sure you want to logout?", OkTitle: "Logout", cancelTitle: "Cancel", viewController: self) { (index) in
            if index == 1 {
                UILoader.startAnimating()
                self.account?.fcmToken = Messaging.messaging().fcmToken
                self.presenter?.logout(account: self.account)
            }
        }
    }
    @IBAction func btnDeleteAccountTapped(_ sender: UIButton) {
                UIAlertUtil.alertWith(title: "Delete Account", message: "Are you sure you want to delete the account. Deleting account will remove all the data attached to this account.", OkTitle: "Delete", cancelTitle: "Cancel", viewController: self) { result in
                    if result == 1 {
                        UILoader.startAnimating()
                        self.account?.fcmToken = Messaging.messaging().fcmToken
                        self.presenter?.deleteAccount(account: self.account)
                    }
                }
            }
    @IBAction func brnRecommendTapped(_ sender: UIButton) {
        let textToShare = "Hello, I recommend Wellnest 12L machine for quick, easy and accurate heart check-up. Get the device here " + AppConfiguration.wellnestShopUrl + " and download the app here " + AppConfiguration.wellnestAppUrl
        let attributedOriginalText = NSMutableAttributedString(string: textToShare)
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: AppConfiguration.wellnestShopUrl, range: NSRange(location: 20, length: 106))
        attributedOriginalText.addAttribute(NSAttributedString.Key.link, value: AppConfiguration.wellnestShopUrl, range: NSRange(location: 28, length: 141))
        
            let objectsToShare: [Any] = [textToShare]
            let activityVC = UIActivityViewController(activityItems: objectsToShare, applicationActivities: nil)
            activityVC.popoverPresentationController?.sourceView = sender
            self.present(activityVC, animated: true, completion: nil)
    }
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    func updateUIbyLogout() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        UIApplication.shared.applicationIconBadgeNumber = 0
        UserDefaults.standard.setBearerToken(token: nil)
        UserDefaults.standard.synchronize()
        let storyB = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
        let vc = storyB.instantiateViewController(withIdentifier: String.init(describing: SplashViewController.self)) as! SplashViewController
        self.navigationController?.setViewControllers([vc], animated: true)
    }
    
    func convertCmsToFeet(cms: Int) -> (Int,Int) {
        let INCH_IN_CM: Float = 2.54

        let numInches = Int(roundf(Float(cms) / INCH_IN_CM))
        let feet = numInches / 12
        let inches = numInches % 12
        return (feet,inches)
    }
    func convertGmsToKg(gms: Int) -> (Int, Int) {
        var gram = gms
        let kg = gram / 1000
        gram = gram - (kg * 1000)
        return (kg,gram)
    }
    func convertGmsToLbs(grams: Int) -> Int {
        let result = Double(grams) / 453.6
        let integerResult = Int.init(result)
        return integerResult
    }
}
