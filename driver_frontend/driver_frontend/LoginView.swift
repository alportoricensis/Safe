import SwiftUI
import CoreLocation

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var vehicleID = ""
    @State private var errorMessage: String?
    
    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                Spacer().frame(height: 40) // Top padding
                
                Text("Driver Login")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .padding(.bottom, 30)
                
                // Username Field
                TextField("Username", text: $username)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding([.leading, .trailing], 24)
                
                // Password Field
                SecureField("Password", text: $password)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .padding([.leading, .trailing], 24)
                
                // Vehicle ID Field
                TextField("Vehicle ID", text: $vehicleID)
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
                    .autocapitalization(.none)
                    .disableAutocorrection(true)
                    .padding([.leading, .trailing], 24)
                
                // Error Message
                if let errorMessage = errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding([.leading, .trailing], 24)
                }
                
                // Login Button
                Button(action: login) {
                    Text("Login")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(10)
                        .padding([.leading, .trailing], 24)
                }
                .padding(.top, 10)
                
                Spacer() // Bottom padding
            }
        }
        .background(Color.white)
        .ignoresSafeArea(edges: .bottom) // Ensure background extends under the keyboard
    }
    
    func login() {
        Task {
            do {
                let vehicleIDResponse = try await loginVehicle(username: username, password: password, vehicleID: vehicleID)
                DispatchQueue.main.async {
                    authManager.username = username
                    authManager.password = password
                    authManager.vehicleID = vehicleIDResponse
                    authManager.isAuthenticated = true
                    RideStore.shared.username = username
                    RideStore.shared.password = password
                    RideStore.shared.vehicleID = vehicleIDResponse
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }
    
    func loginVehicle(username: String, password: String, vehicleID: String) async throws -> String {
        guard let url = URL(string: "http://35.3.200.144:5000/api/v1/vehicles/login/") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        var locManager = CLLocationManager()
        locManager.requestWhenInUseAuthorization()
        var currentLocation: CLLocation!

        
        currentLocation = locManager.location
        
        let latitude = currentLocation.coordinate.latitude
        let longitude = currentLocation.coordinate.longitude
        let loginData: [String: Any] = [
            "username": username,
            "password": password,
            "vehicle_id": vehicleID,
            "latitude":latitude,
            "longitude":longitude
            
        ]
        request.httpBody = try JSONSerialization.data(withJSONObject: loginData, options: [])
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }
        
        guard httpResponse.statusCode == 200 else {
            let errorResponse = try? JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message = errorResponse?["msg"] as? String ?? "Unknown error"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }
        
        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let returnedVehicleID = json["vehicle_id"] as? String {
            return returnedVehicleID
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}
