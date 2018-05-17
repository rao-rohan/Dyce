//
//  LoginViewController.swift
//  PickMe
//
//  Created by Nikhil Sridhar on 11/2/17.
//  Copyright © 2017 Nik Sridhar. All rights reserved.
//

import UIKit
import Firebase
import SVProgressHUD

class LoginVC: UIViewController, UITextFieldDelegate {
    
    //distance from login button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    //outlets
    @IBOutlet weak var headerLabel: UILabel!
    
    @IBOutlet weak var passwordLabel: UILabel!
    @IBOutlet weak var emailUsernameLabel: UILabel!
    
    @IBOutlet weak var lineView1: UIView!
    @IBOutlet weak var lineView2: UIView!

    @IBOutlet weak var loginBtn: UIButton!
    
    @IBOutlet weak var emailUsernameTF: UITextField!
    @IBOutlet weak var passwordTF: UITextField!
    
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
            emailUsernameTF.textContentType = UITextContentType("")
            passwordTF.textContentType = UITextContentType("")
        }
        
        //sets textfield types
        emailUsernameTF.autocorrectionType = .no
        passwordTF.autocorrectionType = .no
        emailUsernameTF.autocapitalizationType = .none
        passwordTF.autocapitalizationType = .none
        
        //sets textfield delegates
        emailUsernameTF.delegate = self
        passwordTF.delegate = self
        
        //rounds buttons
        loginBtn.layer.cornerRadius = 10
        loginBtn.clipsToBounds = true
        
        //configs login button
        loginBtn.addTarget(self, action: #selector(LoginVC.login(sender:)), for: .touchUpInside)
        
        //configs firebase references
        userCollection = Firestore.firestore().collection(NameFile.Firestore.users)
        emailCollection = Firestore.firestore().collection(NameFile.Firestore.emails)
        images = Storage.storage().reference().child(NameFile.Firestore.images)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        emailUsernameTF.becomeFirstResponder()
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
    
    
    @objc func login(sender: UIButton){
        
        //disables the login button until this login request is handled completely
        loginBtn.isEnabled = false
        
        let greyColor = UIColor(red: (151/255), green: (151/255), blue: (151/255), alpha: 1)
        lineView1.backgroundColor = greyColor
        lineView2.backgroundColor = greyColor
        
        if let email = emailUsernameTF.email, let password = passwordTF.password {
            
            //starts the activity indicator
            SVProgressHUD.show()
            
            completeLogin(email: email, password: password, sender: sender)
        }
        //if the user chooses to use a username retreive the corresponding email
        else if let username = emailUsernameTF.username, let password = passwordTF.password {
            emailCollection.document(username).getDocument(completion: { (document, error) in
                guard let email = document?.data()?[NameFile.Firestore.email] as? String else{
                    self.lineView1.backgroundColor = UIColor.red
                    self.loginBtn.isEnabled = true
                    sender.shake()
                    return
                }
                
                //starts the activity indicator
                SVProgressHUD.show()
                
                self.completeLogin(email: email, password: password, sender: sender)
            })
        }
        else{
            if !emailUsernameTF.textIsAnEmail() && !emailUsernameTF.textIsAUsername() {lineView1.backgroundColor = UIColor.red}
            if !passwordTF.textIsAPassword() {lineView2.backgroundColor = UIColor.red}
            loginBtn.isEnabled = true
            sender.shake()
        }
    }
    
    //user login through firebase auth
    private func completeLogin(email: String, password: String, sender: UIButton){
        Auth.auth().signIn(withEmail: email, password: password) { (user, error) in
            if let error = error{
                if let code = AuthErrorCode(rawValue: error._code){
                    switch code{
                    case .invalidEmail:
                        self.lineView1.backgroundColor = UIColor.red
                    case .wrongPassword:
                        self.lineView2.backgroundColor = UIColor.red
                    default:
                        break
                    }
                    self.loginBtn.isEnabled = true
                    SVProgressHUD.dismiss()
                    sender.shake()
                }
            }else{
                if let user = user{
                    self.savePersonalInfoLocally(user: user, password: password)
                }
            }
        }
    }
    
    //upon user login saves all  remote personal info locally
    private func savePersonalInfoLocally(user: User, password: String){
        
        userCollection.document(user.uid).getDocument { (document, error) in
            if let document = document{
                let firstName = document[NameFile.Firestore.firstName] as! String
                let lastName = document[NameFile.Firestore.lastName] as! String
                let username = document[NameFile.Firestore.username] as! String
                let phoneNumber = document[NameFile.Firestore.phoneNumber] as! String
                let profileImageURL = document[NameFile.Firestore.profileImageURL] as! String
                AppStorage.PersonalInfo.uid = user.uid
                AppStorage.PersonalInfo.email = user.email!
                AppStorage.PersonalInfo.password = password
                AppStorage.PersonalInfo.firstName = firstName
                AppStorage.PersonalInfo.lastName = lastName
                AppStorage.PersonalInfo.username = username
                AppStorage.PersonalInfo.phoneNumber = phoneNumber
                AppStorage.PersonalInfo.profileImageURL = profileImageURL
                AppStorage.save()
                let profileImageRef = Storage.storage().reference(forURL: profileImageURL)
                profileImageRef.getData(maxSize: 100*1024*1024, completion: { (data, error) in
                    if let data = data{
                        if let profileImage = UIImage(data: data){
                            AppStorage.PersonalInfo.profileImage = profileImage
                            AppStorage.save()
                            self.loginBtn.isEnabled = true
                            SVProgressHUD.dismiss()
                            
                            //segues to app
                            let storyboard: UIStoryboard = UIStoryboard(name: "App", bundle: nil)
                            if let ivc = storyboard.instantiateInitialViewController(){
                                self.show(ivc, sender: self)
                            }
                        }
                    }
                })
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

//returns the textfield's text if it is a given type
//returns if the textfield's text is a given type
extension UITextField {
    var name: String?{
        guard let text = self.text, text.count > 1, text.count < 15 else {
            return nil
        }
        return text
    }
    func textIsAName() -> Bool{
        guard let text = self.text, text.count > 1, text.count < 15 else {
            return false
        }
        return true
    }
    var phoneNumber: String?{
        guard let text = self.text, text.count == 11 else {
            return nil
        }
        return text
    }
    func textIsAPhoneNumber() -> Bool{
        guard let text = self.text, text.count == 11 else {
            return false
        }
        return true
    }
    var email: String?{
        guard let text = self.text, text.count > 7, text.count < 50, text.contains("@"), text.contains(".") else {
            return nil
        }
        return text
    }
    func textIsAnEmail() -> Bool{
        guard let text = self.text, text.count > 7, text.count < 50, text.contains("@"), text.contains(".") else {
            return false
        }
        return true
    }
    var username: String?{
        guard let text = self.text, text.count > 5, text.count < 20 else {
            return nil
        }
        return text
    }
    func textIsAUsername() -> Bool{
        guard let text = self.text, text.count > 5, text.count < 20 else {
            return false
        }
        return true
    }
    var password: String?{
        guard let text = self.text, text.count > 5, text.count < 25 else {
            return nil
        }
        return text
    }
    func textIsAPassword() -> Bool{
        guard let text = self.text, text.count > 5, text.count < 25 else {
            return false
        }
        return true
    }
}

//button shake effect
extension UIView {
    func shake() {
        let animation = CAKeyframeAnimation(keyPath: "transform.translation.x")
        animation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionLinear)
        animation.duration = 0.6
        animation.values = [-15.0, 15.0, -15.0, 15.0, -10.0, 10.0, -5.0, 5.0, 0.0 ]
        layer.add(animation, forKey: "shake")
    }
}
