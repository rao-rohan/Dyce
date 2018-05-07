import UIKit
import Foundation
import CoreLocation
import Firebase
import SCLAlertView
import DZNEmptyDataSet

class QuestionsViewController: UITableViewController, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    override var prefersStatusBarHidden : Bool {
        return false
    }
    
    var currLocation: CLLocationCoordinate2D?
    let locationManager = CLLocationManager()
    
    private var questions = [Question]() {didSet{tableView.reloadData()}}
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        UIApplication.shared.statusBarStyle = .lightContent
        
        _ = Timer.scheduledTimer(timeInterval: 120.0, target: self, selector: #selector(QuestionsViewController.fetchPosts), userInfo: nil, repeats: true)
        
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
        
        tableView.tableFooterView = UIView()
    }
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return UIStatusBarStyle.lightContent
    }
    
    @IBAction func unwindToQuestionsViewController(_ segue: UIStoryboardSegue) {
    }
    
    //MARK: Table View Methods
    
    
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
    //MARK: Query for location
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0) {
            let location = locations[locations.count - 1]
            currLocation = location.coordinate
            fetchPosts()
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
    
    
    @objc private func fetchPosts(){
        questions.removeAll()
        let postsCollection = Firestore.firestore().collection(NameFile.Firestore.posts)
        postsCollection.getDocuments { (snapshot, error) in
            if let documents = snapshot?.documents{
                for document in documents{
                    let creatorUID = document[NameFile.Firestore.creatorUID] as! String
                    let creatorUsername = document[NameFile.Firestore.creatorUsername] as! String
                    let postID = document.documentID
                    let location = document[NameFile.Firestore.postLocation] as! GeoPoint
                    let category = document[NameFile.Firestore.postCategory] as! String
                    let time = document[NameFile.Firestore.postTime] as! String
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
                    })
                }
            }
        }
    }
    
}

/*extension QuestionsViewController: DZNEmptyDataSetSource, DZNEmptyDataSetDelegate {
    //MARK: Empty Data Set
    func title(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "There's nothing here!"
        let changes = [kCTFontAttributeName: UIFont(name: "ProximaNova-Bold", size: 24.0)!, NSForegroundColorAttributeName: UIColor.flatGray()] as [String : Any]
        
        return NSAttributedString(string: str, attributes: changes)
    }
    
    func description(forEmptyDataSet scrollView: UIScrollView!) -> NSAttributedString! {
        let str = "Enable location services or be the first poster in your area!"
        let attrs = [kCTFontAttributeName: UIFont(name: "ProximaNova-Semibold", size: 18.0)!, NSForegroundColorAttributeName: UIColor.flatGray()] as [String : Any]
        return NSAttributedString(string: str, attributes: attrs)
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
}*/
