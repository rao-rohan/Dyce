import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import GeoFire
import SVProgressHUD
import ESPullToRefresh

//this view controller operates with an array of Question objects to display

class QuestionsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, PushCompletedDelegate{

    var currLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    var geofireRef : DatabaseReference!
    var geoFire : GeoFire!
    
    private var questions = [Question]() {didSet{tableView.reloadData()}}
    
    private var needsToFetchQuestions = false
    
    var locationQueryHandle: DatabaseHandle = 0
    var locQuery: GFCircleQuery?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
        
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
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
            }else{
                self.needsToFetchQuestions = true
            }
        }
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        }
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        if let _ = currLocation{
            SVProgressHUD.show()
            fetchQuestions()
        }else{
            needsToFetchQuestions = true
        }
    }
    
    @IBAction func unwindToQuestionsViewController(_ segue: UIStoryboardSegue) {
    }
    
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
                return cell
            }
        }
        return UITableViewCell()
    }
    
    func completedPush() {
        if let _ = currLocation{
            SVProgressHUD.show()
            fetchQuestions()
        }else{
            needsToFetchQuestions = true
        }
    }
    
    //fetches all the questions from the database
    @objc private func fetchQuestions(){
        questions.removeAll()
        
        //creates a location query of posts to fetch
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
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if let identifier = segue.identifier {
            
            if identifier == "questionDetail" || identifier == "questionImageDetail" {
                if let indexPath = self.tableView.indexPathForSelectedRow{
                    let question = self.questions[indexPath.row]
                    if let detailVC = segue.destination as? ReplyViewController{
                        detailVC.question = question
                    }
                }
            }
            
            if identifier == "newQuestion"{
                if let newVC = segue.destination as? NewPostViewController{
                    newVC.delegate = self
                }
            }
            
        }
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

extension QuestionsViewController : CLLocationManagerDelegate {
    
    //every time the location is updated, this method is called, and the posts are re-fetched
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if(locations.count > 0) {
            let location = locations.last
            currLocation = location?.coordinate
            if needsToFetchQuestions == true{
                needsToFetchQuestions = false
                SVProgressHUD.show()
                fetchQuestions()
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





