//
//  ProfileTableViewController.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 1/6/18.
//  Copyright © 2018 Applausity Inc. All rights reserved.
//

import UIKit
import Photos
import Firebase
import SVProgressHUD

class ProfileVC: UIViewController {
    
    @IBOutlet weak var toUserPostsView: UIView!
    //header outlets
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var settingsBtn: UIButton!
    
    //image picker controller
    //firebase references
    var userCollection: CollectionReference!
    var postsCollection : CollectionReference!
    var selectedPostType: UserPostType = .replies
    
    override func viewDidLoad() {
        
        //rounds imageview corners
        
        //rounds button corners
        settingsBtn.layer.masksToBounds = true
        settingsBtn.layer.cornerRadius = 10
    
        //registers the profileImageView as a UITapGestureRecognizer
        
        //configs firebase references
        userCollection = Firestore.firestore().collection(NameFile.Firestore.users)
        postsCollection = Firestore.firestore().collection(NameFile.Firestore.posts)
  
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //hides the navigation bar on the this view controller
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        //shows the navigation bar on other view controllers
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
        SVProgressHUD.dismiss()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        loadUserData()
    }
    
    private func loadUserData(){
        usernameLabel.text = AppStorage.PersonalInfo.username
    }
    @IBAction func userFavPressed(_ sender: Any) {
        selectedPostType = .favorites
        print(selectedPostType)
        performSegue(withIdentifier: NameFile.Segues.Profile.toUserPostsRepliesFavorites, sender: nil)
    }
    @IBAction func userRepliesPressed(_ sender: Any) {
        selectedPostType = .replies
        print(selectedPostType)
        performSegue(withIdentifier: NameFile.Segues.Profile.toUserPostsRepliesFavorites, sender: nil)
    }
    @IBAction func userPostsPressed(_ sender: Any) {
        selectedPostType = .userPosts
        print(selectedPostType)
        performSegue(withIdentifier: NameFile.Segues.Profile.toUserPostsRepliesFavorites, sender: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        //sets the destination to the selectedType
//        if segue.identifier == NameFile.Segues.Profile.toUserPostsRepliesFavorites{
//            let vc = segue.destination as! UserSelectedPostsTableViewController
//            vc.postType = selectedPostType
//        }
        
        
        if let detailVC = segue.destination as? UserSelectedPostsTableViewController{
            print("here")
            detailVC.postType = selectedPostType
            
        }
    }
    @IBAction func unwindToProfile(segue: UIStoryboardSegue) {}
}
enum UserPostType{
    case userPosts
    case favorites
    case replies
    case none
}

