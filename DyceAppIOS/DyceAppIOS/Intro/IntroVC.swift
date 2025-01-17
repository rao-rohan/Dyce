// Names: Nikhil Sridhar and Rohan Rao
//
// File Name: IntroVC.swift
//
// File Description: This class represents the intro screen in the login. 

import UIKit

class IntroVC: UIViewController {
    
    //outlets
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginBtn.layer.cornerRadius = 10
        registerBtn.layer.cornerRadius = 10
    }
    
    // MARK: - Navigation
    
    @IBAction func unwindToIntro(segue: UIStoryboardSegue) {
        print("unwinding")
    }

    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
