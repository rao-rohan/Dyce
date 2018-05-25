import Foundation
import UIKit

class QuestionCell: UITableViewCell {
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var categoryFlag: UIView!
    @IBOutlet weak var categoryLabel: UILabel!

    
    var question: Question = Question() {didSet { reloadData() } }

    private func reloadData(){
        questionLabel.text = question.question
        //converts TimeStamp to String
        var timeWord = "second"
        let secondsSinceEpoch = TimeInterval(question.time.seconds)
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
        timeLabel.text = "\(timeSince)" + " " + timeWord + " ago" //sets it to the label
      //  print("\(timeAgo)" + timeWord)
        var replies = " reply"
        if(question.numReplies != 1){
            replies = " replies"
        }
        repliesLabel.text = "\(question.numReplies)" + replies
        usernameLabel.setTitle(question.creatorUsername, for: .normal)
        categoryLabel.text = question.category
    }
}
