import Foundation
import SwiftUI
internal import Combine

final class AuthManager: ObservableObject {
    @Published var currentUser: User?
    @Published var isAuthenticated = false
    
    private let dbManager = SQLiteManager.shared
    
    func signUp(email: String, name: String) -> Bool {
        let success = dbManager.insertUser(email: email, name: name)
        if success {
            if let userData = dbManager.getUser(by: email) {
                currentUser = User(id: userData.id, email: userData.email, name: userData.name)
                isAuthenticated = true
            }
        }
        return success
    }
    
    func signIn(email: String) -> Bool {
        if let userData = dbManager.getUser(by: email) {
            currentUser = User(id: userData.id, email: userData.email, name: userData.name)
            isAuthenticated = true
            return true
        }
        return false
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
    }
    
    func userExists(email: String) -> Bool {
        return dbManager.getUser(by: email) != nil
    }
}
