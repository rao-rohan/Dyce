//
//  SignUpViewController.swift
//  Questions
//
//  Created by Rohan Rao on 10/02/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import Foundation
import SVProgressHUD
import SCLAlertView
import UIKit
import Firebase


class SignUpViewController: VCWithKeyboard , UITextFieldDelegate {
    
    @IBOutlet weak var stackView: UIStackView!
    @IBOutlet weak var signUpTF: UILabel!
    @IBOutlet weak var fullNameField: UITextField! //username
    @IBOutlet weak var backBT: UIButton!
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var passwordField: UITextField!
    @IBOutlet weak var signUpButton: UIButton!
    var keyboardHeight : CGFloat = 0
    var prevHeight : CGFloat = 0
    override func viewDidLoad() {
        super.viewDidLoad()
     //   UIKeyboardType = .alphabet
        self.passwordField.delegate = self
        self.fullNameField.delegate = self
        self.emailField.delegate = self
        self.backBT.isHidden = false
        let colors:[UIColor] = [
            UIColor(hexString: "dd2c00")!,
            UIColor(hexString: "ffc107")!
        ]
        
        signUpButton.backgroundColor = UIColor.init(gradientStyle: .leftToRight, withFrame: view.frame, andColors: colors)
        
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    @IBAction func signUpPressed(_ sender: AnyObject) {
        let username = fullNameField.text
        let password = self.passwordField.text
        let email = self.emailField.text
        var hasError = false
        
        // Validate the text fields
        
        if username == "" || username == " " || username == "   "{
            UIView.animateKeyframes(withDuration: 0.75, delay: 0.1, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x += 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.2625, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x -= 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.425, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x += 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5875, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x -= 20
                })
            }, completion: { (success) in
                print("Here")
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "You haven't entered a username!")
                hasError = true
                
            })
        }
        
        if email == "" || email == " " || email == "  "{
            UIView.animateKeyframes(withDuration: 0.75, delay: 0.1, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x += 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.2625, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x -= 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.425, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x += 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5875, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x -= 20
                })
            }, completion: { (success) in
                print("Here")
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "You haven't entered an email!")
                hasError = true
                
            })
            
        }
        
        if password == "" || password == " " || password == " " {
            UIView.animateKeyframes(withDuration: 0.75, delay: 0.1, options: [.calculationModeLinear], animations: {
                UIView.addKeyframe(withRelativeStartTime: 0.1, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x += 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.2625, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x -= 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.425, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x += 20
                })
                UIView.addKeyframe(withRelativeStartTime: 0.5875, relativeDuration: 0.1625, animations: {
                    self.signUpButton.center.x -= 20
                })
            }, completion: { (success) in
                print("Here")
                let alert = SCLAlertView()
                alert.showError("Error", subTitle: "You haven't entered a password!")
                hasError = true
            })
            
        }
        
        if(hasError == false) {
    
            SVProgressHUD.show()
            Auth.auth().createUser(withEmail: email!, password: password!) { (user, error) in
                if (error == nil) {
                    SVProgressHUD.dismiss()
                    let user = Auth.auth().currentUser
                    if let user = user{
                        let changeRequest = user.createProfileChangeRequest()
                        changeRequest.displayName = username
                        print(Auth.auth().currentUser?.displayName)
                        changeRequest.commitChanges(completion: { (error) in
                            if let error = error {
                                print("error")
                            }else{
                                print("its okay it workeD")
                            }
                        })
                    }
                    SVProgressHUD.showSuccess(withStatus: "Welcome to Dyce!")
                    DispatchQueue.main.async(execute: { () -> Void in
                        let viewController: UIViewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "TabBarController")
                        self.present(viewController, animated: true, completion: nil)
                    })
                }
                else {
                    SVProgressHUD.dismiss()
                }
            }
        }
    }

}


