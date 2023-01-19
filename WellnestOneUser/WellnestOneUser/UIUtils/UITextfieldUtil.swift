//
//  UITextfieldUtil.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 23/04/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import UIKit
import Foundation

protocol UITextfieldPickerDelegate {
    func didChange(value: String, index: Int, picker: UITextfieldPicker)
    func didEndEditing(value: String, index: Int, picker: UITextfieldPicker)
}


@IBDesignable
class UITextfieldPicker: UITextField, UIPickerViewDelegate, UIPickerViewDataSource, UITextFieldDelegate {
    var dataList: [String]? {
        didSet {
            updateUI()
            self.delegate = self
            self.pickerView.delegate = self
            self.pickerView.dataSource = self
            self.pickerView.selectRow(0, inComponent: 0, animated: false)
            self.text = self.dataList?[0]
        }
    }
    
    @IBInspectable var PlaceholderText: String? {
        didSet {
            updateUI()
        }
    }
    
    var isDoneButtonAvailable : Bool? {
        didSet {
            updateUI()
        }
    }
    
    var pickerDelegate: UITextfieldPickerDelegate?
    
    var pickerView = UIPickerView()
    
    override var text: String? {
        didSet {
            
        }
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        updateUI()
    }
    
    private func updateUI() {
        self.inputView = self.pickerView
        self.autocorrectionType = .no
        self.pickerView.selectRow(0, inComponent: 0, animated: false)
        self.tintColor = UIColor.clear
        self.layer.cornerRadius = 20.0
        self.clipsToBounds = true
        let imageView = UIImageView.init(image: UIImage.init(named: "ic_dropdown"))
        self.rightView = imageView
        self.rightViewMode = .always
        self.sizeToFit()
        
        let leftView2 = UIView.init(frame: CGRect.init(x: 5, y: 0, width: 140, height: 40))
        let labelMobile = UILabel.init(frame: CGRect.init(x: 5, y: 0, width: 140, height: 40))
        labelMobile.text = "   " + (self.PlaceholderText ?? "")
        labelMobile.font = UIFont.Roboto_Regular(fontSize: 12)
        labelMobile.textColor = UIColor.colorPrimaryLabel
        leftView2.addSubview(labelMobile)
        self.leftView = leftView2
        self.leftViewMode = .always

        let toolBar = UIToolbar.init()
        toolBar.barStyle = .default
        let selectButton = UIBarButtonItem.init(title: "Select", style: .done, target: self, action: #selector(selectMethod))
        toolBar.setItems([selectButton], animated: false)
    }
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return self.dataList!.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return self.dataList![row]
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        self.text = self.dataList![row]
        if self.pickerDelegate != nil {
            
            self.pickerDelegate?.didChange(value: self.dataList![row], index: row, picker: self)
        }
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.layer.borderColor = UIColor.colorFrom(hexString: "111111").cgColor
        self.layer.borderWidth = 1.0
        self.layoutIfNeeded()
    }
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        return false
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        textField.resignFirstResponder()
        print("textFieldShouldReturn")
        return true
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.layer.borderWidth = 0.0
        if let selectedText = self.dataList?[self.pickerView.selectedRow(inComponent: 0)] {
            if textField.text != selectedText {
                if self.pickerDelegate != nil && textField.hasText && self.dataList != nil {
                    self.pickerDelegate?.didEndEditing(value: selectedText, index: self.pickerView.selectedRow(inComponent: 0), picker: self)
                }
            } else {
                print("Same text")
            }
        }
        self.layoutIfNeeded()
    }
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        OperationQueue.main.addOperation {
            if self.isFirstResponder  {
                UIMenuController.shared.setMenuVisible(false, animated: false)
            }
        }
        return super.canPerformAction(action, withSender: sender)
    }
    
    
    @objc func selectMethod() {
        self.textFieldDidEndEditing(self)
        self.resignFirstResponder()
    }
}

@IBDesignable class UITextViewRoundCorner: UITextView {
    
    @IBInspectable var PlaceholderText: String? {
        didSet {
            UpdateUI()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        UpdateUI()
    }
    
    func UpdateUI() {
//        self.layer.borderWidth = 1
//        self.layer.borderColor = UIColor.colorButton.cgColor
        self.layer.cornerRadius = 20
        self.autocorrectionType = .no
        let leftView = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 110, height: 40))
        let labelMobile = UILabel.init(frame: CGRect.init(x: 5, y: 0, width: 110, height: 40))
        labelMobile.text = "   " + (self.PlaceholderText ?? "")
        labelMobile.textColor = UIColor.colorPrimaryLabel
        labelMobile.font = UIFont.Roboto_Regular(fontSize: 12)
        leftView.addSubview(labelMobile)
        self.addSubview(leftView)
        
        self.textContainerInset = UIEdgeInsets.init(top: 10, left: 135, bottom: 10, right: 10)
        self.layoutIfNeeded()
    }
    
}

import UIKit

@IBDesignable class UITextFieldOTP: UITextField {
    
    private var underLineView = UIView()
    @IBInspectable var underLineHeight : CGFloat = 1.0 {
        didSet {
            UpdateUI()
        }
    }
    @IBInspectable var underLineColor: UIColor = .clear {
        didSet {
            UpdateUI()
        }
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.underLineView = UIView()
        self.addSubview(self.underLineView)
        UpdateUI()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        UpdateUI()
    }
    
    private func UpdateUI() {
        self.borderStyle = .none
        self.autocorrectionType = .no
//        self.backgroundColor = UIColor.colorBackground
        self.layer.cornerRadius = 5.0
        self.textAlignment = .center
        self.keyboardType = UIKeyboardType.numberPad
        self.tintColor = .black
        if #available(iOS 12.0, *) {
            self.textContentType = UITextContentType.oneTimeCode
        }
        
        self.underLineView.frame = CGRect(x: 0, y: self.frame.height - self.underLineHeight, width: self.frame.width, height: self.underLineHeight)
        self.underLineView.backgroundColor = self.underLineColor
        if self.underLineView.superview == nil {
            self.addSubview(self.underLineView)
        }
        
        if self.textColor != UIColor.colorFrom(hexString: "#222C4A") {
            self.textColor = UIColor.colorFrom(hexString: "#222C4A")
//            self.tintColor = self.textColor
        }
        if self.font != UIFont.Roboto_Bold(fontSize: 24) {
            self.font = UIFont.Roboto_Bold(fontSize: 24)
        }
    }
    override func deleteBackward() {
        super.deleteBackward()
       _ = self.delegate?.textField?(self, shouldChangeCharactersIn: NSRange(location: 0, length: 0), replacementString: "")
    }
    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        UpdateUI()
    }
}

