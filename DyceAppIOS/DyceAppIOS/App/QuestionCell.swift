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
        let secondsSinceEpoch = TimeInterval(question.time.seconds)
        let secondsAgo = NSDate().timeIntervalSince1970 - secondsSinceEpoch
        let minutesAgo = (Int) (secondsAgo / 60)
        
        timeLabel.text = "\(minutesAgo) min ago"
        
        let date = NSDate(timeIntervalSince1970: secondsSinceEpoch)
        
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.current //Set timezone that you want
        dateFormatter.locale = NSLocale.current
        dateFormatter.dateFormat = "HH:mm" //Specify your format that you want
        
        repliesLabel.text = "\(question.numReplies)"
        usernameLabel.setTitle(question.creatorUsername, for: .normal)
        categoryLabel.text = question.category
    }
}
