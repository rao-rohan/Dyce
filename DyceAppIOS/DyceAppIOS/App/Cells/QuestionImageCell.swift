import Foundation
import UIKit

//this cell displays the appearance of a Question object which contains an image

class QuestionImageCell: UITableViewCell {
     let colorPicker = CategoryHelper()
    
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var postImage: UIImageView!
    @IBOutlet weak var categoryFlag: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    
    var question: Question = Question() {didSet { reloadData() } }
    
    private func reloadData(){
        questionLabel.text = question.question

        //converts to the appropriate unit of time
        var timeWord = "second"
        let secondsSinceEpoch = TimeInterval(question.time.seconds)
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
        timeLabel.text = "\(timeSince)" + " " + timeWord + " ago"

        var replies = " reply"
        if(question.numReplies != 1){
            replies = " replies"
        }
        repliesLabel.text = "\(question.numReplies)" + replies
        
        usernameLabel.setTitle(question.creatorUsername, for: .normal)
        postImage.image = question.image
        categoryLabel.text = question.category
        categoryFlag.backgroundColor = colorPicker.colorChooser(question.category)
        
    }
}
