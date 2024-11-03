import Foundation
import Combine

class AuthViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isAuthenticated = false
    @Published var currentUser: User?
    @Published var errorMessage: String?
    @Published var isLoading = false
    
    // MARK: - User Input Properties
    @Published var email = ""
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var fullName = ""
    
    // MARK: - Validation Properties
    @Published var isEmailValid = false
    @Published var isPasswordValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        setupValidation()
        checkAuthenticationState()
    }
    
    // MARK: - Validation Setup
    private func setupValidation() {
        // Email validation
        $email
            .map { email in
                let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
                let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
                return emailPredicate.evaluate(with: email)
            }
            .assign(to: \.isEmailValid, on: self)
            .store(in: &cancellables)
        
        // Password validation (minimum 8 characters)
        $password
            .map { $0.count >= 8 }
            .assign(to: \.isPasswordValid, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication Methods
    func signIn() {
        guard isEmailValid, isPasswordValid else {
            errorMessage = "Please enter valid credentials"
            return
        }
        
        isLoading = true
        
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // TODO: Replace with actual API call
            if self.email == "test@example.com" && self.password == "password123" {
                self.currentUser = User(
                    id: UUID().uuidString,
                    email: self.email,
                    fullName: "Test User"
                )
                self.isAuthenticated = true
                self.saveAuthToken("dummy-token")
            } else {
                self.errorMessage = "Invalid credentials"
            }
            
            self.isLoading = false
        }
    }
    
    func signUp() {
        guard isEmailValid, isPasswordValid else {
            errorMessage = "Please enter valid credentials"
            return
        }
        
        guard password == confirmPassword else {
            errorMessage = "Passwords don't match"
            return
        }
        
        guard !fullName.isEmpty else {
            errorMessage = "Please enter your full name"
            return
        }
        
        isLoading = true
        
        // Simulate network call
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            guard let self = self else { return }
            
            // TODO: Replace with actual API call
            self.currentUser = User(
                id: UUID().uuidString,
                email: self.email,
                fullName: self.fullName
            )
            self.isAuthenticated = true
            self.saveAuthToken("dummy-token")
            
            self.isLoading = false
        }
    }
    
    func signOut() {
        // Clear user data
        currentUser = nil
        isAuthenticated = false
        clearAuthToken()
        
        // Reset form fields
        email = ""
        password = ""
        confirmPassword = ""
        fullName = ""
    }
    
    // MARK: - Helper Methods
    private func checkAuthenticationState() {
        // Check if user is already logged in
        if let token = UserDefaults.standard.string(forKey: "authToken") {
            // TODO: Validate token with backend
            isAuthenticated = true
            // TODO: Fetch user profile
        }
    }
    
    private func saveAuthToken(_ token: String) {
        UserDefaults.standard.set(token, forKey: "authToken")
    }
    
    private func clearAuthToken() {
        UserDefaults.standard.removeObject(forKey: "authToken")
    }
    
    func clearError() {
        errorMessage = nil
    }
}

// MARK: - User Model
struct User: Codable {
    let id: String
    let email: String
    let fullName: String
}
