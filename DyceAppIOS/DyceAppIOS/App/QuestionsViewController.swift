import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet

class QuestionsViewController: UITableViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var currLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    private var questions = [Question]() {didSet{tableView.reloadData()}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        self.tableView.backgroundColor = UIColor(hexString: "f2f2f2")
        tableView.estimatedRowHeight = 200
        tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self as! CLLocationManagerDelegate
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.requestLocation()
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.locationManager.requestLocation()
        fetchQuestions()
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
        questions.removeAll()
        print("called")
        if  (currLocation?.latitude) != nil {
            let latitude = (currLocation?.latitude)!
            let longitude = (currLocation?.longitude)!
            let lat = 0.0144927536231884 * 5
            let lon = 0.0181818181818182 * 5
            let lowerLat = latitude - (lat)
            let lowerLon = longitude - (lon)
            
            let greaterLat = latitude + (lat)
            let greaterLon = longitude + (lon)
        
            
            let docRef = Firestore.firestore().collection(NameFile.Firestore.posts)
            let postsCollection = docRef
                .whereField(NameFile.Firestore.postLongitude, isGreaterThanOrEqualTo: lowerLon)
                .whereField(NameFile.Firestore.postLongitude, isLessThanOrEqualTo : greaterLon)
                .whereField(NameFile.Firestore.postLatitude, isGreaterThanOrEqualTo: lowerLat)
                .whereField(NameFile.Firestore.postLatitude, isLessThanOrEqualTo : greaterLat)
            postsCollection.getDocuments { (snapshot, error) in
                if let documents = snapshot?.documents{
                    for document in documents{
                        let creatorUID = document[NameFile.Firestore.creatorUID] as! String
                        let creatorUsername = document[NameFile.Firestore.creatorUsername] as! String
                        let postID = document.documentID
                        //let location = document[NameFile.Firestore.postLocation] as! GeoPoint
                        let pulledLat = document[NameFile.Firestore.postLatitude] as! Double
                        let pulledLong = document[NameFile.Firestore.postLongitude] as! Double
                        let category = document[NameFile.Firestore.postCategory] as! String
                        let time = document[NameFile.Firestore.postTime] as! Timestamp
                        let question = document[NameFile.Firestore.postQuestion] as! String
                        let imageURL = document[NameFile.Firestore.postImageURL] as? String
                        
                        let repliesCollection = Firestore.firestore().collection(NameFile.Firestore.posts).document(postID).collection(NameFile.Firestore.replies)
                        repliesCollection.getDocuments(completion: { (snapshot, error) in
                            if let documents = snapshot?.documents{
                                //get images
                                if let url = imageURL{
                                    let imageRef = Storage.storage().reference(forURL: url)
                                    imageRef.getData(maxSize: 100*1024*1024, completion: { (data, error) in
                                        if let data = data{
                                            if let image = UIImage(data: data){
                                                let location = GeoPoint(latitude: pulledLat, longitude: pulledLong)
                                                self.appendInOrder(_question: Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _location: location, _category: category, _time: time, _question: question, _numReplies: documents.count, _image: image))
                                            }
                                        }
                                    })
                                }else{
                                    let location = GeoPoint(latitude: pulledLat, longitude: pulledLong)
                                    self.appendInOrder(_question: Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _location: location, _category: category, _time: time, _question: question, _numReplies: documents.count))
                                }
                            }
                        })
                        
                    }
                    //                }
                }
                //
            }
        }
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
            if identifier == "questionDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let question = self.questions[indexPath!.row] as? Question
                let detail = segue.destination as! ReplyContainerViewController
                detail.question = question!
            }
            
            if identifier == "questionImageDetail" {
                let indexPath = self.tableView.indexPathForSelectedRow
                let question = self.questions[indexPath!.row] as? Question
                let detail = segue.destination as! ReplyContainerViewController
                detail.question = question!
            }
        }
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
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            print(currLocation)
            fetchQuestions()
        }
        else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Please enable location services in settings!")
        }
    }
    
}





