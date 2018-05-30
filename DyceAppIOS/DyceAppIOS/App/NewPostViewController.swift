import Foundation
import ChameleonFramework
import SVProgressHUD
import SCLAlertView
import Firebase
import CoreLocation

//this view controller displays the template for the user to post a new question

class NewPostViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextViewDelegate {

    @IBOutlet weak var ImagePlace: UIImageView!
    @IBOutlet weak var placeHolderText: UILabel!
    @IBOutlet weak var postTextView: UITextView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var categoryButton: UIButton!
    
    var image: UIImage?
    var locationExists: Bool = false
    var selectedCategory: String?
    var currLocation: CLLocationCoordinate2D?
    var reset: Bool = false
    let locationManager = CLLocationManager()
    var imagePickerController: UIImagePickerController?
    var toolbar: UIToolbar!
    var time : Timestamp!
    
    var delegate: PushCompletedDelegate?
    
    private var deleteCategory = true
    
    override var prefersStatusBarHidden : Bool {
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        postTextView.sizeToFit()
        postTextView.layoutIfNeeded()
        postTextView.delegate = self
        
        nameLabel.text = AppStorage.PersonalInfo.username
        
        categoryButton.titleLabel?.textAlignment = NSTextAlignment.center
        
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.delegate = self
        locationManager.requestWhenInUseAuthorization()
        
        if(locationManager.location != nil) {
            locationExists = true
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if deleteCategory{
            AppStorage.Questions.category = nil
            AppStorage.save()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        locationManager.startUpdatingLocation()
        deleteCategory = true
        AppStorage.load()
        if let category = AppStorage.Questions.category{
            categoryButton.titleLabel?.text = category
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    func textViewDidChange(_ textView: UITextView) {
        UIView.animate(withDuration: 0.05) {
            self.placeHolderText.alpha = textView.text.isEmpty ? 1 : 0
        }
    }
    override var inputAccessoryView: UIView? {
        toolbar = UIToolbar()
        toolbar.isTranslucent = false
        toolbar.tintColor = UIColor.flatBlack
        let cameraButton = UIBarButtonItem(image: UIImage(named: "camera"), style: .plain, target: self, action: #selector(NewPostViewController.chooseImageSource))
        cameraButton.tintColor = UIColor.flatGray
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let postButton = UIBarButtonItem(title: "POST", style: .plain, target: self, action: #selector(NewPostViewController.uploadPost))
        postButton.setTitleTextAttributes([NSAttributedStringKey.font: UIFont(name: "Avenir", size: 10.0)!, NSAttributedStringKey.foregroundColor: UIColor.flatGray], for: .normal)
        toolbar.items = [cameraButton, space, postButton]
        toolbar.sizeToFit()
        return toolbar
    }
    
    @objc func uploadPost(){
        let question = Question()
        
        var hasError = false
        let alert = SCLAlertView()
        
        time = Timestamp()

        if selectedCategory != nil {
            question.category = selectedCategory!
        } else {
            alert.showError("Error", subTitle: "Please select a category")
            hasError = true
        }

        if(postTextView.text != "") {
            question.question = postTextView.text
        } else {
            alert.showError("Error", subTitle: "You haven't written a question!")
            hasError = true
        }

        if(locationExists == true) {
            question.location = GeoPoint(latitude: currLocation!.latitude, longitude: currLocation!.longitude)
        } else {
            alert.showError("Error", subTitle: "Couldn't get location!")
        }
        
        if let image = image {
            question.image = image
        }
        
        question.time = time
        question.creatorUID = AppStorage.PersonalInfo.uid
        question.creatorUsername = AppStorage.PersonalInfo.username
        
        if(hasError == false) {
            SVProgressHUD.show()
            question.pushToFirestore {
                self.delegate?.completedPush()
            }
            AppStorage.Questions.category = nil
            AppStorage.save()
            performSegue(withIdentifier: "backtoFeed", sender: nil)
        }
    }
    
    @IBAction func pressCategoryButton(_ sender: AnyObject) {
        let alertView = SCLAlertView()
        
        if(postTextView.isFirstResponder) {
            postTextView.resignFirstResponder()
        }

        alertView.addButton("Travel", backgroundColor: UIColor.flatRed, textColor: UIColor.white) {
            self.selectedCategory = "Travel"
            
            self.categoryButton.backgroundColor = UIColor.flatRed
            self.categoryButton.titleLabel?.text = "Travel"
            
            AppStorage.Questions.category = "Travel"
            AppStorage.save()
        }
        
        alertView.addButton("Entertainment", backgroundColor: UIColor.flatOrange) {
            self.selectedCategory = "Entertainment"
            
            self.categoryButton.backgroundColor = UIColor.flatYellow
            self.categoryButton.titleLabel?.text = "Entertainment"
            
            AppStorage.Questions.category = "Entertainment"
            AppStorage.save()
        }
        
        alertView.addButton("Meetup", backgroundColor: UIColor.flatYellow, textColor: UIColor.white) {
            self.selectedCategory = "Meetup"
            
            self.categoryButton.backgroundColor = UIColor.flatYellow
            self.categoryButton.titleLabel?.text = "Meetup"
            
            AppStorage.Questions.category = "Meetup"
            AppStorage.save()
        }
        
        alertView.addButton("Listings", backgroundColor: UIColor.flatGreen, textColor: UIColor.white) {
            self.selectedCategory = "Listings"
            
            self.categoryButton.backgroundColor = UIColor.flatGreen
            self.categoryButton.titleLabel?.text = "Listings"
            
            AppStorage.Questions.category = "Listings"
            AppStorage.save()
        }
        
        alertView.addButton("Recommendations", backgroundColor: UIColor.flatSkyBlue, textColor: UIColor.white) {
            self.selectedCategory = "Recommendations"
            
            self.categoryButton.backgroundColor = UIColor.flatSkyBlue
            self.categoryButton.titleLabel?.text = "Recommendations"
            
            AppStorage.Questions.category = "Recommendations"
            AppStorage.save()
        }
        alertView.addButton("Other", backgroundColor: UIColor.flatMagenta, textColor: UIColor.white) {
            self.selectedCategory = "Other"
            
            self.categoryButton.backgroundColor = UIColor.flatMagenta
            self.categoryButton.titleLabel?.text = "Other"
            
            AppStorage.Questions.category = "Other"
            AppStorage.save()
        }
        
        alertView.showNotice("Categories", subTitle: "")
    }
    
    
    @objc func chooseImageSource() {
        postTextView.resignFirstResponder()

        let alertController = UIAlertController(title: nil, message: "Where do you want to get your picture from?", preferredStyle: .actionSheet)
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(cancelAction)
        
        let photoLibraryAction = UIAlertAction(title: "Photo from Library", style: .default) { (action) in
            self.deleteCategory = false
            self.showImagePickerController(.photoLibrary)
        }
        
        alertController.addAction(photoLibraryAction)
        
        if (UIImagePickerController.isCameraDeviceAvailable(.rear)) {
            let cameraAction = UIAlertAction(title: "Photo from Camera", style: .default) { (action) in
                self.deleteCategory = false
                self.showImagePickerController(.camera)
            }
            alertController.addAction(cameraAction)
        }
        present(alertController, animated: true, completion: nil)
        toolbar.isHidden = false
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage {
            image = pickedImage
            ImagePlace.image = pickedImage

        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func showImagePickerController(_ sourceType: UIImagePickerControllerSourceType) {
        imagePickerController = UIImagePickerController()
        imagePickerController!.sourceType = sourceType
        imagePickerController!.delegate = self
        
        present(imagePickerController!, animated: true, completion: nil)
    }

}

protocol PushCompletedDelegate{
    func completedPush()
}


//MARK: TextView Methods

extension NewPostViewController {
    func alert(_ message: String) {
        let alert = UIAlertController(title: "We couldn't fetch your location.", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertActionStyle.cancel, handler: nil)
        let settings = UIAlertAction(title: "Settings", style: UIAlertActionStyle.default) { (action) -> Void in
            UIApplication.shared.open(URL(string: UIApplicationOpenSettingsURLString)!, options: [:], completionHandler: nil)
            return
        }
        alert.addAction(settings)
        alert.addAction(cancel)
        self.present(alert, animated: true, completion: nil)
    }
}

extension NewPostViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        locationManager.stopUpdatingLocation()
        if(locations.count > 0){
            let location = locations[0]
            currLocation = location.coordinate
        } else {
            print("cant get location")
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
        let alert = SCLAlertView()
        alert.showError("Error", subTitle: "Please enable location services in settings!")
    }
}
