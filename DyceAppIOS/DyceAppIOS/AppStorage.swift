// Names: Nikhil Sridhar and Rohan Rao
//
// File Name: AppStorage.swift
//
// File Description: This class stores basic information locally;
// functionality includes saving and loading from UserDefaults;
// operates completely independent from firebase

import Foundation
import UIKit

public class AppStorage{
    
    struct PersonalInfo {
        static var uid = ""
        static var username = ""
        static var email = ""
        static var password = ""
    }
    struct Questions {
        static var category: String?
    }
    
    static func save(){
        let defaults = UserDefaults.standard
        
        //Personal Info save
        defaults.set(PersonalInfo.uid, forKey: "UID")
        defaults.set(PersonalInfo.username, forKey: "Username")
        defaults.set(PersonalInfo.email, forKey: "Email")
        defaults.set(PersonalInfo.password, forKey: "Password")
        
        //Questions save
        defaults.set(Questions.category, forKey: "Category")
    }
    
    static func load(){
        let defaults = UserDefaults.standard
        
        //Personal Info load
        PersonalInfo.uid = defaults.value(forKey: "UID") as? String ?? ""
        PersonalInfo.username = defaults.value(forKey: "Username") as? String ?? ""
        PersonalInfo.email = defaults.value(forKey: "Email") as? String ?? ""
        PersonalInfo.password = defaults.value(forKey: "Password") as? String ?? ""
        
        
        //Questions load
        Questions.category = defaults.value(forKey: "Category") as? String
    }
    
}
