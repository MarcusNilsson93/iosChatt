//
//  User.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-05-25.
//

import Foundation

//TODO Fix name variable
class User {
    
    var userName: String
    var uid: String
    
    
    init(_ username:String, uid:String) {
        self.userName = username
        self.uid = uid
    }
}
