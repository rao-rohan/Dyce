//
//  QuestionHeaderView.swift
//  Questions
//
//  Created by Rohan Rao on 10/10/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import UIKit


class QuestionImageHeaderView: UITableViewHeaderFooterView {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var profPic: UIImageView!
    @IBOutlet weak var repliesLabel: UILabel!
    
    var posterUID : String = ""
    
}
