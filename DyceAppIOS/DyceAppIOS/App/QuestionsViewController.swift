import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet

class QuestionsViewController: UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
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
        
        self.locationManager.requestAlwaysAuthorization()
        self.locationManager.requestWhenInUseAuthorization()
        
        if (CLLocationManager.locationServicesEnabled()) {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
        
        tableView.tableFooterView = UIView(frame: CGRect.zero)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
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
    
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0) {
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            fetchQuestions()
        }
        else {
            let alert = SCLAlertView()
            alert.showError("Error", subTitle: "Please enable location services in settings!")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Please enable location services in settings!")
    }
    
    
    @objc private func fetchQuestions(){
        questions.removeAll()
        print("called")
        let postsCollection = Firestore.firestore().collection(NameFile.Firestore.posts)
        postsCollection.getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents{
                for document in documents{
                    
                    let creatorUID = document[NameFile.Firestore.creatorUID] as! String
                    let creatorUsername = document[NameFile.Firestore.creatorUsername] as! String
                    let postID = document.documentID
                    let location = document[NameFile.Firestore.postLocation] as! GeoPoint
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
                                            self.questions.append(Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _location: location, _category: category, _time: time, _question: question, _numReplies: documents.count, _image: image))
                                        }
                                    }
                                })
                            }else{
                                self.questions.append(Question(_creatorUID: creatorUID, _creatorUsername: creatorUsername, _postID: postID, _location: location, _category: category, _time: time, _question: question, _numReplies: documents.count))
                            }
                        }
//                        for question in self.questions{
//                            print(question.time)
//                        }
                    })
                    
                }
            }
            
        }
        print("here11111")
        self.questions.sort(by: { $0.time.seconds > $1.time.seconds})
        for question in self.questions{
            print(question.time)
        }
        
    }
    
}
