//
//  UserSelectedPostsTableViewController.swift
//  DyceAppIOS
//
//  Created by Rohan Rao on 6/11/18.
//  Copyright © 2018 NikhilandRohan. All rights reserved.
//
import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import GeoFire
import SVProgressHUD
import ESPullToRefresh

class UserSelectedPostsTableViewController: UITableViewController {
    
    var postType: UserPostType = .replies
    
    //model (backbone)
    private var questions = [Question]() {didSet{tableView.reloadData()}}
    private var selectedPosts = [String]() {didSet{tableView.reloadData()}}
    private var favoritedPosts = [String]() {didSet{tableView.reloadData()}}
    var userPostsCollection : CollectionReference!
    var userFavoritesCollection : CollectionReference!
    var userRepliesCollection : CollectionReference!
    var postsCollection : CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print(postType)
        setupTitle()
        self.tableView.backgroundColor = UIColor(hexString: "f2f2f2")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //inits pull to refresh capabilities
        self.tableView.es.addPullToRefresh {
            self.tableView.es.stopPullToRefresh()
            SVProgressHUD.show()
            self.getSelectedQuestions()
            self.getFavoritedPosts()
            self.fetchQuestions()
        }
        
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
        
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
        setupCollectionRef()
        
    }
    func setupCollectionRef(){
        userFavoritesCollection = Firestore.firestore().collection(NameFile.Firestore.users).document(AppStorage.PersonalInfo.uid).collection(NameFile.Firestore.userFavoritedPosts)
        userRepliesCollection = Firestore.firestore().collection(NameFile.Firestore.users).document(AppStorage.PersonalInfo.uid).collection(NameFile.Firestore.userRepliesCollection)
        userPostsCollection = Firestore.firestore().collection(NameFile.Firestore.users).document(AppStorage.PersonalInfo.uid).collection(NameFile.Firestore.userPosts)
        postsCollection = Firestore.firestore().collection(NameFile.Firestore.posts)
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //when the screen first appears, start updating location and fetch questions from the database
        SVProgressHUD.show()
        
        tableView.reloadData()
        getSelectedQuestions()
  
        print(selectedPosts)
    }
    
    func setupTitle(){
        switch postType{
        case .favorites:
            self.navigationController?.navigationBar.topItem?.title = "Post which you have favorited"
        case .favorites:
            self.navigationController?.navigationBar.topItem?.title = "Post which you have favorited"
        case .userPosts:
            self.navigationController?.navigationBar.topItem?.title = "Your Posts"
        default:
            self.navigationController?.navigationBar.topItem?.title = ""
            
        }
        
    }
    //MARK: - Tableview Delegate and Datasource
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return questions.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let question = questions[indexPath.row]
        if let imageURL = question.imageURL{
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionImageCell", for: indexPath)
            if let cell = cell as? QuestionImageCell{
                cell.question = question
                
                //async image loading so that the text appears first and then the images appear later
                if question.image == #imageLiteral(resourceName: "GrayRect"){
                    let imageRef = Storage.storage().reference(forURL: imageURL)
                    imageRef.getData(maxSize: 100*1024*1024, completion: { (data, error) in
                        if let data = data{
                            if let image = UIImage(data: data){
                                let q = cell.question
                                cell.question = Question(_creatorUID: q.creatorUID, _creatorUsername: q.creatorUsername, _postID: q.postID, _category: q.category, _time: q.time, _question: q.question, _numReplies: q.numReplies, _imageURL: q.imageURL, _image: image)
                                self.questions[indexPath.row] = Question(_creatorUID: q.creatorUID, _creatorUsername: q.creatorUsername, _postID: q.postID, _category: q.category, _time: q.time, _question: q.question, _numReplies: q.numReplies, _imageURL: q.imageURL, _image: image)
                                if self.favoritedPosts.contains(cell.question.postID){
                                    cell.isFavorited = true
                                    cell.favoriteButton.setImage(#imageLiteral(resourceName: "gold star "), for: .normal)
                                }
                                else{
                                    cell.isFavorited = false
                                    cell.favoriteButton.setImage(#imageLiteral(resourceName: "star blank"), for: .normal)
                                }
                            }
                            
                        }
                    })
                }
                
                return cell
            }
            
        }else{
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionCell", for: indexPath)
            if let cell = cell as? QuestionCell{
                cell.question = question
                if favoritedPosts.contains(cell.question.postID){
                    cell.isFavorited = true
                    cell.favoriteButton.setImage(#imageLiteral(resourceName: "gold star "), for: .normal)
                }
                else{
                    cell.isFavorited = false
                    cell.favoriteButton.setImage(#imageLiteral(resourceName: "star blank"), for: .normal)
                }
                
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func getSelectedQuestions(){
        selectedPosts.removeAll()
        getFavoritedPosts()
        switch postType {
        case .favorites:
            userFavoritesCollection.getDocuments{ (snapshot , error) in
                if let documents = snapshot?.documents{
                    for document in documents{
                        self.selectedPosts.append(document.documentID)
                        print(document.documentID)
                        
                    }
                    self.fetchQuestions()
                }
                
            }
        case .replies:
            userRepliesCollection.getDocuments{ (snapshot , error) in
                if let documents = snapshot?.documents{
                    for document in documents{
                        self.selectedPosts.append(document.documentID)
                    }
                    self.fetchQuestions()
                }
                
            }
        case .userPosts:
            userPostsCollection.getDocuments{ (snapshot , error) in
                if let documents = snapshot?.documents{
                    for document in documents{
                        self.selectedPosts.append(document.documentID)
                        print(document.documentID)
                    }
                    self.fetchQuestions()
                }
                
            }
            
        default:
            break
        }
    }
    func getFavoritedPosts(){
        userFavoritesCollection.getDocuments{ (snapshot , error) in
            if let documents = snapshot?.documents{
                for document in documents{
                    self.favoritedPosts.append(document.documentID)
                }
            }
            
        }
    }
    //fetches all the questions from the database
    @objc private func fetchQuestions(){
        questions.removeAll()
            for selectedPost in selectedPosts{
                let doc = postsCollection.document(selectedPost)
                doc.getDocument { (document, error) in
                    if let document = document, document.exists {
                        let creatorUID = document[NameFile.Firestore.creatorUID] as! String
                        let creatorUsername = document[NameFile.Firestore.creatorUsername] as! String
                        let postID = document.documentID
                        let category = document[NameFile.Firestore.postCategory] as! String
                        let time = document[NameFile.Firestore.postTime] as! Timestamp
                        let question = document[NameFile.Firestore.postQuestion] as! String
                        let imageURL = document[NameFile.Firestore.postImageURL] as? String
                        
                        //grabs the number of replies
                        let repliesCollection = Firestore.firestore().collection(NameFile.Firestore.posts).document(postID).collection(NameFile.Firestore.replies)
                        repliesCollection.getDocuments(completion: { (snapshot, error) in
                            if let documents = snapshot?.documents{
                                if let imageURL = imageURL{
                                    //adds the post to the backbone array
                                    self.appendInOrder(_question: Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _category: category, _time: time, _question: question, _numReplies: documents.count, _imageURL: imageURL, _image: #imageLiteral(resourceName: "GrayRect")))
                                }else{
                                    //adds the post to the backbone array
                                    self.appendInOrder(_question: Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _category: category, _time: time, _question: question, _numReplies: documents.count))
                                }
                            }
                        })
                    }
                }

                
            }
        SVProgressHUD.dismiss()
    }
    
    //adds questions to the backbone so that they appear in order
    func appendInOrder(_question : Question){
        _ = self.questions.filter { (pass) -> Bool in
            if pass.postID != _question.postID{
                return true
            }
            return false
        }
        for (index, question)  in questions.enumerated(){
            let secondsSinceEpochReply = TimeInterval(question.time.seconds)
            let timeAgoReply = NSDate().timeIntervalSince1970 - secondsSinceEpochReply
            let secondsSinceEpoch_Reply = TimeInterval(_question.time.seconds)
            let timeAgo_Reply = NSDate().timeIntervalSince1970 - secondsSinceEpoch_Reply
            if timeAgo_Reply < timeAgoReply{
                self.questions.insert(_question, at: index)
                return
            }
        }
        self.questions.append(_question)
    }
    
    func rotateImage(img: UIImage) -> UIImage{
        var rot = UIImage()
        switch img.imageOrientation
        {
        case .right:
            rot = UIImage(cgImage: img.cgImage!, scale: 1.0, orientation: .down)
            
        case .down:
            rot = UIImage(cgImage: img.cgImage!, scale: 1.0, orientation: .left)
            
        case .left:
            rot = UIImage(cgImage: img.cgImage!, scale: 1.0, orientation: .up)
            
        default:
            rot = UIImage(cgImage: img.cgImage!, scale: 1.0, orientation: .right)
        }
        
        return rot
    }
    
    //MARK: - Navigation
    
    
}

extension UserSelectedPostsTableViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There's nothing here!"
        let changes = [kCTFontAttributeName: UIFont(name: "Avenir Next", size: 24.0)!, kCTForegroundColorAttributeName: UIColor.flatGray]
        
        return NSAttributedString(string: str, attributes: changes as [NSAttributedStringKey : Any])
    }
    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }
    

}





