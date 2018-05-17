import Foundation
import UIKit
import Firebase
import SVProgressHUD
import SCLAlertView

class ReplyViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var question = Question()
    var keyboardHeight : CGFloat = 0
    var height : CGFloat = 0
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var tableView : UITableView!
    private var replies = [Reply]() {didSet{tableView.reloadData()}}
    var questionHeaderView: QuestionHeaderView?
    var questionImageHeaderView: QuestionImageHeaderView?
    let colorPicker = CategoryHelper()
    var image = UIImage()
    var hasImage = false
    override func viewDidLoad() {
        super.viewDidLoad()
        print(hasImage)
        print("entered replies" )
        self.replyTextField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.separatorStyle = .none
        
        tableView.estimatedRowHeight = 150.0
        tableView.rowHeight = UITableViewAutomaticDimension
        if hasImage{
            questionImageHeaderView = UINib(nibName: "QuestionHeaderImageView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionImageHeaderView
            questionImageHeaderView?.posterUID = question.creatorUID
            questionImageHeaderView?.usernameLabel.text = question.creatorUsername
            questionImageHeaderView?.questionLabel.text = question.question
            questionImageHeaderView?.categoryLabel.text = question.category
            questionImageHeaderView?.timeLabel.text = convertTime(_time: question.time)
            questionImageHeaderView?.imageView.clipsToBounds = true
            questionImageHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question.category)
            questionImageHeaderView?.imageView.image = question.image
            questionImageHeaderView?.imageView.image = rotateImage(image: question.image!)
            questionImageHeaderView?.repliesLabel.text = calcReplies(_reply: question.numReplies)
            
        }
        else {
            //Normal Cell Detail
            questionHeaderView = UINib(nibName: "QuestionHeaderView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionHeaderView
            questionHeaderView?.posterUID = question.creatorUID
            questionHeaderView?.usernameLabel.text = question.creatorUsername
            questionHeaderView?.questionLabel.text = question.question
            questionHeaderView?.categoryLabel.text = question.category
            questionHeaderView?.timeLabel.text = convertTime(_time: question.time)
            questionHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question.category)
            questionHeaderView?.categoryLabel.text = question.category
            questionHeaderView?.repliesLabel.text = calcReplies(_reply: question.numReplies)
        }
        fetchReplies()
        
        
    }
    override func viewDidAppear(_ animated: Bool) {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)),
                                               name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    func calcReplies(_reply : Int) -> String{
        var replies = " reply"
        if(question.numReplies != 1){
            replies = " replies"
        }
        return "\(question.numReplies)" + replies
    }
    func convertTime(_time : Timestamp) -> String {
        //converts TimeStamp to String
        var timeWord = "second"
        let secondsSinceEpoch = TimeInterval(_time.seconds)
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
        return "\(timeSince)" + " " + timeWord + " ago" //sets it to the label
    }
    func fetchReplies(){
        replies.removeAll()
        print("fetching replies")
        let repliesCollection = Firestore.firestore().collection(NameFile.Firestore.FirestorePosts).document(question.postID).collection(NameFile.Firestore.replies)
        repliesCollection.getDocuments(completion: { (snapshot, error) in
            if let documents = snapshot?.documents{
                for document in documents {
                    let posterUID = document[NameFile.Firestore.replyUID] as! String
                    let posterUsername = document[NameFile.Firestore.replyUsername] as! String
                    let replyText = document[NameFile.Firestore.reply] as! String
                    let replyTime = document[NameFile.Firestore.replyTime] as! Timestamp
                    self.appendInOrder(_reply: (Reply(_uid: posterUID, _username: posterUsername, _reply: replyText, _time: replyTime)))
                }
            }
        })
    }
    func appendInOrder(_reply : Reply){
        for (index, reply)  in replies.enumerated(){
            let secondsSinceEpochReply = TimeInterval(reply.time.seconds)
            let timeAgoReply = NSDate().timeIntervalSince1970 - secondsSinceEpochReply
            let secondsSinceEpoch_Reply = TimeInterval(_reply.time.seconds)
            let timeAgo_Reply = NSDate().timeIntervalSince1970 - secondsSinceEpoch_Reply
            if timeAgo_Reply < timeAgoReply{
                self.replies.insert(_reply, at: index)
                return
            }
        }
        self.replies.append(_reply)
        
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height - height
        moveTextField(replyTextField, moveDistance: -keyboardHeight, up: true)
        // do whatever you want with this keyboard height
    }
    
    @objc func keyboardWillHide(notification: Notification) {
        // keyboard is dismissed/hidden from the screen
        moveTextField(replyTextField, moveDistance: -keyboardHeight, up: false)
    }
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        textField.text = ""
        return true
    }
    
    @IBAction func sendPressed(_ sender: AnyObject) {
        let reply = Reply()
        let alert = SCLAlertView()
        if(replyTextField.text != "") {
            reply.postID = question.postID
            reply.reply = replyTextField.text!
            reply.uid = AppStorage.PersonalInfo.uid
            reply.username = AppStorage.PersonalInfo.username
            reply.pushToFirestore()
            fetchReplies()
        }
        else{
            alert.showError("Error", subTitle: "Couldn't get location!")
        }
        textFieldShouldReturn(replyTextField)
    }
    
    func moveTextField(_ textField: UITextField, moveDistance: CGFloat, up: Bool) {
        let moveDuration = 0.3
        let movement: CGFloat = (up ? moveDistance : -moveDistance)
        UIView.beginAnimations("animateTextField", context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(moveDuration)
        self.view.frame = self.view.frame.offsetBy(dx: 0, dy: movement)
        UIView.commitAnimations()
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(true)
        NotificationCenter.default.removeObserver(self)
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(questionHeaderView != nil) {
            return questionHeaderView
        }
        return questionImageHeaderView
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(questionHeaderView != nil) {
            return 224.0
        }
        return 360.0
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reply = replies[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath)
        if let cell = cell as? ReplyCell{
            cell.reply = reply
            return cell
        }
        return UITableViewCell()
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    func rotateImage(image:UIImage) -> UIImage
    {
        var rotatedImage = UIImage()
        switch image.imageOrientation
        {
        case .right:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .down)
            
        case .down:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .left)
            
        case .left:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .up)
            
        default:
            rotatedImage = UIImage(cgImage: image.cgImage!, scale: 1.0, orientation: .right)
        }
        
        return rotatedImage
    }
    
}

