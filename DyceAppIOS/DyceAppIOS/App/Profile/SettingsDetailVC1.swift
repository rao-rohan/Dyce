//
//  SettingsDetailVC2.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 1/27/18.
//  Copyright © 2018 Applausity Inc. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

//ONE CELL VIEW CONTROLLER

class SettingsDetailVC1: UIViewController, UITextFieldDelegate {
    
    //model
    var type: SettingsType = .email
    
    //detail header outlet
    @IBOutlet weak var detailTV: UITextView!
    
    //outlets
    @IBOutlet weak var firstTF: UITextField!
    @IBOutlet weak var removeBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    //distance from continue button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    //keyboard inset
    private var bottomSafeAreaInset: CGFloat = 0
    
    //firebase references
    var userCollection: CollectionReference!
    var postsCollection : CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loadCustomView()
        
        //hides the continue button
        continueBtn.isHidden = true
        
        //sets textfield types
        firstTF.autocorrectionType = .no
        
        //sets textfield inset
        let spacerView = UIView(frame:CGRect(x: 0, y: 0, width: 22, height:firstTF.frame.height))
        firstTF.leftView = spacerView
        firstTF.leftViewMode = UITextFieldViewMode.always
        
        //adds observer methods to buttons
        removeBtn.addTarget(self, action: #selector(SettingsDetailVC1.removeAllFields(_:)), for: .touchUpInside)
        continueBtn.addTarget(self, action: #selector(SettingsDetailVC1.saveSettings(sender:)), for: .touchUpInside)
        
        //adds observer methods to textfields
        firstTF.addTarget(self, action: #selector(SettingsDetailVC1.textFieldDidChange(_:)), for: .editingChanged)
        
        //adds an observer to the keyboard
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        //configs firebase references
        userCollection = Firestore.firestore().collection(NameFile.Firestore.users)
        setTextFieldValue()
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
    
    
    @objc private func removeAllFields(_ button: UIButton) {
        firstTF.text = nil
        firstTF.resignFirstResponder()
        firstTF.correctColorScheme()
        continueBtn.isHidden = true
    }
    private func setTextFieldValue(){
        switch  type {
        case .username:
            firstTF.text = AppStorage.PersonalInfo.username
        case .email:
            firstTF.text = AppStorage.PersonalInfo.email
        default:
            firstTF.text = nil
        }
    }
    
    
    @IBAction func textFieldTouched(_ sender: Any) {
        firstTF.text = nil
    }
    @objc private func textFieldDidChange(_ textField: UITextField) {
        continueBtn.isHidden = true
        
        switch type {
            
        case .email:
            if textField == firstTF {
                if textField.text != AppStorage.PersonalInfo.email{
                    continueBtn.isHidden = false
                }else{firstTF.correctColorScheme()}
            }
        case .username:
            if textField == firstTF {
                if textField.text != AppStorage.PersonalInfo.username{
                    continueBtn.isHidden = false
                }else{firstTF.correctColorScheme()}
            }
        default:
            break
            
        }
    }
    
    @objc private func saveSettings(sender: UIButton){
        switch type {
            
        case .email:
            
            continueBtn.isEnabled = false
            firstTF.correctColorScheme()
            
            if let email = firstTF.email{
                
                //starts the activity indicator
                SVProgressHUD.show()
                
                updateEmail(email: email, sender: sender)
            }else{
                firstTF.incorrectColorScheme()
                continueBtn.isEnabled = true
                sender.shake()
            }
        case .username:
            
            continueBtn.isEnabled = false
            firstTF.correctColorScheme()
            
            if let username = firstTF.username{
                
                //starts the activity indicator
                SVProgressHUD.show()
                
                updateUsername(username: username, sender: sender)
            }else{
                firstTF.incorrectColorScheme()
                continueBtn.isEnabled = true
                sender.shake()
            }
        default:
            break
            
        }
    }
    
    private func updateEmail(email: String, sender: UIButton){
        Auth.auth().currentUser?.updateEmail(to: email, completion: { (error) in
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
                                //possible recursion
                                self.updateEmail(email: email, sender: sender)
                            }
                        })
                    default:
                        self.firstTF.incorrectColorScheme()
                        self.continueBtn.isEnabled = true
                        SVProgressHUD.dismiss()
                        sender.shake()
                    }
                }
            }else{
                AppStorage.PersonalInfo.email = email
                AppStorage.save()
                self.continueBtn.isEnabled = true
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: NameFile.Segues.Profile.unwindToSettings, sender: self)
            }
        })
    }
    private func updateUsername(username: String, sender: UIButton){
        let changeRequest = Auth.auth().currentUser?.createProfileChangeRequest()
        changeRequest?.displayName = username
        changeRequest?.commitChanges(completion: { (error) in
            if let error = error{
                print(error.localizedDescription)
                self.firstTF.incorrectColorScheme()
                self.continueBtn.isEnabled = true
                SVProgressHUD.dismiss()
                sender.shake()
            }
            else{
                AppStorage.PersonalInfo.username = username
                AppStorage.save()
                self.continueBtn.isEnabled = true
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: NameFile.Segues.Profile.unwindToSettings, sender: self)
            }
        })
        
        
        
    }
    
    
    //load the view of the view controller based on the specified type
    private func loadCustomView(){
        switch type {
            
        case .email:
            firstTF.text = AppStorage.PersonalInfo.email
            self.title = "Email"
            detailTV.text = "Enter an email to receive electronic receipts, alerts, and other notifications"
            firstTF.placeholder = "Email"
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

//adjusts a texfield's appearance based on the relative accuracy of its content
extension UITextField {
    func correctColorScheme() {
        backgroundColor = UIColor.white
        textColor = UIColor.black
        if let placeholder = placeholder{
            attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.gray])
        }
    }
    func incorrectColorScheme() {
        backgroundColor = UIColor.red
        textColor = UIColor.white
        if let placeholder = placeholder{
            attributedPlaceholder = NSAttributedString(string: placeholder,
                                                       attributes: [NSAttributedStringKey.foregroundColor: UIColor.white])
        }
    }
}
