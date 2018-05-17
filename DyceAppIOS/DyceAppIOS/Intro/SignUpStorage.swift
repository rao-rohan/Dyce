//
//  SignUpStorage.swift
//  SplitMe
//
//  Created by Nikhil Sridhar on 11/11/17.
//  Copyright © 2017 Applausity Inc. All rights reserved.
//

import Foundation

struct SignUpStorage {
    static var username: String?
    static var email: String?
    static var password: String?
    static var firstName: String?
    static var lastName: String?
    static var phoneNumber: String?
    
    static func empty(){
        SignUpStorage.username = nil
        SignUpStorage.email = nil
        SignUpStorage.password = nil
        SignUpStorage.firstName = nil
        SignUpStorage.lastName = nil
        SignUpStorage.phoneNumber = nil
    }
}
