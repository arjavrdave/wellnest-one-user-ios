//
//  OTPViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 05/05/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import SwinjectStoryboard
import Firebase
let RESEND_TIMER = 30
import Amplitude

enum OTPPageType {
    case login
    case signUp
    case editDoctor
}

class OTPViewController: UIParentViewController, UITextFieldDelegate {

    var account : IAccount?
    @IBOutlet weak var lblInvalidCode: UILabel!
    @IBOutlet weak var lblPhoneNumber: UILabel!
    @IBOutlet weak var viewOTP: UIViewShadow!
    @IBOutlet weak var btnResend: UIButton!
    @IBOutlet weak var lblResendTimer: UILabel!
    @IBOutlet weak var btnProceed: UIButtonProceedForward!
    @IBOutlet weak var constBottomspace: NSLayoutConstraint!
    
    private var charCounts: Int = 0
    private var otpMaxLength = Int(4)
    private var codeString = ""
    private var seconds: Int = 0
    private var presenter: OTPPresenter?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        self.viewOTP.subviews.forEach { (view) in
            if let textField = view as? UITextFieldOTP {
                textField.placeholder = ""
                textField.delegate = self
            }
        }
        
        self.btnResend.isHidden = true
        self.lblInvalidCode.isHidden = true
        self.lblPhoneNumber.text = "+\(self.account?.countryCode ?? 91) " + "\(self.account?.phoneNumber ?? "")"
        startTimer()
    }
    override func viewWillAppear(_ animated: Bool) {
        self.constButtonBottom = self.constBottomspace
    }
    override func viewDidAppear(_ animated: Bool) {
        self.presenter = OTPPresenter.init(viewController: self)
    }
    override func viewDidDisappear(_ animated: Bool) {
        self.presenter = nil
    }
    @IBAction func btnProceedTapped(_ sender: Any) {
        self.account?.code = self.codeString
        self.account?.fcmToken = UserDefaults.fcmToken
        UILoader.startAnimating()
        self.presenter?.verifyOTP(account: self.account)
    }
    
    @IBAction func btnBackTapped(_ sender: UIButton) {
        self.navigationController?.popToRootViewController(animated: true)
    }
    
    @IBAction func btnResendTapped(_ sender: UIButton) {
        UILoader.startAnimating()
        self.presenter?.resendOTP(account: self.account)
    }
    
    override func becomeFirstResponder() -> Bool {
        if let txtOtp = self.viewOTP.viewWithTag( (self.charCounts == self.otpMaxLength) ? self.otpMaxLength : self.charCounts + 1) {
            txtOtp.becomeFirstResponder()
        }
        return false
    }

    
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        let tagNumber = textField.tag
        let charCount = (self.charCounts == self.otpMaxLength) ? self.otpMaxLength : self.charCounts + 1
        if tagNumber == charCount {
            return true
        }
        return false
    }
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if let text = textField.text, let textRange = Range(range, in: text) {
            let stringNew = string.trim().numbersOnly() // Support only numbers
            
            let fullString = text.replacingCharacters(in: textRange, with: stringNew).numbersOnly().trim()
            
            if fullString.isEmpty { // DELETE text
                textField.text = fullString
                self.charCounts -= 1
                self.charCounts = (self.charCounts < 0) ? 0 : self.charCounts
                if textField.tag > 1 {
                    self.viewOTP.viewWithTag(textField.tag - 1)?.becomeFirstResponder()
                }
                
            } else { // ENTER NEW CHAR
                if stringNew.isEmpty == false {
                    textField.text = stringNew
                    self.charCounts += 1
                    self.charCounts = (self.charCounts > self.otpMaxLength) ? self.otpMaxLength : self.charCounts
                    
                    if textField.tag == self.otpMaxLength {
                        self.view.endEditing(true)
                        // Done Entering
                        
                    } else {
                        self.viewOTP.viewWithTag(textField.tag + 1)?.becomeFirstResponder()
                    }
                }
            }
        }
        return false
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.viewOTP.subviews.forEach { (view) in
            if let textField = view as? UITextFieldOTP {
                if textField.text?.isEmpty == false {
                    textField.layer.borderColor = UIColor.colorPrimaryLabel.cgColor
                    textField.layer.borderWidth = 0.7
                } else {
                    textField.layer.borderColor = UIColor.colorPrimaryLabel.cgColor
                    textField.layer.borderWidth = 0.0
                }
            }
        }

    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        var otp = ""
        self.viewOTP.subviews.forEach { (view) in
            if let textField = view as? UITextFieldOTP {
                if textField.text?.isEmpty == false {
                    textField.layer.borderColor = UIColor.colorPrimaryLabel.cgColor
                    textField.layer.borderWidth = 0.7
                    otp.append(textField.text!.trim())
                } else {
                    textField.layer.borderColor = UIColor.colorPrimaryLabel.cgColor
                    textField.layer.borderWidth = 0.0
                }
            }
        }
        
        print("OTP is : ", otp)
        if otp.count == 4 {
            
            self.codeString = otp
            self.btnProceed.status = .enable

        } else {
            self.btnProceed.status = .disable
        }
    }
    
    func startTimer() {
        _ = self.becomeFirstResponder()
        self.seconds = RESEND_TIMER
        self.btnResend.isHidden = true
        self.lblResendTimer.isHidden = false
        updateTimer()
    }
    
    func updateTimer() {
        if self.seconds == 0 {
            self.btnResend.isHidden = false
            self.lblResendTimer.isHidden = true
        } else {

            let timeInString = String(format: "%.2d:%.2d", self.seconds/60, self.seconds % 60)
            self.lblResendTimer.text = "Resend code in: " + timeInString + " sec"
            self.btnResend.isHidden = true
            self.seconds -= 1

            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
                self.updateTimer()
            }
        }
    }
    
    func updateUIbyError(error: Error?) {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }

        self.showError(error: error)
        self.lblInvalidCode.isHidden = false
        self.btnProceed.status = .error
        self.displayTextField(with: true)
       
    }

    func updateUIBySuccess() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        if let bearerToken = UserDefaults.bearerToken {
            if let id = bearerToken.id {
                self.account?.id = id
            }
            if bearerToken.isNewUser ?? true {
                let storyboard = SwinjectStoryboard.create(name: "Profile", bundle: Bundle.main, container: self.initialize.container)
                let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: CreateProfileViewController.self)) as! CreateProfileViewController
                vc.account?.phoneNumber = self.account?.phoneNumber
                vc.account?.countryCode = self.account?.countryCode
                vc.pageType = .create
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let storyboard = SwinjectStoryboard.create(name: "Landing", bundle: Bundle.main, container: self.initialize.container)
                let vc = storyboard.instantiateViewController(withIdentifier: String.init(describing: HomeViewController.self)) as! HomeViewController
                self.navigationController?.setViewControllers([vc], animated: true)
            }
        } else {
            UIAlertUtil.alertWith(title: "Error", message: "Unable to Login Please Try Again.", OkTitle: "ok", viewController: self) { result in
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
    }

    func updateUIbyOTPResent() {
        DispatchQueue.main.async {
            UILoader.stopAnimating()
        }
        self.btnResend.isHidden = true
        self.lblInvalidCode.isHidden = true
        self.displayTextField(with: false)
        UIAlertUtil.alertWith(title: "Success", message: "OTP has been sent to your phone number.", viewController: self) { (_) in
            self.startTimer()
        }
    }
    func displayTextField(with error: Bool) {
        if error {
            self.viewOTP.subviews.forEach { textField in
                textField.layer.borderColor = UIColor.colorRed.cgColor
                textField.layer.borderWidth = 1.0
            }
        } else {
            self.viewOTP.subviews.forEach { textField in
                textField.layer.borderWidth = 0.0
            }
        }
    }
    
}
