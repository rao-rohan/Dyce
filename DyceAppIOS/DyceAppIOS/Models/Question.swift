import Foundation
import UIKit
import Firebase
import CoreLocation
import SVProgressHUD

class Question {
    
    var creatorUID: String
    var creatorUsername: String
    var postID: String
    var location: GeoPoint
    var category: String
    var time: String
    var question: String
    var numReplies: Int
    var image: UIImage?
    
    init(_creatorUID: String, _creatorUsername: String, _postID: String, _location: GeoPoint, _category: String, _time: String, _question: String, _numReplies: Int, _image: UIImage? = nil) {
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
        creatorUID = ""
        creatorUsername = ""
        postID = ""
        location = GeoPoint(latitude: 0.0, longitude: 0.0)
        category = ""
        time = ""
        question = ""
        numReplies = 0
        image = nil
    }
    
    func pushToFirestore(){
        //firebase references
        let postCollection: CollectionReference = Firestore.firestore().collection(NameFile.Firestore.posts)
        let imageStorage: StorageReference = Storage.storage().reference(withPath: NameFile.Firestore.images)
        
        if let image = image{
            imageStorage.child(NameFile.Firestore.images).putData(UIImagePNGRepresentation(image)!).observe(.success, handler: { (snapshot) in
                if let imageURL = snapshot.metadata?.downloadURL()?.absoluteString{
                    postCollection.document().setData([
                        NameFile.Firestore.creatorUID: self.creatorUID,
                        NameFile.Firestore.creatorUsername: self.creatorUsername,
                        NameFile.Firestore.postLocation: self.location,
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
                NameFile.Firestore.postLocation: self.location,
                NameFile.Firestore.postCategory: self.category,
                NameFile.Firestore.postTime: self.time,
                NameFile.Firestore.postQuestion: self.question
                ])
            SVProgressHUD.dismiss()
        }
    }
    
}
