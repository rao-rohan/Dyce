//
//  QuestionHeaderView.swift
//  Questions
//
//  Created by Rohan Rao on 10/02/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import UIKit

class QuestionHeaderView: UITableViewHeaderFooterView {

    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var profilePicView: UIImageView!
    
    var posterUID: String = ""
    
    
}
