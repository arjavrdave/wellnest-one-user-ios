//
//  LoginViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 03/06/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import QuickLook
class LoginViewController: UIParentViewController, UITextFieldDelegate, ProtoCountryCode {
    
    var account : IAccount?

    @IBOutlet weak var txtFPhoneNum: UITextField!
    @IBOutlet weak var lblErrorMessage: UILabel!
    @IBOutlet weak var btnForward: UIButton!
    @IBOutlet weak var btnTermsCnd: UIButton!
    @IBOutlet weak var constBottomspace: NSLayoutConstraint!
    @IBOutlet weak var btnCountryCode: UIButton!
    @IBOutlet weak var imageViewCountry: UIImageView!
    var selectedCountryCode = 91
    var selectedCountryName = "India"
    var selectedCountryIdentifier = "IN"
    private var presenter: LoginPresenter?
    lazy var previewItem = NSURL()
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnForward.layer.cornerRadius = self.btnForward.frame.height / 2
        self.txtFPhoneNum.delegate = self
        self.txtFPhoneNum.keyboardType = .numberPad
        self.btnForward.isUserInteractionEnabled = false
        self.imageViewCountry.layer.cornerRadius = 15
        self.imageViewCountry.sd_setImage(with: URL.init(string: "https://flagcdn.com/h80/in.png"), completed: nil)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        self.constButtonBottom = self.constBottomspace
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.txtFPhoneNum.becomeFirstResponder()
        self.presenter = LoginPresenter.init(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if textField == self.txtFPhoneNum {
            if let text = textField.text, let textRange = Range(range, in: text) {
                let fullString = text.replacingCharacters(in: textRange, with: string)
                if textField.isEqual(self.txtFPhoneNum) {
                    let allowedChars = CharacterSet(charactersIn: "0123456789").inverted
                    if fullString.rangeOfCharacter(from: allowedChars) == nil {
                        if fullString.numbersOnly().isLessThan(maxLength: 13) {
                            textField.text = fullString
                        }
                        if fullString.numbersOnly().isGratterThan(minLength: 7) && fullString.numbersOnly().isLessThan(maxLength: 13) {
                            self.btnForward.backgroundColor = UIColor.colorGreen
                            self.btnForward.isUserInteractionEnabled = true
                        } else {
                            self.btnForward.backgroundColor = UIColor.colorButton
                            self.btnForward.isUserInteractionEnabled = false
                        }
                    }
                    return false
                }
            }
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        if textField.text?.numbersOnly().count ?? 0 >= 7 && textField.text?.numbersOnly().count ?? 0 <= 13  {
            self.account?.phoneNumber = textField.text?.trim().numbersOnly()
            self.btnForward.backgroundColor = UIColor.colorGreen
            self.btnForward.isUserInteractionEnabled = true
        } else {
            self.btnForward.backgroundColor = UIColor.colorButton
            self.btnForward.isUserInteractionEnabled = false
        }
    }
    
    @IBAction func btnForwardTapped(_ sender: UIButton) {
        self.txtFPhoneNum.resignFirstResponder()
        UILoader.startAnimating()
        self.presenter?.login(account: self.account)
        
    }
    @IBAction func btnTermsCond(_ sender: UIButton) {
        let previewController = QLPreviewController()
        
        self.previewItem = self.getPreviewItem(withName: "Wellnest_TOS.pdf")
        previewController.dataSource = self
        previewController.navigationItem.rightBarButtonItems = nil
        self.present(previewController,animated: true, completion: nil)
    }
    
    @IBAction func btnCloseTapped(_ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
    
    @IBAction func btnCountryCodeTapped(_ sender: UIButton) {
        let stryB = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
        let vc = stryB.instantiateViewController(withIdentifier: String.init(describing: CountryCodeViewController.self)) as! CountryCodeViewController
        vc.delegate = self
        vc.selectedCountryName = self.selectedCountryName
        vc.selectedCountryIdentifier = self.selectedCountryIdentifier
        self.present(vc, animated: true, completion: nil)
    }
    
    func countryCodeSelected(countryCode: String, code: String, countryName: String) {
        
        self.selectedCountryCode = countryCode.numbersOnly().int ?? 91
        self.selectedCountryName = countryName
        self.selectedCountryIdentifier = code
        self.account?.countryCode = self.selectedCountryCode
        self.btnCountryCode.setTitle(countryCode, for: .normal)
        self.imageViewCountry.sd_setImage(with: URL.init(string: "https://flagcdn.com/h80/\(code.lowercased()).png"))
        
    }
    func updateUIbyResponse(isSuccess: Bool) {
        UILoader.stopAnimating()
        if isSuccess {
            self.lblErrorMessage.text = ""
            let storyBoard = SwinjectStoryboard.create(name: "Login", bundle: Bundle.main, container: self.initialize.container)
            let vc = storyBoard.instantiateViewController(withIdentifier: String.init(describing: OTPViewController.self)) as! OTPViewController
            vc.account = self.account
            self.navigationController?.pushViewController(vc, animated: true)
        } else {
            self.btnForward.backgroundColor = UIColor.colorRed
            self.lblErrorMessage.textColor = UIColor.colorRed
            self.lblErrorMessage.text = "Phone is not associated with wellnest account."
            
        }
    }
    
    func getPreviewItem(withName name: String) -> NSURL {
        let file = name.components(separatedBy: ".")
        let path = Bundle.main.path(forResource: file.first!, ofType: file.last!)
        let url = NSURL(fileURLWithPath: path!)
        
        return url
    }
}
extension LoginViewController: QLPreviewControllerDataSource {
    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        return 1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        return self.previewItem as QLPreviewItem
    }
}
