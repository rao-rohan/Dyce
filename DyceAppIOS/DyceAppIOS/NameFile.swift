import Foundation

struct NameFile{
    
    struct Firestore{
        static let FirestorePosts = "PostCollection"
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
