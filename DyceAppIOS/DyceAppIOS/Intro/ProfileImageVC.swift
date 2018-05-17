//
//  ProfileImageVC.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 11/22/17.
//  Copyright © 2017 Applausity Inc. All rights reserved.
//

import UIKit
import Photos
import Firebase
import SVProgressHUD

class ProfileImageVC: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    //outlets
    @IBOutlet weak var headerLabel: UILabel!
    @IBOutlet weak var semiHeaderLabel: UILabel!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var cameraBtn: UIButton!
    @IBOutlet weak var photosBtn: UIButton!
    @IBOutlet weak var continueBtn: UIButton!
    
    //distance from header to top safe area
    @IBOutlet weak var toTop: NSLayoutConstraint!
    //distance from continue button to bottom safe area
    @IBOutlet weak var toBottom: NSLayoutConstraint!
    
    //firebase references
    var emailCollection: CollectionReference!
    var userCollection: CollectionReference!
    var images: StorageReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        checkPermission()
        
        profileImageView.image = #imageLiteral(resourceName: "DefaultProfileImage")
        
        //rounds buttons and images
        profileImageView.layer.cornerRadius = 25
        profileImageView.clipsToBounds = true
        continueBtn.layer.cornerRadius = 10
        continueBtn.clipsToBounds = true
        cameraBtn.layer.cornerRadius = 5
        cameraBtn.clipsToBounds = true
        photosBtn.layer.cornerRadius = 5
        photosBtn.clipsToBounds = true
        
        //configs buttons
        photosBtn.addTarget(self, action: #selector(ProfileImageVC.changeProfileImage(_:)), for: .touchUpInside)
        cameraBtn.addTarget(self, action: #selector(ProfileImageVC.changeProfileImage(_:)), for: .touchUpInside)
        continueBtn.addTarget(self, action: #selector(ProfileImageVC.nextPage(_:)), for: .touchUpInside)
        
        //firebase references
        var emailCollection: CollectionReference!
        var userCollection: CollectionReference!
        var images: StorageReference!
        
    }
    
    //MARK: - Image Picker Controller
    
    private func checkPermission() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        switch photoAuthorizationStatus {
        case .authorized:
            print("Access is granted by user")
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({
                (newStatus) in
                print("status is \(newStatus)")
                if newStatus ==  PHAuthorizationStatus.authorized {
                    print("success")
                }
            })
            print("It is not determined until now")
        case .restricted:
            print("User do not have access to photo album.")
        case .denied:
            print("User has denied the permission.")
        }
    }
    
    @objc private func changeProfileImage(_ sender: UIButton){
        
        let imagePickerController = UIImagePickerController()
        imagePickerController.delegate = self
        imagePickerController.allowsEditing = true
        
        if(sender == photosBtn){
            if UIImagePickerController.isSourceTypeAvailable(.photoLibrary){
                imagePickerController.sourceType = .photoLibrary
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("no photos")
            }
        }else{
            if UIImagePickerController.isSourceTypeAvailable(.camera){
                imagePickerController.sourceType = .camera
                self.present(imagePickerController, animated: true, completion: nil)
            }else{
                print("no camera")
            }
        }
    }
    

    @objc func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage{
            self.profileImageView.image = image
        } else {
            print("no picker image exists")
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    //saves the new profile image remotely and locally
    @objc private func nextPage(_ sender: UIButton){
        if let profileImage = profileImageView.image{
            if profileImage == #imageLiteral(resourceName: "default"){
                //segues to app
                let storyboard: UIStoryboard = UIStoryboard(name: "App", bundle: nil)
                if let ivc = storyboard.instantiateInitialViewController(){
                    self.show(ivc, sender: sender)
                }
            }else{
                
                //starts the activity indicator
                SVProgressHUD.show()
                
                let profileImageRef = images.child(AppStorage.PersonalInfo.uid)
                profileImageRef.putData(UIImagePNGRepresentation(profileImage)!).observe(.success, handler: { (snapshot) in
                    if let profileImageURL = snapshot.metadata?.downloadURL()?.absoluteString{
                        self.userCollection.document(AppStorage.PersonalInfo.uid).updateData([
                            NameFile.Firestore.profileImageURL: profileImageURL
                            ])
                        AppStorage.PersonalInfo.profileImage = profileImage
                        AppStorage.PersonalInfo.profileImageURL = profileImageURL
                        AppStorage.save()
                        
                        SVProgressHUD.dismiss()
                        
                        //segues to app
                        let storyboard: UIStoryboard = UIStoryboard(name: "App", bundle: nil)
                        if let ivc = storyboard.instantiateInitialViewController(){
                            self.show(ivc, sender: sender)
                        }
                    }
                })
            }
        }
    }
    
    
    /*
     // MARK: - Navigation
     
     // In a storyboard-based application, you will often want to do a little preparation before navigation
     override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
     // Get the new view controller using segue.destinationViewController.
     // Pass the selected object to the new view controller.
     }
     */
    
}
