import Foundation
import UIKit
import Firebase
import CoreLocation
import SVProgressHUD
import GeoFire

//this functions as a Question object which stores necessary information pertaining to a particular question
//asked by a certain user

class Question {
    
    public typealias Block = () -> Void
    
    var geofireRef : DatabaseReference!
    var geoFire : GeoFire!
    var time: Timestamp
    var location : GeoPoint
    var creatorUID: String
    var creatorUsername: String
    var postID: String
    var category: String
    var question: String
    var numReplies: Int
    var imageURL: String?
    var image: UIImage?
    
    init(_creatorUID: String, _creatorUsername: String, _postID: String, _category: String, _time: Timestamp, _question: String, _numReplies: Int, _imageURL: String? = nil, _image: UIImage? = nil) {
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
        time = _time
        location = GeoPoint(latitude: 0, longitude: 0)
        creatorUID = _creatorUID
        creatorUsername = _creatorUsername
        postID = _postID
        category = _category
        question = _question
        numReplies = _numReplies
        imageURL = _imageURL
        image = _image
    }
    
    //default init
    init() {
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
        time = Timestamp(date: Date(timeIntervalSinceNow: 0))
        location = GeoPoint(latitude: 0, longitude: 0)
        creatorUID = ""
        creatorUsername = ""
        postID = ""
        category = ""
        question = ""
        numReplies = 0
        imageURL = nil
        image = nil
    }
    
    func pushToFirestore(completion: Block? = nil){
        let postCollection: CollectionReference = Firestore.firestore().collection(NameFile.Firestore.posts)
        let imageStorage: StorageReference = Storage.storage().reference(withPath: NameFile.Firestore.images)
        
        let newDocument = postCollection.document()
        geoFire.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), forKey: newDocument.documentID)
        if let image = image{
            imageStorage.child(newDocument.documentID).putData(UIImagePNGRepresentation(image)!).observe(.success, handler: { (snapshot) in
                imageStorage.child(newDocument.documentID).downloadURL(completion: { (url, error) in
                    if error != nil{
                        print(error?.localizedDescription ?? "")
                    }else{
                        if let imageURL = url?.absoluteString{
                            newDocument.setData([
                                NameFile.Firestore.creatorUID: self.creatorUID,
                                NameFile.Firestore.creatorUsername: self.creatorUsername,
                                NameFile.Firestore.postCategory: self.category,
                                NameFile.Firestore.postTime: self.time,
                                NameFile.Firestore.postQuestion: self.question,
                                NameFile.Firestore.postImageURL: imageURL
                                ])
                            SVProgressHUD.dismiss()
                            completion?()
                        }
                    }
                })
            })
        }else{
            newDocument.setData([
                NameFile.Firestore.creatorUID: self.creatorUID,
                NameFile.Firestore.creatorUsername: self.creatorUsername,
                NameFile.Firestore.postCategory: self.category,
                NameFile.Firestore.postTime: self.time,
                NameFile.Firestore.postQuestion: self.question
                ])
            SVProgressHUD.dismiss()
            completion?()
        }
    }
    
}
