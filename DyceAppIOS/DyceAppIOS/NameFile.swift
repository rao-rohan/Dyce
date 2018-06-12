// Names: Nikhil Sridhar and Rohan Rao
//
// File Name: NameFile.swift
//
// File Description: This class stores any name constants for easier access and less error.

import Foundation

struct NameFile{
    
    struct Firestore{
        static let posts = "PostCollection"
            //post id (document)
                static let creatorUID = "CreatorUID"
                static let creatorUsername = "CreatorUsername"
                static let postCategory = "PostCategory"
                static let postTime = "PostTime"
                static let postQuestion = "PostQuestion"
                static let postImageURL = "PostImageURL"
        
                static let replies = "ReplyCollection"
                    static let replyUID = "ReplyUID"
                    static let replyUsername = "ReplyUsername"
                    static let reply = "Reply"
                    static let replyTime = "ReplyTime"
        static let users = "UserCollection"
            static let userUID = "UserUID"
                static let userPosts = "UserPostsCollection"
                    static let userPostID = "UserPostID"
                static let userFavoritedPosts = "UserFavoritedPostsCollection"
                    static let userFavPostID = "UserFavID"
                static let userRepliesCollection = "UserRepliesCollection"
                    static let userReplyPostID = "UserReplyID"
        
        static let images = "Images"
    }
    struct Segues{
        struct Profile {
            static let toOneCellSettingDetail = "SegueToOneCellSettingDetail"
            static let toTwoCellSettingDetail = "SegueToTwoCellSettingDetail"
            static let toThreeCellSettingDetail = "SegueToThreeCellSettingDetail"
            static let unwindToSettings = "UnwindToSettings"
            static let toUserPostsRepliesFavorites = "SegueToUserPostsRepliesFavorites"
            
        }
    }
    struct RTDB{
        static let RTDBPosts = "Posts"
            static let firestorePostID = "FirestorePostID"
    }
}
