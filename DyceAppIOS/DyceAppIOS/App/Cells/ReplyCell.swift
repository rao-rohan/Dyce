//
//  ReplyCell.swift
//  Questions
//
//  Created by Rohan Rao on 10/02/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import Foundation
import UIKit

class ReplyCell: UITableViewCell {
    
    @IBOutlet weak var replyText: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTime: UILabel!
    var reply: Reply = Reply() {didSet { reloadData() } }
    
    private func reloadData(){
        replyText.text = reply.reply
        //converts TimeStamp to String
        var timeWord = "second"
        let secondsSinceEpoch = TimeInterval(reply.time.seconds)
        var timeAgo = NSDate().timeIntervalSince1970 - secondsSinceEpoch
        // print("\(timeAgo)" + timeWord)
        if(timeAgo > 60 && timeWord == "second"){ // more than 60 seconds
            timeAgo /= 60 // now in minutes
            timeWord = "minute"
            //  print("\(timeAgo)" + timeWord)
        }
        if(timeAgo > 60 && timeWord == "minute") {//if more than 60 minutes
            timeAgo /= 60 //now in hours
            timeWord = "hour"
            //  print("\(timeAgo)" + timeWord)
        }
        if(timeAgo > 24 && timeWord == "hour" ){ //if more than 24 hours ago
            timeAgo /= 24 //now in days
            timeWord = "day"
            //  print("\(timeAgo)" + timeWord)
        }
        
        if(timeAgo > 1){ //making the time word gramatically correct
            timeWord += "s"
            //  print("\(timeAgo)" + timeWord)
        }
        
        let timeSince = (Int) (timeAgo) //casts to an integer
        postTime.text = "\(timeSince)" + " " + timeWord + " ago" //sets it to the label
        //  print("\(timeAgo)" + timeWord)
        usernameLabel.text = reply.username
    }
}

