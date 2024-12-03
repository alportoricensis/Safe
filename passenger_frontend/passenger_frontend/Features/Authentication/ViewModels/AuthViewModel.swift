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
            
            self?.loginToBackend(user: authenticatedUser)
        }
    }

    private func loginToBackend(user: User) {
        guard let url = URL(string: "http://18.191.14.26/api/v1/users/login/") else { return }
        
        let body: [String: Any] = [
            "uuid": user.id,
            "email": user.email,
            "displayName": user.displayName
        ]
        
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = try? JSONSerialization.data(withJSONObject: body)
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                if let error = error {
                    print("❌ Login Error: \(error.localizedDescription)")
                    self?.error = error
                    return
                }
                
                if let data = data {
                    print("📥 Login Response Data: \(String(data: data, encoding: .utf8) ?? "No data")")
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    print("🔄 Login Response Status: \(httpResponse.statusCode)")
                }
                
                self?.user = user
                self?.isAuthenticated = true
            }
        }.resume()
    }

    func signInAsGuest() {
        let guestId = UUID().uuidString
        self.user = User(id: guestId, email: "", displayName: "Guest")
        self.isAuthenticated = true
    }
    
    func signOut() {
        GIDSignIn.sharedInstance.signOut()
        self.user = nil
        self.isAuthenticated = false
    }
}
