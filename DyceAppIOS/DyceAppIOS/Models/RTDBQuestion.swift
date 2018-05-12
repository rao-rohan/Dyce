////
////  RTDBQuestion.swift
////  DyceAppIOS
////
////  Created by Rohan Rao on 5/11/18.
////  Copyright © 2018 NikhilandRohan. All rights reserved.
////
//
//import Foundation
//import Firebase
//import GeoFire
//class RTDBQuestion {
//    var geofireRef : DatabaseReference!
//    var geoFire = GeoFire()
//    var longitude : Double
//    var latitude : Double
//    var postID : String
//    init(_postID : String , _longitude : Double , _latitude : Double ) {
//        geofireRef = Database.database().reference()
//        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDBPosts.RTDBPosts))
//        longitude = _longitude
//        latitude = _latitude
//        postID = _postID
//    }
//    init() {
//        geofireRef = Database.database().reference()
//        geoFire = GeoFire(firebaseRef: geofireRef.ref.child(NameFile.RTDBPosts.RTDBPosts))
//        longitude = 0
//        latitude = 0
//        postID = ""
//    }
//
//
//    func pushToRTDB(){
//         geoFire.setLocation(CLLocation(latitude: latitude, longitude: longitude), forKey: postID)
//    }
//
//}
//
