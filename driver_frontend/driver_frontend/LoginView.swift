import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var username = ""
    @State private var password = ""
    @State private var errorMessage: String?

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
        }
        .padding()
    }

    func login() {
        Task {
            do {
                let vehicleID = try await loginVehicle(username: username, password: password)
                DispatchQueue.main.async {
                    authManager.username = username
                    authManager.password = password
                    authManager.vehicleID = vehicleID
                    authManager.isAuthenticated = true
                    RideStore.shared.username = username
                    RideStore.shared.password = password
                    RideStore.shared.vehicleID = vehicleID
                }
            } catch {
                DispatchQueue.main.async {
                    self.errorMessage = error.localizedDescription
                }
            }
        }
    }

    func loginVehicle(username: String, password: String) async throws -> String {
        let url = URL(string: "https://35.3.200.144:5000/api/v1/vehicles/login/")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        let loginData: [String: Any] = ["username": username, "password": password]
        request.httpBody = try JSONSerialization.data(withJSONObject: loginData)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        guard httpResponse.statusCode == 200 else {
            let errorResponse = try JSONSerialization.jsonObject(with: data) as? [String: Any]
            let message = errorResponse?["msg"] as? String ?? "Unknown error"
            throw NSError(domain: "", code: httpResponse.statusCode, userInfo: [NSLocalizedDescriptionKey: message])
        }

        if let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any],
           let vehicleID = json["vehicle_id"] as? String {
            return vehicleID
        } else {
            throw URLError(.cannotParseResponse)
        }
    }
}
