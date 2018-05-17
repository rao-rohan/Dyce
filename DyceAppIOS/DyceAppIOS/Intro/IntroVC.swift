//
//  IntroVC.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 12/9/17.
//  Copyright © 2017 Applausity Inc. All rights reserved.
//

import UIKit

class IntroVC: UIViewController {
    
    //outlets
    @IBOutlet weak var loginBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //rounds buttons
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
