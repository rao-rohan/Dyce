// Names: Nikhil Sridhar and Rohan Rao
//
// File Name: ReplyViewController.swift
//
// File Description: This view controller operates with an array of Reply objects to display.

import Foundation
import UIKit
import Firebase
import SVProgressHUD
import SCLAlertView
import DZNEmptyDataSet

class ReplyViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource{
    
    var question = Question()
    var keyboardHeight : CGFloat = 0
    var height : CGFloat = 0
    var isFavorite = false
    @IBOutlet weak var replyTextField: UITextField!
    @IBOutlet weak var tableView : UITableView!
    
    var delegate: ReplyCompletedDelegate?
    private var replies = [Reply]() {didSet{tableView.reloadData()}}
    var questionHeaderView: QuestionHeaderView?
    var questionImageHeaderView: QuestionImageHeaderView?
    let colorPicker = CategoryHelper()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.replyTextField.delegate = self
        self.tableView.delegate = self
        self.tableView.dataSource = self
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        print(question.question)
        initQuestionHeader()
        fetchReplies()
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        tableView.reloadData()
    }
    func initQuestionHeader(){
        if let image = question.image{
            questionImageHeaderView = UINib(nibName: "QuestionHeaderImageView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionImageHeaderView
            questionImageHeaderView?.question = Question(_creatorUID: question.creatorUID, _creatorUsername: question.creatorUsername, _postID: question.postID, _category: question.category, _time: question.time, _question: question.question, _numReplies: question.numReplies, _imageURL: question.imageURL, _image: image)
            if(isFavorite){
                questionImageHeaderView?.isFavorited = true
                questionImageHeaderView?.favoriteButton.setImage(#imageLiteral(resourceName: "gold star "), for: .normal)
            }
            else{
                questionImageHeaderView?.isFavorited = false
                questionImageHeaderView?.favoriteButton.setImage(#imageLiteral(resourceName: "star blank"), for: .normal)
            }
            
        }else{
            questionHeaderView = UINib(nibName: "QuestionHeaderView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionHeaderView
            questionHeaderView?.question = Question(_creatorUID: question.creatorUID, _creatorUsername: question.creatorUsername, _postID: question.postID, _category: question.category, _time: question.time, _question: question.question, _numReplies: question.numReplies, _imageURL: question.imageURL)
            if(isFavorite){
                questionHeaderView?.isFavorited = true
                questionHeaderView?.favoriteButton.setImage(#imageLiteral(resourceName: "gold star "), for: .normal)
            }
            else{
                questionHeaderView?.isFavorited = false
                questionHeaderView?.favoriteButton.setImage(#imageLiteral(resourceName: "star blank"), for: .normal)
            }
        }
        
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
        
        var timeWord = "second"
        let secondsSinceEpoch = TimeInterval(_time.seconds)
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
        return "\(timeSince)" + " " + timeWord + " ago"
    }
    
    func fetchReplies(){
        replies.removeAll()
        
        let repliesCollection = Firestore.firestore().collection(NameFile.Firestore.posts).document(question.postID).collection(NameFile.Firestore.replies)
        
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
        
        let image = question.image
        if image != nil {
            if let text = questionImageHeaderView?.repliesLabel.text{
                if let numReplies = Int(text){
                    questionImageHeaderView?.repliesLabel.text = "\(numReplies+1)"
                }
            }
        }
        else {
            if let text = questionHeaderView?.repliesLabel.text{
                if let numReplies = Int(text){
                    questionHeaderView?.repliesLabel.text = "\(numReplies+1)"
                }
            }
        }
    }
    
    @objc func keyboardWillShow(notification: Notification) {
        let userInfo:NSDictionary = notification.userInfo! as NSDictionary
        let keyboardFrame:NSValue = userInfo.value(forKey: UIKeyboardFrameEndUserInfoKey) as! NSValue
        let keyboardRectangle = keyboardFrame.cgRectValue
        keyboardHeight = keyboardRectangle.height
        moveTextField(replyTextField, moveDistance: -keyboardHeight, up: true)
    }
    
    @objc func keyboardWillHide(notification: Notification) {
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
        _ = textFieldShouldReturn(replyTextField)
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
    
}
protocol ReplyCompletedDelegate{
    func completedReply()
}
extension ReplyViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There's nothing here!"
        let changes = [kCTFontAttributeName: UIFont(name: "Avenir Next", size: 24.0)!, kCTForegroundColorAttributeName: UIColor.flatGray]
        
        return NSAttributedString(string: str, attributes: changes as [NSAttributedStringKey : Any])
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Be the first reply for this post!"
        let attrs = [kCTFontAttributeName: UIFont(name: "Avenir Next", size: 18.0)!, kCTForegroundColorAttributeName: UIColor.flatGray]
        return NSAttributedString(string: str, attributes: attrs as [NSAttributedStringKey : Any])
    }
    
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }
    
}


