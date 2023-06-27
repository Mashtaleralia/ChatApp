//
//  DatabaseManager.swift
//  ChatApp
//
//  Created by Admin on 27.06.2023.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager {
    
    static let shared = DatabaseManager()
    
    private let database = Database.database().reference()
    
}

extension DatabaseManager {
    
    public func userExists(with email: String, completion: @escaping (Bool) -> Void) {
        database.child(email).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    public func insertUser(with user: ChatAppUser) {
        database.child(user.emailAddress).setValue(["first_name":user.firstName,
                                                    "last_name":user.lastName])
    }
}



struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
   // let profilePictureUrl: String
}
