//
//  SignUpVC1.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 11/3/17.
//  Copyright © 2017 Applausity Inc. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class SignUpVC2: UIViewController, UITextFieldDelegate {
    
    //distance from continue button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    //outlets
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var accountInfoLabel: UILabel!
    @IBOutlet weak var termsOfServiceLabel: UILabel!
    
    @IBOutlet weak var usernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    @IBOutlet weak var emailTF: UITextField!
    
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var lineView2: UIView!
    @IBOutlet weak var lineView3: UIView!
    
    @IBOutlet weak var signUpBtn: UIButton!
    @IBOutlet weak var backBtn: UIButton!
    
    //keyboard inset
    private var bottomSafeAreaInset: CGFloat = 0
    
    //firebase references
    var emailCollection: CollectionReference!
    var userCollection: CollectionReference!
    var images: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 11, *) {
            //disables password autoFill accessory views.
            usernameTF.textContentType = UITextContentType("")
            passwordTF.textContentType = UITextContentType("")
            emailTF.textContentType = UITextContentType("")
        }
        
        //sets textfield types
        usernameTF.autocorrectionType = .no
        passwordTF.autocorrectionType = .no
        emailTF.autocorrectionType = .no
        emailTF.keyboardType = .emailAddress
        
        //sets textfield delegates
        emailTF.delegate = self
        passwordTF.delegate = self
        usernameTF.delegate = self
        
        //rounds buttons
        signUpBtn.layer.cornerRadius = 10
        signUpBtn.clipsToBounds = true
        
        //configs sign up button
        signUpBtn.addTarget(self, action: #selector(SignUpVC2.signUp(sender:)), for: .touchUpInside)
        
        //sets URL for text in termsOfServiceLabel
        let string = "By signing up you accept our privacy policy and terms of service"
        let range = (string as NSString).range(of: "privacy policy and terms of service")
        let attributedString = NSMutableAttributedString(string: string)
        let tosappURL = URL(string: "blahblahblah")
        if let url = tosappURL{
            attributedString.addAttribute(.link, value: url, range: range)
        }
        attributedString.addAttribute(.underlineStyle, value: 1, range: range)
        attributedString.addAttribute(.underlineColor, value: UIColor.blue, range: range)
        termsOfServiceLabel.attributedText = attributedString
        
        //configs firebase references
        userCollection = Firestore.firestore().collection(NameFile.Firestore.users)
        emailCollection = Firestore.firestore().collection(NameFile.Firestore.emails)
        images = Storage.storage().reference().child(NameFile.Firestore.images)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        usernameTF.becomeFirstResponder()
        
        //loads any previously enterred info
        if let username = SignUpStorage.username {
            usernameTF.text = username
        }
        if let email = SignUpStorage.email {
            emailTF.text = email
        }
        if let password = SignUpStorage.password {
            passwordTF.text = password
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
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
    
    @objc func signUp(sender: UIButton){
        
        //disables the sign up button until this sign up request is handled completely
        signUpBtn.isEnabled = false
        
        if let username = usernameTF.username, let password = passwordTF.password, let email = emailTF.email{
            SignUpStorage.username = username
            SignUpStorage.password = password
            SignUpStorage.email = email
            
            //starts the activity indicator
            SVProgressHUD.show()
            
            validateUsername(sender: sender)
        }
        else{
            let greyColor = UIColor(red: (151/255), green: (151/255), blue: (151/255), alpha: 1)
            lineView1.backgroundColor = greyColor
            lineView2.backgroundColor = greyColor
            lineView3.backgroundColor = greyColor
            
            if !usernameTF.textIsAUsername() {lineView1.backgroundColor = UIColor.red}
            if !passwordTF.textIsAPassword() {lineView2.backgroundColor = UIColor.red}
            if !emailTF.textIsAnEmail() {lineView3.backgroundColor = UIColor.red}
            signUpBtn.isEnabled = true
            sender.shake()
        }
        
    }
    
    //ensures that the user's username has not already been taken
    private func validateUsername(sender: UIButton){
        emailCollection.document(SignUpStorage.username!).getDocument { (document, error) in
            if let _ = document?.data(){
                //username already exists
                self.lineView1.backgroundColor = UIColor.red
                self.signUpBtn.isEnabled = true
                SVProgressHUD.dismiss()
                sender.shake()
            }else{
                self.createUser(sender: sender)
            }
        }
    }
    
    //creates user through firebase auth using email and password
    private func createUser(sender: UIButton){
        Auth.auth().createUser(withEmail: SignUpStorage.email!, password: SignUpStorage.password!) { (user, error) in
            if let error = error{
                if let code = AuthErrorCode(rawValue: error._code){
                    switch code{
                    case .invalidEmail:
                        self.lineView3.backgroundColor = UIColor.red
                    case .emailAlreadyInUse:
                        self.lineView3.backgroundColor = UIColor.red
                    case .weakPassword:
                        self.lineView2.backgroundColor = UIColor.red
                    default:
                        break
                    }
                    self.signUpBtn.isEnabled = true
                    SVProgressHUD.dismiss()
                    sender.shake()
                }
            }else{
                if let user = user{
                    self.savePersonalInfoRemotely(user: user)
                }
            }
        }
    }
    
    //when an user completes sign up saves all their personal info remotely
    private func savePersonalInfoRemotely(user: User){
        images.child("DefaultImage").downloadURL { (url, error) in
            if let url = url{
                self.emailCollection.document(SignUpStorage.username!).setData([NameFile.Firestore.email: user.email!])
                
                self.userCollection.document(user.uid).setData([
                    NameFile.Firestore.firstName:                                                 SignUpStorage.firstName!,
                    NameFile.Firestore.lastName: SignUpStorage.lastName!,
                    NameFile.Firestore.username: SignUpStorage.username!,
                    NameFile.Firestore.phoneNumber: SignUpStorage.phoneNumber!,
                    NameFile.Firestore.profileImageURL: url.absoluteString
                ])
                
                AppStorage.PersonalInfo.uid = user.uid
                AppStorage.PersonalInfo.email = SignUpStorage.email!
                AppStorage.PersonalInfo.password = SignUpStorage.password!
                AppStorage.PersonalInfo.firstName = SignUpStorage.firstName!
                AppStorage.PersonalInfo.lastName = SignUpStorage.lastName!
                AppStorage.PersonalInfo.username = SignUpStorage.username!
                AppStorage.PersonalInfo.phoneNumber = SignUpStorage.phoneNumber!
                AppStorage.PersonalInfo.profileImage = #imageLiteral(resourceName: "default")
                AppStorage.PersonalInfo.profileImageURL = url.absoluteString
                AppStorage.save()
                SignUpStorage.empty()
                
                self.signUpBtn.isEnabled = true
                SVProgressHUD.dismiss()
                self.performSegue(withIdentifier: "SegueToProfileImage", sender: self)
            }
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
    
}
