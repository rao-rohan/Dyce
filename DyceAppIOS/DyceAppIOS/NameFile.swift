import Foundation

struct NameFile{
    
    struct Firestore{
<<<<<<< HEAD
<<<<<<< HEAD
        static let emails = "EmailCollection"
            //username
                static let email = "Email"
        
        static let users = "UserCollection"
            //uid
                static let firstName = "FirstName"
                static let lastName = "LastName"
                static let username = "Username"
                static let phoneNumber = "PhoneNumber"
                static let profileImageURL = "ProfileImageURL"
        
=======
>>>>>>> parent of 5bb03c2... might uhuoh
        static let posts = "PostCollection"
=======
        static let FirestorePosts = "PostCollection"
>>>>>>> 81e3ffada19361eaaec778ef2feb60eac936e988
            //post id (document)
                static let creatorUID = "CreatorUID"
                static let creatorUsername = "CreatorUsername"
                //static let postLocation = "PostLocation"
                static let postLongitude = "PostLongitude"
                static let postLatitude = "PostLatitude"
                static let postCategory = "PostCategory"
                static let postTime = "PostTime"
                static let postQuestion = "PostQuestion"
                static let postImageURL = "PostImageURL"
        
                static let replies = "ReplyCollection"
                    static let replyUID = "ReplyUID"
                    static let replyUsername = "ReplyUsername"
                    static let reply = "Reply"
                    static let replyTime = "ReplyTime"
                    
        static let images = "Images"
    }
    struct RTDB{
        static let RTDBPosts = "Posts"
            static let firestorePostID = "FirestorePostID"
        
    }
}
