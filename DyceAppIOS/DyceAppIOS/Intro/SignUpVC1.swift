//
//  SignUpVC1.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 11/12/17.
//  Copyright © 2017 Applausity Inc. All rights reserved.
//

import UIKit

class SignUpVC1: UIViewController, UITextFieldDelegate {
    
    //outlets
    @IBOutlet weak var registerLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var lastNameLabel: UILabel!
    @IBOutlet weak var firstNameLabel: UILabel!
    
    @IBOutlet weak var firstNameTF: UITextField!
    @IBOutlet weak var lastNameTF: UITextField!
    @IBOutlet weak var phoneNumberTF: UITextField!
    
    @IBOutlet weak var backBtn: UIButton!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var lineView2: UIView!
    @IBOutlet weak var lineView3: UIView!
    
    //distance from continue button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    
    //keyboard inset
    private var bottomSafeAreaInset: CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) {
            //disables password autoFill accessory views.
            firstNameTF.textContentType = UITextContentType("")
            lastNameTF.textContentType = UITextContentType("")
            phoneNumberTF.textContentType = UITextContentType("")
            phoneNumberTF.textContentType = UITextContentType("")
        }
        
        //sets textfield types
        firstNameTF.autocorrectionType = .no
        lastNameTF.autocorrectionType = .no
        phoneNumberTF.autocorrectionType = .no
        phoneNumberTF.keyboardType = .phonePad
        firstNameTF.autocapitalizationType = .words
        lastNameTF.autocapitalizationType = .words
        
        //sets textfield delegates
        firstNameTF.delegate = self
        lastNameTF.delegate = self
        phoneNumberTF.delegate = self
        
        //rounds buttons
        continueBtn.layer.cornerRadius = 10
        continueBtn.clipsToBounds = true
        
        //configs continue button
        continueBtn.addTarget(self, action: #selector(SignUpVC1.nextPage(sender:)), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        firstNameTF.becomeFirstResponder()
        
        //loads any previously enterred info
        if let firstName = SignUpStorage.firstName {
            firstNameTF.text = firstName
        }
        if let lastName = SignUpStorage.lastName {
            lastNameTF.text = lastName
        }
        if let phoneNumber = SignUpStorage.phoneNumber {
            phoneNumberTF.text = phoneNumber
        }
        
        //adds an observer to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
        self.view.endEditing(true);
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            //this value is the bottom safe area place value.
            bottomSafeAreaInset =  view.safeAreaInsets.bottom
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        print("Too much memory used")
    }
    
    //MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations:  { [weak self] in
            //moves everything up accordingly
            self?.toBottom.constant = keyboardHeight + 10 - (self?.bottomSafeAreaInset)!
            }, completion: nil)
    }

    
    @objc func nextPage(sender: UIButton){
        
        //disables the continue button until this request is handled completely
        continueBtn.isEnabled = false
        
        if let firstName = firstNameTF.name, let lastName = lastNameTF.name, let phoneNumber = phoneNumberTF.phoneNumber{
            SignUpStorage.firstName = firstName
            SignUpStorage.lastName = lastName
            SignUpStorage.phoneNumber = phoneNumber
            continueBtn.isEnabled = true
            performSegue(withIdentifier: "SegueToSignUpP2", sender: sender)
        }
        else{
            let greyColor = UIColor(red: (151/255), green: (151/255), blue: (151/255), alpha: 1)
            lineView1.backgroundColor = greyColor
            lineView2.backgroundColor = greyColor
            lineView3.backgroundColor = greyColor
            if !firstNameTF.textIsAName() {lineView1.backgroundColor = UIColor.red}
            if !lastNameTF.textIsAName() {lineView2.backgroundColor = UIColor.red}
            if !phoneNumberTF.textIsAPhoneNumber() {lineView3.backgroundColor = UIColor.red}
            continueBtn.isEnabled = true
            sender.shake()
        }

    }
    
    
    
    // MARK: - Navigation
    
    /*
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
    
    @IBAction func unwindToRegister(segue: UIStoryboardSegue) {
        print("Unwinding")
    }
    
}
