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
        timeLabel.text = question.time
        repliesLabel.text = "\(question.numReplies)"
        usernameLabel.setTitle(question.creatorUsername, for: .normal)
        categoryLabel.text = question.category
    }
}
