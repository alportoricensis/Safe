import SwiftUI

struct AssignedRidesView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedTab: Tab = .current
    @State private var showAlert = false
    @State private var alertMessage = ""
    
    enum Tab {
        case current, completed
    }

    var body: some View {
        NavigationView {
            GeometryReader { geometry in
                VStack(spacing: 0) {
                    VStack {
                        Button(action: logoutVehicle) {
                            Text("Logout")
                                .font(.headline)
                                .padding()
                                .background(Color.yellow)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                        }
                        .padding(.top, 20)
                        .alert(isPresented: $showAlert) {
                            Alert(title: Text("Logout Status"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
                        }
                        
                        Text("Assigned Rides")
                            .font(.largeTitle)
                            .foregroundColor(.white)
                            .padding(.top, 30)
                        
                        Spacer()
                        
                        HStack(spacing: 0) {
                            TabButton(text: "Current", isSelected: selectedTab == .current) {
                                selectedTab = .current
                            }
                            TabButton(text: "Completed", isSelected: selectedTab == .completed) {
                                selectedTab = .completed
                            }
                        }
                        .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height * 0.25)
                    .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                    
                    VStack {
                        if selectedTab == .current {
                            CurrRidesView()
                        } else {
                            CompletedRidesView()
                        }
                        Spacer()
                    }
                    .frame(width: geometry.size.width, height: geometry.size.height)
                    .background(Color(red: 0/255, green: 39/255, blue: 76/255))
                }
                .edgesIgnoringSafeArea(.all)
                .withSafeTopBar()
            }
            .navigationBarTitle("Assigned Rides", displayMode: .inline)
        }
    }

    func switchToCompletedTab() {
        selectedTab = .completed
    }

    func logoutVehicle() {
        if let vehicleId = RideStore.shared.vehicleId {
            logoutAPI(vehicleId: vehicleId) { success, message in
                DispatchQueue.main.async {
                    alertMessage = message
                    showAlert = true

                    if success {
                        authManager.isAuthenticated = false
                        RideStore.shared.vehicleId = nil
                    }
                }
            }
        }
    }

    func logoutAPI(vehicleId: String, completion: @escaping (Bool, String) -> Void) {
        guard let url = URL(string: "http://18.191.14.26/api/v1/vehicles/logout/\(vehicleId)/") else {
            completion(false, "Invalid URL")
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"

        request.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Accept")

        let task = URLSession.shared.dataTask(with: request) { data, response, error in
            if let error = error {
                completion(false, "Error: \(error.localizedDescription)")
                return
            }

            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                completion(true, "Successfully logged out.")
            } else {
                completion(false, "Failed to log out. Vehicle may not be active.")
            }
        }

        task.resume()
    }
}

struct TabButton: View {
    var text: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack {
                Text(text)
                    .foregroundColor(.white)
                    .fontWeight(isSelected ? .bold : .regular)
                    .padding(.vertical, 3)
                Rectangle()
                    .fill(isSelected ? Color.yellow : Color.clear)
                    .frame(height: 2)
            }
            .frame(maxWidth: .infinity)
        }
    }
}
