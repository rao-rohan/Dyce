import Foundation
import UIKit
import Firebase
import CoreLocation
import SVProgressHUD

class Question {
    
    var creatorUID: String
    var creatorUsername: String
    var creatorProfileImage: UIImage
    
    var postID: String
    var category: String
    var time: Timestamp
    var location : GeoPoint
    var question: String
    var numReplies: Int
    var image: UIImage?
    
    init(_creatorUID: String, _creatorUsername: String, _creatorProfileImage: UIImage = #imageLiteral(resourceName: "default"), _postID: String, _category: String, _time: Timestamp, _location: GeoPoint, _question: String, _numReplies: Int, _image: UIImage? = nil) {
        creatorUID = _creatorUID
        creatorUsername = _creatorUsername
        creatorProfileImage = _creatorProfileImage
        postID = _postID
        location = _location
        category = _category
        time = _time
        question = _question
        numReplies = _numReplies
        image = _image
    }
    
    init() {
        creatorUID = ""
        creatorUsername = ""
        creatorProfileImage = UIImage()
        postID = ""
        location = GeoPoint(latitude: 0, longitude: 0)
        category = ""
        time = Timestamp()
        question = ""
        numReplies = 0
        image = UIImage()
    }
    
    func pushToFirestore(){
        let postCollection: CollectionReference = Firestore.firestore().collection(NameFile.Firestore.posts)
        let imageStorage: StorageReference = Storage.storage().reference(withPath: NameFile.Firestore.images)
        
        if let image = image{
            imageStorage.child(NameFile.Firestore.images).putData(UIImagePNGRepresentation(image)!).observe(.success, handler: { (snapshot) in
                if let imageURL = snapshot.metadata?.downloadURL()?.absoluteString{
                    postCollection.document().setData([
                        NameFile.Firestore.creatorUID: self.creatorUID,
                        NameFile.Firestore.creatorUsername: self.creatorUsername,
                        NameFile.Firestore.postLongitude : self.location.longitude,
                        NameFile.Firestore.postLatitude : self.location.latitude,
                        NameFile.Firestore.postCategory: self.category,
                        NameFile.Firestore.postTime: self.time,
                        NameFile.Firestore.postQuestion: self.question,
                        NameFile.Firestore.postImageURL: imageURL
                        ])
                    SVProgressHUD.dismiss()
                }
            })
        }else{
            postCollection.document().setData([
                NameFile.Firestore.creatorUID: self.creatorUID,
                NameFile.Firestore.creatorUsername: self.creatorUsername,
                NameFile.Firestore.postLongitude : self.location.longitude,
                NameFile.Firestore.postLatitude : self.location.latitude,
                NameFile.Firestore.postCategory: self.category,
                NameFile.Firestore.postTime: self.time,
                NameFile.Firestore.postQuestion: self.question
                ])
            SVProgressHUD.dismiss()
        }
    }
    
}
