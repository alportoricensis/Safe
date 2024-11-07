import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

class AuthViewModel: ObservableObject {
    @Published var user: User?
    @Published var isAuthenticated = false
    @Published var error: Error?
    
    func signInWithGoogle() {
        guard let clientID = Bundle.main.infoDictionary?["GIDClientID"] as? String else {
            print("Error: No client ID found in Info.plist")
            return
        }
        
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
            print("Error: No root view controller found")
            return
        }
        
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config
        
        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { [weak self] result, error in
            if let error = error {
                self?.error = error
                return
            }
            
            guard let user = result?.user,
                  let userID = user.userID,
                  let profile = user.profile else { return }
            
            let authenticatedUser = User(
                id: userID,
                email: profile.email,
                displayName: profile.name
            )
            
            DispatchQueue.main.async {
                self?.user = authenticatedUser
                self?.isAuthenticated = true
            }
        }
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.user = nil
        self.isAuthenticated = false
    }
}
