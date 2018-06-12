//
//  SettingsDetailVC3.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 3/12/18.
//  Copyright © 2018 Applausity. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

//THREE CELL VIEW CONTROLLER

class SettingsDetailVC3: UIViewController {
    
    //model
    var type: SettingsType = .password
    
    //detail header outlet
    @IBOutlet weak var detailTV: UITextView!
    
    //outlets
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var secondTF: UITextField!
    @IBOutlet weak var thirdTF: UITextField!
    
    @IBOutlet weak var continueBtn: UIButton!
    @IBOutlet weak var removeBtn: UIButton!
    
    @IBOutlet weak var separatorView1: UIView!
    @IBOutlet weak var separatorView2: UIView!
    
    //distance from continue button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    //keyboard inset
    private var bottomSafeAreaInset: CGFloat = 0
    
    //firebase references
    var userCollection: CollectionReference!
    var postsCollection : CollectionReference!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(AppStorage.PersonalInfo.password)
        
        loadCustomView()
        
        //hides the continue button
        continueBtn.isHidden = true
        
        //sets textfield types
        firstTF.autocorrectionType = .no
        secondTF.autocorrectionType = .no
        thirdTF.autocorrectionType = .no
        
        //sets textfield insets
        let spacerView1 = UIView(frame:CGRect(x: 0, y: 0, width: 22, height:firstTF.frame.height))
        let spacerView2 = UIView(frame:CGRect(x: 0, y: 0, width: 22, height:firstTF.frame.height))
        let spacerView3 = UIView(frame:CGRect(x: 0, y: 0, width: 22, height:firstTF.frame.height))
        firstTF.leftView = spacerView1
        firstTF.leftViewMode = UITextFieldViewMode.always
        secondTF.leftView = spacerView2
        secondTF.leftViewMode = UITextFieldViewMode.always
        thirdTF.leftView = spacerView3
        thirdTF.leftViewMode = UITextFieldViewMode.always
        
        //adds observer methods to buttons
        removeBtn.addTarget(self, action: #selector(SettingsDetailVC3.removeAllFields(_:)), for: .touchUpInside)
        continueBtn.addTarget(self, action: #selector(SettingsDetailVC3.saveSettings(sender:)), for: .touchUpInside)
        
        //adds observer methods to textfields
        firstTF.addTarget(self, action: #selector(SettingsDetailVC3.textFieldDidChange(_:)), for: .editingChanged)
        secondTF.addTarget(self, action: #selector(SettingsDetailVC3.textFieldDidChange(_:)), for: .editingChanged)
        thirdTF.addTarget(self, action: #selector(SettingsDetailVC3.textFieldDidChange(_:)), for: .editingChanged)
        
        //adds an observer to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //configs firebase references
        userCollection = Firestore.firestore().collection(NameFile.Firestore.users)
        postsCollection = Firestore.firestore().collection(NameFile.Firestore.posts)
    }
    
    override func viewSafeAreaInsetsDidChange() {
        if #available(iOS 11.0, *) {
            super.viewSafeAreaInsetsDidChange()
            //this value is the bottom safe area place value.
            bottomSafeAreaInset =  view.safeAreaInsets.bottom
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        SVProgressHUD.dismiss()
    }
    
    //MARK - Observer methods
    
    @objc private func removeAllFields(_ button: UIButton) {
        firstTF.text = nil
        secondTF.text = nil
        thirdTF.text = nil
        firstTF.resignFirstResponder()
        secondTF.resignFirstResponder()
        thirdTF.resignFirstResponder()
        firstTF.correctColorScheme()
        secondTF.correctColorScheme()
        thirdTF.correctColorScheme()
        continueBtn.isHidden = true
    }
    
    @objc private func textFieldDidChange(_ textField: UITextField) {
        continueBtn.isHidden = true
        switch type {
        case .password:
            if firstTF.textIsAPassword() && secondTF.textIsAPassword() && thirdTF.textIsAPassword(){
                continueBtn.isHidden = false
            }
        default:
            break
        }
    }
    
    @objc private func saveSettings(sender: UIButton){
        switch type {
            
        case .password:
            
            firstTF.correctColorScheme()
            secondTF.correctColorScheme()
            thirdTF.correctColorScheme()
            continueBtn.isEnabled = false
            
            if firstTF.text == AppStorage.PersonalInfo.password, let newPassword = secondTF.password, thirdTF.text == newPassword{
                
                //starts the activity indicator
                SVProgressHUD.show()
                
                updatePassword(password: newPassword, sender: sender)
            }else{
                if firstTF.text != AppStorage.PersonalInfo.password {firstTF.incorrectColorScheme()}
                if !secondTF.textIsAPassword() {secondTF.incorrectColorScheme()}
                if thirdTF.text != secondTF.text {thirdTF.incorrectColorScheme()}
                continueBtn.isEnabled = true
                sender.shake()
            }
            
        default:
            break
            
        }
    }
    
    private func updatePassword(password: String, sender: UIButton){
        Auth.auth().currentUser?.updatePassword(to: password, completion: { (error) in
            if let error = error{
                if let code = AuthErrorCode(rawValue: error._code){
                    switch code{
                    case .requiresRecentLogin:
                        //re-authenticates the user if it has been a while since he or she has logged in
                        let credential = EmailAuthProvider.credential(withEmail: AppStorage.PersonalInfo.email, password: AppStorage.PersonalInfo.password)
                        Auth.auth().currentUser?.reauthenticateAndRetrieveData(with: credential, completion: { (authResult, error) in
                            if error != nil{
                                print("Can't reauthenticate")
                            }else{
                                self.updatePassword(password: password, sender: sender)
                            }
                        })
                    default:
                        self.secondTF.incorrectColorScheme()
                        self.continueBtn.isEnabled = true
                        SVProgressHUD.dismiss()
                        sender.shake()
                    }
                }
            }else{
                AppStorage.PersonalInfo.password = self.secondTF.text!
                AppStorage.save()
                self.continueBtn.isEnabled = true
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: NameFile.Segues.Profile.unwindToSettings, sender: self)
            }
        })
    }
    
    //loads the view of the view controller based on the specified type
    private func loadCustomView(){
        switch type {
            
        case .password:
            self.title = "Password"
            detailTV.text = "Enter a password to access your account and protect your information"
            firstTF.placeholder = "Current Password"
            secondTF.placeholder = "New Password"
            thirdTF.placeholder = "Confirm Password"
            firstTF.isSecureTextEntry = true
            secondTF.isSecureTextEntry = true
            thirdTF.isSecureTextEntry = true
        default:
            break
            
        }
    }
    
    //MARK: - Keyboard
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        let keyboardHeight = keyboardRectangle.height
        
        UIView.animate(withDuration: 0.4, delay: 0.0, options: [], animations:  { [weak self] in
            //moves everything up accordingly
            self?.toBottom.constant = keyboardHeight + 10 - (self?.bottomSafeAreaInset)! - 10
            }, completion: nil)
    }
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
