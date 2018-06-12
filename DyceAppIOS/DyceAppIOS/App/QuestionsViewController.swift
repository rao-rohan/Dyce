// Names: Nikhil Sridhar and Rohan Rao
//
// File Name: QuestionsViewController.swift
//
// File Description: This view controller operates with an array of Question objects to display.

import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import GeoFire
import SVProgressHUD
import ESPullToRefresh

class QuestionsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PushCompletedDelegate , ReplyCompletedDelegate{
    
    //these objects manage your location
    var currLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var geofireRef : DatabaseReference!
    var geoFire : GeoFire!
    
    //model (backbone)
    private var questions = [Question]() {didSet{tableView.reloadData()}}
    private var favoritedQuestions = [String]() {didSet{tableView.reloadData()}}
    private var needsToFetchQuestions = false
    
    var locationQueryHandle: DatabaseHandle = 0
    var locQuery: GFCircleQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
        
        self.tableView.backgroundColor = UIColor(hexString: "f2f2f2")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        //inits pull to refresh capabilities
        self.tableView.es.addPullToRefresh {
            self.tableView.es.stopPullToRefresh()
            if let _ = self.currLocation{
                SVProgressHUD.show()
                self.fetchQuestions()
                self.getFavorites()
            }else{
                self.needsToFetchQuestions = true
            }
        }

        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        locationManager.requestWhenInUseAuthorization()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
       
//
        tableView.emptyDataSetSource = self
        tableView.emptyDataSetDelegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //when the screen first appears, start updating location and fetch questions from the database
        locationManager.startUpdatingLocation()
        if let _ = currLocation{
            SVProgressHUD.show()
            fetchQuestions()
            tableView.reloadData()
            getFavorites()
        }else{
            needsToFetchQuestions = true
        }
    }
    
    @IBAction func unwindToQuestionsViewController(_ segue: UIStoryboardSegue) {
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
                                if self.favoritedQuestions.contains(cell.question.postID){
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
                if favoritedQuestions.contains(cell.question.postID){
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
    
    //MARK: - CompletedPushDelegate
    
    func completedPush() {
        if let _ = currLocation{
            SVProgressHUD.show()
            fetchQuestions()
        }else{
            needsToFetchQuestions = true
        }
    }
    func completedReply() {
        getFavorites()
    }
    func getFavorites(){
        favoritedQuestions.removeAll()
        let userFavoritesCollections : CollectionReference = Firestore.firestore().collection(NameFile.Firestore.users).document(AppStorage.PersonalInfo.uid).collection(NameFile.Firestore.userFavoritedPosts)
        userFavoritesCollections.getDocuments{ (snapshot , error) in
            if let documents = snapshot?.documents{
                for document in documents{
                    self.favoritedQuestions.append(document.documentID)
                }
            }
            
        }
        
    }
    //fetches all the questions from the database
    @objc private func fetchQuestions(){
        questions.removeAll()
        
        //creates a location query (by radius) of posts to fetch
        let center = CLLocation(latitude: (currLocation?.latitude)!, longitude: (currLocation?.longitude)!)
        locQuery = geoFire.query(at: center, withRadius: 6)
        locQuery?.observeReady {
            SVProgressHUD.dismiss()
            self.locQuery?.removeAllObservers()
        }
        locationQueryHandle = locQuery!.observe(.keyEntered, with: { (key, location) in
            
            let docRef = Firestore.firestore().collection(NameFile.Firestore.posts)
            let postsCollection = docRef.document(key)
            
            //grabs each post
            postsCollection.getDocument { (document, error) in
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
        })
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "questionDetail" {
                if let indexPath = self.tableView.indexPathForSelectedRow{
                    let question = self.questions[indexPath.row]
                    if let detailVC = segue.destination as? ReplyViewController{
                        detailVC.question = question
                        let cell = tableView.cellForRow(at: indexPath) as! QuestionCell
                        detailVC.isFavorite = cell.isFavorited
                        
                    }
                }
            }
            if identifier == "questionImageDetail" {
                if let indexPath = self.tableView.indexPathForSelectedRow{
                    let question = self.questions[indexPath.row]
                    if let detailVC = segue.destination as? ReplyViewController{
                        detailVC.question = question
                        let cell = tableView.cellForRow(at: indexPath) as! QuestionImageCell
                        detailVC.isFavorite = cell.isFavorited
                        
                    }
                }
            }
            
            //if the segue is destined for the new question view controller, set its delegate
            if identifier == "newQuestion"{
                if let newVC = segue.destination as? NewPostViewController{
                    newVC.delegate = self
                }
            }
            
        }
    }
    
}

public extension UIImage {
    public convenience init?(color: UIColor, size: CGSize = CGSize(width: 1, height: 1)) {
        let rect = CGRect(origin: .zero, size: size)
        UIGraphicsBeginImageContextWithOptions(rect.size, false, 0.0)
        color.setFill()
        UIRectFill(rect)
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        guard let cgImage = image?.cgImage else { return nil }
        self.init(cgImage: cgImage)
    }
}
extension QuestionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There's nothing here!"
        let changes = [kCTFontAttributeName: UIFont(name: "Avenir Next", size: 24.0)!, kCTForegroundColorAttributeName: UIColor.flatGray]

        return NSAttributedString(string: str, attributes: changes as [NSAttributedStringKey : Any])
    }

    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Enable location services or be the first poster in your area!"
        let attrs = [kCTFontAttributeName: UIFont(name: "Avenir Next", size: 18.0)!, kCTForegroundColorAttributeName: UIColor.flatGray]
        return NSAttributedString(string: str, attributes: attrs as [NSAttributedStringKey : Any])
    }

    func image(forEmptyDataSet scrollView: UIScrollView!) -> UIImage! {
        return UIImage(named: "exclamation_mark_filled")
    }

    func buttonImage(forEmptyDataSet scrollView: UIScrollView!, for state: UIControlState) -> UIImage! {
        return UIImage(named: "newquestionbutton")
    }

    func emptyDataSetDidTapButton(_ scrollView: UIScrollView!) {
        performSegue(withIdentifier: "newQuestion", sender: self)
    }
}

extension QuestionsViewController : CLLocationManagerDelegate {
    
    //every time the location is updated, re-fetch the questions
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.count > 0) {
            let location = locations.last
            currLocation = location?.coordinate
            if needsToFetchQuestions == true{
                needsToFetchQuestions = false
                SVProgressHUD.show()
                fetchQuestions()
                getFavorites()
            }
        }
        else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Please enable location services in settings!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error.localizedDescription)
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Please enable location services in settings!")
    }
    
}





