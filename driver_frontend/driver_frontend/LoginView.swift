import SwiftUI
import CoreLocation

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var vehicleID = ""
    @State private var errorMessage: String?
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        VStack(spacing: 20) {
            Text("Driver Login")
                .font(.largeTitle)

            TextField("Username", text: $username)
                .padding()
                .autocapitalization(.none)
                .border(Color.gray)

            SecureField("Password", text: $password)
                .padding()
                .border(Color.gray)

            TextField("Vehicle ID", text: $vehicleID)
                .padding()
                .autocapitalization(.none)
                .border(Color.gray)

            if let errorMessage = errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
            }

            Button(action: login) {
                Text("Login")
                    .font(.headline)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .disabled(!isLoginEnabled())

            if locationManager.location == nil {
                Text("Fetching current location...")
                    .font(.caption)
                    .foregroundColor(.gray)
            }
        }
        .padding()
    }

    func isLoginEnabled() -> Bool {
        return !username.isEmpty && !password.isEmpty && !vehicleID.isEmpty && locationManager.location != nil
    }

    func login() {
        guard let location = locationManager.location else {
            self.errorMessage = "Unable to fetch current location."
            return
        }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude

        Task {
            do {
                let vehicleIDResponse = try await loginVehicle(username: username, password: password, vehicleID: vehicleID, latitude: latitude, longitude: longitude)
                DispatchQueue.main.async {
                    authManager.username = username
                    authManager.password = password
                    authManager.vehicleID = vehicleIDResponse
                    authManager.isAuthenticated = true
                    RideStore.shared.username = username
                    RideStore.shared.password = password
                    RideStore.shared.vehicleId = vehicleIDResponse
                    locationManager.setVehicleId(vehicleIDResponse)
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loginVehicle(username: String, password: String, vehicleID: String, latitude: Double, longitude: Double) async throws -> String {
        guard let url = URL(string: "http://35.2.2.224:5000/api/v1/vehicles/login/") else {
            throw URLError(.badURL)
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let loginData: [String: Any] = [
            "username": username,
            "password": password,
            "vehicle_id": vehicleID,
            "latitude": latitude,
            "longitude": longitude
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
