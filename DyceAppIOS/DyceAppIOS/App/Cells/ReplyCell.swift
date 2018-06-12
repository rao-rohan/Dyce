// Names: Nikhil Sridhar and Rohan Rao
//
// File Name: ReplyCell.swift
//
// File Description: This cell displays the appearance of a Reply object. 

import Foundation
import UIKit

class ReplyCell: UITableViewCell {
    
    @IBOutlet weak var replyText: UILabel!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var postTime: UILabel!
    
    var reply: Reply = Reply() {didSet { reloadData() } }
    
    private func reloadData(){
        replyText.text = reply.reply
        
        //converts to the appropriate unit of time
        var timeWord = "second"
        let secondsSinceEpoch = TimeInterval(reply.time.seconds)
        var ago = NSDate().timeIntervalSince1970 - secondsSinceEpoch
        if(ago > 60 && timeWord == "second"){
            ago /= 60
            timeWord = "minute"
        }
        if(ago > 60 && timeWord == "minute") {
            ago /= 60
            timeWord = "hour"
        }
        if(ago > 24 && timeWord == "hour" ){
            ago /= 24
            timeWord = "day"
        }
        if(ago > 1){
            timeWord += "s"
        }
        let timeSince = (Int) (ago)
        postTime.text = "\(timeSince)" + " " + timeWord + " ago"

        usernameLabel.text = reply.username
    }
}

