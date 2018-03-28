//
//  LoginViewController.swift
//  Questions
//
//  Created by Rohan Rao on 10/02/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import Foundation
import UIKit
import Firebase
import ChameleonFramework
import SVProgressHUD
import SCLAlertView
class LoginViewController: UIViewController, UITextFieldDelegate {
    
    var activeField: UITextField?

    @IBOutlet weak var logo: UIImageView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var passwordField: borderlessTextField!
    @IBOutlet weak var usernameField: borderlessTextField!
    //@IBOutlet weak var usernameField: UITextField!
    //@IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signInButton: UIButton!
    //@IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.passwordField.delegate = self
        self.usernameField.delegate = self
        
        let colors:[UIColor] = [
            UIColor(hexString: "98fff3")!,
            UIColor(hexString: "2414ff")!
        ]
        signInButton.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: view.frame, andColors: colors)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    func registerForKeyboardNotifications(){
        //Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(notification:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    func deregisterFromKeyboardNotifications(){
        //Removing notifies on keyboard appearing
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWasShown(notification: NSNotification){
        //Need to calculate keyboard exact size due to Apple suggestions
       // self.scrollView.isScrollEnabled = true
        var info = notification.userInfo!
        let keyboardSize = (info[UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.cgRectValue.size
        let _ : UIEdgeInsets = UIEdgeInsetsMake(0.0, 0.0, keyboardSize!.height, 0.0)

//        self.scrollView.contentInset = contentInsets
//        self.scrollView.scrollIndicatorInsets = contentInsets
//
//        var aRect : CGRect = self.view.frame
//        aRect.size.height -= keyboardSize!.height
//        if let activeField = self.activeField {
//            if (!aRect.contains(activeField.frame.origin)){
//                self.scrollView.scrollRectToVisible(activeField.frame, animated: true)
//            }
//        }
    }
    
    @objc func keyboardWillBeHidden(notification: NSNotification){
    }
    
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -100, up: true)
        logo.isHidden = true
    }
    
    // Finish Editing The Text Field
    func textFieldDidEndEditing(_ textField: UITextField) {
        moveTextField(textField, moveDistance: -100, up: false)
        logo.isHidden = false
    }

    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    @IBAction func unwindToLogin(_ segue: UIStoryboardSegue) {
    }
    
    @IBAction func signInPressed(_ sender: AnyObject) {
        let username = self.usernameField.text
        let password = self.passwordField.text
        var hasError = false
        
        // Validate the text fields
        if username == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a username!")
            hasError = true
            
        }
        if password == "" {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "You haven't entered a password!")
            hasError = true
        }
        
        if(hasError == false) {
            SVProgressHUD.show()
            // Send a request to login
            Auth.auth().signIn(withEmail: username!, password: password!) { (user, error) in
                if ((user) != nil) {
                    SVProgressHUD.dismiss()
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController:UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                        self.present(viewController, animated: true, completion: nil)
                    })
                    
                } else {
                    let alert = SCLAlertView()
                    alert.showError("Error", subTitle: "\(String(describing: error))")
                    SVProgressHUD.dismiss()
                }
            }
        }
    }
    func moveTextField(_ textField: UITextField, moveDistance: Int, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = CGFloat(up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
}


class borderlessTextField: UITextField {
    let padding = UIEdgeInsets(top: 0, left: 10, bottom: 0, right: 10);
    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
    
    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return UIEdgeInsetsInsetRect(bounds, padding)
    }
}
