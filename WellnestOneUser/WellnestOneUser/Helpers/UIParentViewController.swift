//
//  UIParentViewController.swift
//  Wellnest Technician
//
//  Created by Mayank Verma on 07/07/20.
//  Copyright © 2020 Wellnest Inc. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import SwinjectStoryboard
class UIParentViewController: UIViewController, UIGestureRecognizerDelegate {
    
    let initialize: Initializers = Initializers.shared
    var constantBottomSpace : CGFloat? = 20
    public var constButtonBottom: NSLayoutConstraint? {
        didSet {
            SetKeyboardObserver()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if self.navigationController != nil {
            if self.navigationController!.viewControllers.count > 1 {
                self.navigationController?.interactivePopGestureRecognizer?.delegate = self
            }
        }
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.constantBottomSpace = self.constButtonBottom?.constant
        SetKeyboardObserver()
    }
    
    func showError(error : Error?) {
        if error?.localizedDescription == " This account is not present please login again " {
            DispatchQueue.main.async {
                UILoader.stopAnimating()
                UIAlertUtil.show(error: error, viewController: self) { (index) in
                    if index == 1{
                        //TODO: Logout functionality
                    }
                }
            }
        } else {
            DispatchQueue.main.async {
                UILoader.stopAnimating()
                UIAlertUtil.show(error: error, viewController: self) { (_) in
                    UILoader.stopAnimating()
                }
            }
        }
        
    }


    private func SetKeyboardObserver() {
        if self.constButtonBottom != nil {
            NotificationCenter.default.addObserver(self, selector: #selector(KeyboardFrameChanged(notification:)), name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.addObserver(self, selector: #selector(KeyboardFrameChanged(notification:)), name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    private func RemoveKeyboardObserver() {
        if self.constButtonBottom != nil {
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillHideNotification, object: nil)
        }
    }
    
    @objc func KeyboardFrameChanged(notification: Notification) {
        
        let animationDuaration =  notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as! Double
        
        if let keyboardScreenEndFrame = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            if notification.name == UIResponder.keyboardWillShowNotification {
                self.constButtonBottom?.constant = keyboardScreenEndFrame.height - self.view.safeAreaInsets.bottom
            } else if notification.name == UIResponder.keyboardWillHideNotification {
                self.constButtonBottom?.constant = self.constantBottomSpace ?? 0.0
            }
            UIView.animate(withDuration: animationDuaration) {
                self.view.layoutIfNeeded()
            }
        }
    }
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        RemoveKeyboardObserver()
    }
}
