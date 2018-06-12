//
//  QuestionHeaderView.swift
//  Questions
//
//  Created by Rohan Rao on 10/10/17.
//  Copyright © 2017 Rohan Rao. All rights reserved.
//

import UIKit

import Firebase
class QuestionImageHeaderView: UITableViewHeaderFooterView {
//
//    @IBOutlet weak var imageView: UIImageView!
//    @IBOutlet weak var questionLabel: UILabel!
//    @IBOutlet weak var usernameLabel: UILabel!
//    @IBOutlet weak var timeLabel: UILabel!
//    @IBOutlet weak var categoryView: UIView!
//    @IBOutlet weak var categoryLabel: UILabel!
//    @IBOutlet weak var repliesLabel: UILabel!
//    @IBOutlet weak var favoriteButton: UIButton!
//    var isFavorited = false
//        var posterUID: String = ""
//    @IBAction func favoritePressed(_ sender: Any) {
//        let userCollection : CollectionReference = Firestore.firestore().collection(NameFile.Firestore.users).document(AppStorage.PersonalInfo.uid).collection(NameFile.Firestore.userFavoritedPosts)
//        if(!isFavorited){
//            favoriteButton.setImage(#imageLiteral(resourceName: "gold star "), for: .normal)
//            userCollection.document(question.postID).setData(["postID" : question.postID])
//            isFavorited = true
//        }
//        else{
//            favoriteButton.setImage(#imageLiteral(resourceName: "star blank"), for: .normal)
//            userCollection.document(question.postID).delete()
//            isFavorited = false
//        }
//    }
    let colorPicker = CategoryHelper()
    @IBOutlet weak var questionLabel: UILabel!
    @IBOutlet weak var timeLabel: UILabel!
    @IBOutlet weak var repliesLabel: UILabel!
    @IBOutlet weak var usernameLabel: UIButton!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var categoryView: UIView!
    @IBOutlet weak var categoryLabel: UILabel!
    @IBOutlet weak var favoriteButton: UIButton!
    var isFavorited = false
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
        imageView.image = question.image
        categoryLabel.text = question.category
        categoryView.backgroundColor = colorPicker.colorChooser(question.category)
        
    }
    @IBAction func favoritePressed(_ sender: Any) {
        let userCollection : CollectionReference = Firestore.firestore().collection(NameFile.Firestore.users).document(AppStorage.PersonalInfo.uid).collection(NameFile.Firestore.userFavoritedPosts)
        if(!isFavorited){
            favoriteButton.setImage(#imageLiteral(resourceName: "gold star "), for: .normal)
            userCollection.document(question.postID).setData([NameFile.Firestore.userFavPostID : question.postID])
            isFavorited = true
        }
        else{
            favoriteButton.setImage(#imageLiteral(resourceName: "star blank"), for: .normal)
            userCollection.document(question.postID).delete()
            isFavorited = false
        }
    }
}
