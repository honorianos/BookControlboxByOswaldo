//
//  UserDefaultsClass.swift
//  BookControlbox
//
//  Created by Oswaldo Escobar on 28/07/24.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    private let userKey = "loggedInUser"

    private init() {}

    func saveUser(_ user: User) {
        do {
            let data = try JSONEncoder().encode(user)
            UserDefaults.standard.set(data, forKey: userKey)
        } catch {
            print("Error encoding user: \(error)")
        }
    }

    func getUser() -> User? {
        guard let data = UserDefaults.standard.data(forKey: userKey) else { return nil }
        do {
            let user = try JSONDecoder().decode(User.self, from: data)
            return user
        } catch {
            print("Error decoding user: \(error)")
            return nil
        }
    }

    func removeUser() {
        UserDefaults.standard.removeObject(forKey: userKey)
        print("remove user done")
    }
    
    
    func saveStringKey(value: String, forKey key: String) {
        UserDefaults.standard.set(value, forKey: key)
    }
    
    func getStringKey(forKey key: String) -> String? {
        return UserDefaults.standard.string(forKey: key)
    }
    
}
