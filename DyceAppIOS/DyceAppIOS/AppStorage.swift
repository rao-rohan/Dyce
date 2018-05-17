import Foundation
import UIKit

public class AppStorage{
    
    struct PersonalInfo {
        static var uid = ""
        static var profileImageURL = ""
        static var firstName = ""
        static var lastName = ""
        static var username = ""
        static var phoneNumber = ""
        static var email = ""
        static var password = ""
        static var profileImage = UIImage()
    }
    
    static func save(){
        let defaults = UserDefaults.standard
        
        defaults.set(PersonalInfo.uid, forKey: "UID")
        defaults.set(PersonalInfo.profileImageURL, forKey: "ProfileImageURL")
        defaults.set(PersonalInfo.firstName, forKey: "FirstName")
        defaults.set(PersonalInfo.lastName, forKey: "LastName")
        defaults.set(PersonalInfo.username, forKey: "Username")
        defaults.set(PersonalInfo.phoneNumber, forKey: "PhoneNumber")
        defaults.set(PersonalInfo.email, forKey: "Email")
        defaults.set(PersonalInfo.password, forKey: "Password")
        
        if let data = UIImagePNGRepresentation(PersonalInfo.profileImage) {
            let filename = getDocumentsDirectory().appendingPathComponent("ProfileImage")
            try? data.write(to: filename)
        }
    }
    
    static func load(){
        let defaults = UserDefaults.standard
        
        PersonalInfo.uid = defaults.value(forKey: "UID") as? String ?? ""
        PersonalInfo.profileImageURL = defaults.value(forKey: "ProfileImageURL") as? String ?? ""
        PersonalInfo.firstName = defaults.value(forKey: "FirstName") as? String ?? ""
        PersonalInfo.lastName = defaults.value(forKey: "LastName") as? String ?? ""
        PersonalInfo.username = defaults.value(forKey: "Username") as? String ?? ""
        PersonalInfo.phoneNumber = defaults.value(forKey: "PhoneNumber") as? String ?? ""
        PersonalInfo.email = defaults.value(forKey: "Email") as? String ?? ""
        PersonalInfo.password = defaults.value(forKey: "Password") as? String ?? ""
        
        let imageURL = getDocumentsDirectory().appendingPathComponent("ProfileImage")
        let image = UIImage(contentsOfFile: imageURL.path)
        PersonalInfo.profileImage = image ?? UIImage()
    }
    
    private static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
}
