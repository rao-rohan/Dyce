import Foundation

struct NameFile{
    
    struct Firestore{
        static let posts = "PostCollection"
            //post id (document)
                static let creatorUID = "CreatorUID"
                static let creatorUsername = "CreatorUsername"
                static let postLocation = "PostLocation"
                static let postCategory = "PostCategory"
                static let postTime = "PostTime"
                static let postQuestion = "PostQuestion"
                static let postImageURL = "PostImageURL"
        
                static let replies = "ReplyCollection"
                    static let replyUID = "ReplyUID"
                    static let replyUsername = "ReplyUsername"
                    static let reply = "Reply"
                    
        
        static let images = "Images"
    }
}
