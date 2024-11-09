import SwiftUI

class LoginViewModel: ObservableObject {
    @Published var vehicleID: String = ""
    @Published var latitude: String = ""
    @Published var longitude: String = ""
    @Published var isLoggedIn: Bool = false
    @Published var errorMessage: String = ""
}

struct LoginView: View {
    @StateObject private var viewModel = LoginViewModel()
    @EnvironmentObject var appState: AppState

    var body: some View {
        VStack(spacing: 20) {
            Text("Vehicle Login")
                .font(.largeTitle)
            TextField("Vehicle ID", text: $viewModel.vehicleID)
                .padding()
                .background(Color(.secondarySystemBackground))
            TextField("Latitude", text: $viewModel.latitude)
                .padding()
                .background(Color(.secondarySystemBackground))
            TextField("Longitude", text: $viewModel.longitude)
                .padding()
                .background(Color(.secondarySystemBackground))
            if !viewModel.errorMessage.isEmpty {
                Text(viewModel.errorMessage)
                    .foregroundColor(.red)
            }
            Button(action: {
                Task {
                    await loginVehicle()
                }
            }) {
                Text("Login")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding()
        .onChange(of: viewModel.isLoggedIn) { isLoggedIn in
            if isLoggedIn {
                appState.vehicleID = viewModel.vehicleID
                appState.isLoggedIn = true
            }
        }
    }

    func loginVehicle() async {
        guard let url = URL(string: "https://35.3.200.144:5000/api/v1/vehicles/login/") else {
            viewModel.errorMessage = "Invalid URL"
            return
        }

        guard let latitude = Double(viewModel.latitude),
              let longitude = Double(viewModel.longitude) else {
            viewModel.errorMessage = "Please enter valid latitude and longitude."
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let requestBody: [String: Any] = [
            "vehicle_id": viewModel.vehicleID,
            "latitude": latitude,
            "longitude": longitude
        ]

        do {
            let data = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = data

            let (responseData, response) = try await URLSession.shared.data(for: request)

            if let httpResponse = response as? HTTPURLResponse {
                if httpResponse.statusCode == 200 {
                    // Login successful
                    DispatchQueue.main.async {
                        viewModel.isLoggedIn = true
                    }
                } else {
                    // Handle error messages from the backend
                    if let json = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
                       let msg = json["msg"] as? String {
                        DispatchQueue.main.async {
                            viewModel.errorMessage = msg
                        }
                    } else {
                        DispatchQueue.main.async {
                            viewModel.errorMessage = "Login failed with status code: \(httpResponse.statusCode)"
                        }
                    }
                }
            }
        } catch {
            DispatchQueue.main.async {
                viewModel.errorMessage = "Network error: \(error.localizedDescription)"
            }
        }
    }
}
