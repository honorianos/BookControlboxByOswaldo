//
//  Manager.swift
//  BookControlbox
//
//  Created by Oswaldo Escobar on 28/07/24.
//

import Foundation
import Firebase

class AuthManager {
    static let shared = AuthManager()

    private init() {}

    func login(username: String, email:String,  password: String) -> Bool {
        let user = User(username: username, email: email, password: password)
        UserDefaultsManager.shared.saveUser(user)
        return true
    }

    func logout() {
          do {
              try Auth.auth().signOut()
              UserDefaultsManager.shared.removeUser()
              print("User logged out successfully")
          } catch let signOutError as NSError {
              print("Error signing out: %@", signOutError)
          }
      }

    func isLoggedIn() -> Bool {
        return UserDefaultsManager.shared.getUser() != nil
    }
}
