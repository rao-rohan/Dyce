import Foundation
import UIKit

//stores basic information locally
//functionality includes saving and loading from UserDefaults
//operates completely independent from firebase

public class AppStorage{
    
    struct PersonalInfo {
        static var uid = ""
        static var username = ""
    }
    
    static func save(){
        let defaults = UserDefaults.standard
        
        //Personal Info save
        defaults.set(PersonalInfo.uid, forKey: "UID")
        defaults.set(PersonalInfo.username, forKey: "Username")
    }
    
    static func load(){
        let defaults = UserDefaults.standard
        
        //Personal Info load
        PersonalInfo.uid = defaults.value(forKey: "UID") as? String ?? ""
        PersonalInfo.username = defaults.value(forKey: "Username") as? String ?? ""
    }
    
}
