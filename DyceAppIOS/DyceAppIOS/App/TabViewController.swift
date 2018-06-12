//
//  TabViewController.swift
//  Questions
//
//  Created by Rohan Rao on 6/10/18.
//  Copyright © 2018 nFinityLabs. All rights reserved.
//

import Foundation
import UIKit

class TabViewController: UITabBarController{
    override func viewDidLoad() {
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle{
        return UIStatusBarStyle.lightContent
    }
}
