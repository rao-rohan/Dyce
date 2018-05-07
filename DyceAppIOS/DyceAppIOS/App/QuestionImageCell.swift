import Foundation
import UIKit

class QuestionImageCell: UITableViewCell {
    
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
        repliesLabel.text = "\(question.numReplies)"
        usernameLabel.setTitle(question.creatorUsername, for: .normal)
        postImage.image = question.image
        categoryLabel.text = question.category
        
        let secondsSinceEpoch = TimeInterval(question.time.seconds)
        let secondsAgo = NSDate().timeIntervalSince1970 - secondsSinceEpoch
        let minutesAgo = (Int) (secondsAgo / 60)
        
        timeLabel.text = "\(minutesAgo) min ago"
    }
}
