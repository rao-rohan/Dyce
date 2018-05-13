import Foundation
import UIKit
import Firebase
import CoreLocation
import SVProgressHUD
import GeoFire
class Question {
    var geofireRef : DatabaseReference!
    var geoFire : GeoFire!
    var creatorUID: String
    var creatorUsername: String
    var postID: String
    //var location: GeoPoint
    var category: String
    var time: Timestamp
    var location : GeoPoint
    var question: String
    var numReplies: Int
    var image: UIImage?
    
    init(_creatorUID: String, _creatorUsername: String, _postID: String, _location : GeoPoint , _category: String, _time: Timestamp, _question: String, _numReplies: Int, _image: UIImage? = nil) {
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
        creatorUID = _creatorUID
        creatorUsername = _creatorUsername
        postID = _postID
        location = _location
        category = _category
        time = _time
        question = _question
        numReplies = _numReplies
        image = _image
    }
    
    init() {
        geofireRef = Database.database().reference()
        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDB.RTDBPosts))
        creatorUID = ""
        creatorUsername = ""
        postID = ""
        location = GeoPoint(latitude: 0.0, longitude: 0.0)
        // longitude = 0
        //  latitude = 0
        category = ""
        time = Timestamp(date: Date(timeIntervalSinceNow: 0))
        question = ""
        numReplies = 0
        image = nil
    }
    
    func pushToFirestore(finished: @escaping () -> Void){
        //firebase references
        let postCollection: CollectionReference = Firestore.firestore().collection(NameFile.Firestore.FirestorePosts)
        let imageStorage: StorageReference = Storage.storage().reference(withPath: NameFile.Firestore.images)
        
        let newDocument = postCollection.document()
        geoFire.setLocation(CLLocation(latitude: location.latitude, longitude: location.longitude), forKey: newDocument.documentID)
        if let image = image {
            _ = imageStorage.child(NameFile.Firestore.images).child(newDocument.documentID).putData(UIImagePNGRepresentation(image)!, metadata: nil) { metadata, error in
                guard metadata != nil else {
                    // Uh-oh, an error occurred!
                    print(error!)
                    return
                }
                // You can also access to download URL after upload.
                imageStorage.child(NameFile.Firestore.images).downloadURL { (url, error) in
                    guard let downloadURL = url else {
                        // Uh-oh, an error occurred!
                        print(error!)
                        return
                    }
                    newDocument.setData([
                        NameFile.Firestore.creatorUID: self.creatorUID,
                        NameFile.Firestore.creatorUsername: self.creatorUsername,
                        NameFile.Firestore.postLongitude : self.location.longitude,
                        NameFile.Firestore.postLatitude : self.location.latitude,
                        NameFile.Firestore.postCategory: self.category,
                        NameFile.Firestore.postTime: self.time,
                        NameFile.Firestore.postQuestion: self.question,
                        NameFile.Firestore.postImageURL: downloadURL.absoluteString
                        ])
                    
                    SVProgressHUD.dismiss()
                    finished()
                    
                }
            }
        }
            
            
            //        if let image = image{
            //            imageStorage.putData(UIImagePNGRepresentation(image)!).observe(.success, handler: { (snapshot) in
            //                if let imageURL = snapshot.metadata?.downloadURL()?.absoluteString{
            //                    newDocument.setData([
            //                        NameFile.Firestore.creatorUID: self.creatorUID,
            //                        NameFile.Firestore.creatorUsername: self.creatorUsername,
            //                        //NameFile.Firestore.postLocation: self.location,
            //                        NameFile.Firestore.postLongitude : self.location.longitude,
            //                        NameFile.Firestore.postLatitude : self.location.latitude,
            //                        NameFile.Firestore.postCategory: self.category,
            //                        NameFile.Firestore.postTime: self.time,
            //                        NameFile.Firestore.postQuestion: self.question,
            //                        NameFile.Firestore.postImageURL: imageURL
            //                        ])
            //                     print(imageURL)
            //                    SVProgressHUD.dismiss()
            //                }
            //            })
        else{
            newDocument.setData([
                NameFile.Firestore.creatorUID: self.creatorUID,
                NameFile.Firestore.creatorUsername: self.creatorUsername,
                NameFile.Firestore.postLongitude : self.location.longitude,
                NameFile.Firestore.postLatitude : self.location.latitude,
                NameFile.Firestore.postCategory: self.category,
                NameFile.Firestore.postTime: self.time,
                NameFile.Firestore.postQuestion: self.question
                ])
            SVProgressHUD.dismiss()
            
            finished()
        }
    }
    
}
