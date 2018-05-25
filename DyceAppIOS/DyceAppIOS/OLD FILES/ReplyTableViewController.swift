//
//  DetailViewController.swift
//  Questions
//
//  Created by Rohan Rao on 10/08/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import Foundation
import UIKit
import Firebase

class ReplyTableViewController: UITableViewController {
    
    var question = Question()
    var numReplies: Int?
    private var replies = [Reply]() {didSet{tableView.reloadData()}}
    var questionHeaderView: QuestionHeaderView?
    var questionImageHeaderView: QuestionImageHeaderView?
    let colorPicker = CategoryHelper()
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.separatorStyle = .none
        tableView.estimatedRowHeight = 100.0
        tableView.rowHeight = UITableViewAutomaticDimension
        let image = question.image
        if let imageCheck = image {
            
            questionImageHeaderView = UINib(nibName: "QuestionHeaderImageView", bundle: Bundle.main).instantiate(withOwner: nil, options: nil).first as? QuestionImageHeaderView
            questionImageHeaderView?.posterUID = question.creatorUID
            questionImageHeaderView?.usernameLabel.text = question.creatorUsername
            questionImageHeaderView?.questionLabel.text = question.question
            questionImageHeaderView?.categoryLabel.text = question.category
            questionImageHeaderView?.timeLabel.text = convertTime(_time: question.time)
            questionImageHeaderView?.imageView.clipsToBounds = true
            questionImageHeaderView?.categoryView.backgroundColor = colorPicker.colorChooser(question.category)
            questionImageHeaderView?.categoryLabel.text = question.category
            questionImageHeaderView?.imageView.image = question.image
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
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if(questionHeaderView != nil) {
            return questionHeaderView
        }
        return questionImageHeaderView
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(questionHeaderView != nil) {
            return 224.0
        }
        return 360.0
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let reply = replies[indexPath.row]
            let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath)
            if let cell = cell as? ReplyCell{
                cell.reply = reply
                return cell
        }
        return UITableViewCell()
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return replies.count
    }
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
//    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath, object: PFObject?) -> UITableViewCell? {
//        let cell = tableView.dequeueReusableCell(withIdentifier: "replyCell", for: indexPath) as! ReplyCell
//        cell.replyProfilePic.layer.cornerRadius = cell.replyProfilePic.frame.height/2
//        cell.replyProfilePic.clipsToBounds = true
//        cell.postTime.text = (object!.createdAt as NSDate?)?.shortTimeAgo(since: Date())
//        cell.replyText.text = object!.value(forKey: "reply") as? String
//        let user = object!.value(forKey: "fromUser") as? PFUser
//        cell.usernameLabel.text = user?.username
//        return cell
//    }
}
