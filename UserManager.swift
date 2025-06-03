

import Foundation
import Combine

class UserManager: ObservableObject {
    @Published var isSignedIn: Bool = false
    @Published var email: String = ""
    private var password: String = ""
    
    init() {
        // Try to load saved user data on launch
        if let userData = LocalStorage.shared.loadUser() {
            self.email = userData.email
            self.password = userData.password
            self.isSignedIn = true
        }
    }
    
    func signIn(email: String, password: String) {
        // Check if user exists
        if let savedUser = LocalStorage.shared.loadUser() {
            // Verify credentials
            if savedUser.email == email && savedUser.password == password {
                self.email = email
                self.password = password
                self.isSignedIn = true
            }
        } else {
            // Create new user
            let userData = UserData(email: email, password: password)
            LocalStorage.shared.saveUser(userData)
            self.email = email
            self.password = password
            self.isSignedIn = true
        }
    }
    
    func signOut() {
        self.email = ""
        self.password = ""
        self.isSignedIn = false
        LocalStorage.shared.clearUserData()
    }
}
