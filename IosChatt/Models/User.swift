//
//  User.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-05-25.
//

import Foundation

//TODO Fix name variable
class User {
    
    let userName: String
    let uid: String
    
    
    init(_ username:String, uid:String) {
        self.userName = username
        self.uid = uid
    }
}
