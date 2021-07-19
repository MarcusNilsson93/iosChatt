//
//  User.swift
//  IosChat
//
//  Created by Marcus Nilsson on 2021-05-25.
//

import Foundation

class User : Equatable {
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.userName == rhs.userName && lhs.uid == rhs.uid
    }
    
    
    var userName: String
    var uid: String
    
    
    init(_ username:String, uid:String) {
        self.userName = username
        self.uid = uid
    }
}
