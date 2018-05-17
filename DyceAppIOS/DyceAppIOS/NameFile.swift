import Foundation

struct NameFile{
    
    struct Firestore{
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
        
        static let posts = "PostCollection"
            //post id (document)
                static let creatorUID = "CreatorUID"
                static let creatorUsername = "CreatorUsername"
                static let creatorProfileImageURL = "CreatorProfileImageURL"
                static let postLongitude = "PostLongitude"
                static let postLatitude = "PostLatitude"
                static let postCategory = "PostCategory"
                static let postTime = "PostTime"
                static let postQuestion = "PostQuestion"
                static let postImageURL = "PostImageURL"
        
                static let replies = "ReplyCollection"
                    static let replyUID = "ReplyUID"
                    static let replyUsername = "ReplyUsername"
                    static let replyImageURL = "ReplyImageURL"
                    static let reply = "Reply"
                    static let replyTime = "ReplyTime"
                    
        
        static let images = "Images"
    }
}
