import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet
import GeoFire
import AsyncImageView


class QuestionsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    var geofireRef : DatabaseReference!
    var geoFire : GeoFire!
    var refresh = UIRefreshControl()
    private var questions = [Question]() {didSet{tableView.reloadData()}}
    var shouldPull = false
    override func viewDidLoad() {
        super.viewDidLoad()
        viewDidLoadSetup()
        print("setup done")
    }
    func viewDidLoadSetup(){
        locationSetup()
        firebaseSetup()
        refreshSetup()
        geoFireSetup()
        tableViewSetup()
      //  questionsSetup()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.requestLocation()
        locationSetup()
        questions.removeAll()
        
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
        if let _ = question.image{
            let cell = tableView.dequeueReusableCell(withIdentifier: "QuestionImageCell", for: indexPath)
            if let cell = cell as? QuestionImageCell{
                cell.question = question
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
    
    @objc private func fetchQuestions(){
        if(!questions.isEmpty){
            questions.removeAll()
        }
        let center = CLLocation(latitude: (currLocation?.latitude)!, longitude: (currLocation?.longitude)!)
        
        let locQuery = geoFire.query(at: center, withRadius: 6)
        locQuery.observe(.keyEntered, with: { (key, location) in
            print(key)
            let docRef = Firestore.firestore().collection(NameFile.Firestore.FirestorePosts)
            let postsCollection = docRef.document(key)
            postsCollection.getDocument { (document, error) in
                if let document = document, document.exists {
                    let creatorUID = document[NameFile.Firestore.creatorUID] as! String
                    let creatorUsername = document[NameFile.Firestore.creatorUsername] as! String
                    let postID = document.documentID
                    let pulledLat = document[NameFile.Firestore.postLatitude] as! Double
                    let pulledLong = document[NameFile.Firestore.postLongitude] as! Double
                    let category = document[NameFile.Firestore.postCategory] as! String
                    let time = document[NameFile.Firestore.postTime] as! Timestamp
                    let question = document[NameFile.Firestore.postQuestion] as! String
                    let imageURL = document[NameFile.Firestore.postImageURL] as? String
                    
                    let repliesCollection = Firestore.firestore().collection(NameFile.Firestore.FirestorePosts).document(postID).collection(NameFile.Firestore.replies)
                    repliesCollection.getDocuments(completion: { (snapshot, error) in
                        if let documents = snapshot?.documents{
                            //get images
                            let location = GeoPoint(latitude: pulledLat, longitude: pulledLong)
                            self.appendInOrder(_question: Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _location: location, _category: category, _time: time, _question: question, _numReplies: documents.count, _imageURL: URL(string: imageURL!)))
                            if let url = imageURL{
                                let imageRef = Storage.storage().reference(forURL: url)
                                imageRef.getData(maxSize: 100*1024*1024, completion: { (data, error) in
                                    if let data = data{
                                        if let image = UIImage(data: data){
                                            
                                        }
                                    }
                                })
                            }
                            else{
                                let location = GeoPoint(latitude: pulledLat, longitude: pulledLong)
                                self.appendInOrder(_question: Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _location: location, _category: category, _time: time, _question: question, _numReplies: documents.count))
                            }
                        }
                    })
                }
                else {
                    print("Document does not exist")
                }
            }
        })
        refresh.endRefreshing()
    }
    func appendInOrder(_question : Question){
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
            if identifier == "toReply" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let question = self.questions[indexPath!.row] as? Question
                let detail = segue.destination as! ReplyViewController
                detail.question = question!
                detail.hasImage = false
            }
            
            if identifier == "toReplyImage" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let question = self.questions[indexPath!.row] as? Question
                let image = question?.image
                let detail = segue.destination as! ReplyViewController
                detail.question = question!
                detail.hasImage = true
                detail.image = image!
            }
        }
    }
    func tableViewSetup(){
        self.tableView.backgroundColor = UIColor(hexString: "f2f2f2")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    func locationSetup(){
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self as CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
    }
    
    func refreshSetup(){
        refresh.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refresh.addTarget(self, action: #selector(QuestionsViewController.fetchQuestions), for: UIControlEvents.valueChanged)
        self.tableView.addSubview(refresh)
        
    }
    func geoFireSetup(){
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
    }
    func firebaseSetup(){
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
    }
    func questionsSetup(){
        fetchQuestions()
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
extension QuestionsViewController : CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Please enable location services in settings!")
        locationManager.requestLocation()
    }
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            locationManager.requestLocation()
        }
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0) {
            let location = locations.last
            currLocation = location?.coordinate
            print(currLocation)
            print("updating Loc")
            fetchQuestions()
        }
        else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Please enable location services in settings!")
        }
    }
    
}





