import SwiftUI

enum MenuOption: String, CaseIterable {
    case assignedRides = "Assigned Rides"
    case rideHistory = "Ride History"
    case settings = "Settings"
    case support = "Support"
    case messages = "Messages"
}

struct MenuView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var rideStore: RideStore
    @EnvironmentObject var locationManager: LocationManager
    @State private var selectedOption: MenuOption?
    
    // State variables for alert handling
    @State private var showAlert: Bool = false
    @State private var alertMessage: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            // Header Section
            VStack(alignment: .leading) {
                Text("SAFE!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.yellow)
                
                HStack {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .foregroundColor(.gray)
                    
                    VStack(alignment: .leading) {
                        Text((authManager.username ?? "").isEmpty ? "Driver" : authManager.username ?? "Driver")
                            .font(.headline)
                        
                        Divider()
                        
                        NavigationLink(destination: MessagesView()
                            .environmentObject(authManager)
                            .environmentObject(locationManager)
                        ) {
                            HStack {
                                Text("Messages")
                                Spacer()
                                Image(systemName: "circle.fill")
                                    .foregroundColor(.yellow)
                                    .font(.system(size: 8))
                            }
                        }
                    }
                }
            }
            .padding()
            .background(Color(red: 2/255, green: 28/255, blue: 52/255))
            .cornerRadius(10)
            
            // Menu Options
            VStack(alignment: .leading, spacing: 15) {
                NavigationLink(destination: AssignedRidesView()
                    .environmentObject(rideStore)
                    .environmentObject(authManager)
                    .environmentObject(locationManager)
                ) {
                    Text("Assigned Rides")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                NavigationLink(destination: RideHistoryView()
                    .environmentObject(rideStore)
                    .environmentObject(locationManager)
                ) {
                    Text("Ride History")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                NavigationLink(destination: SettingsView()
                    .environmentObject(locationManager)
                ) {
                    Text("Settings")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                NavigationLink(destination: SupportView()
                    .environmentObject(locationManager)
                ) {
                    Text("Support")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            .foregroundColor(.white)
            
            Spacer()
            
            // Footer Section with Logout Button
            VStack {
                Divider()
                Button(action: logoutVehicle) {
                    HStack {
                        Image(systemName: "arrow.backward.circle.fill")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundColor(.red)
                        Text("Logout")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                    .cornerRadius(10)
                }
            }
            .padding(.horizontal)
            
            // Footer Text
            HStack {
                Text("Legal")
                Spacer()
                Text("v4.3712003")
            }
            .font(.caption)
            .padding(.horizontal)
            .foregroundColor(.white)
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        // Alert Modifier
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Logout"), message: Text(alertMessage), dismissButton: .default(Text("OK")))
        }
    }
    
    // MARK: - Logout Functions
    
    func logoutVehicle() {
        guard let vehicleId = rideStore.vehicleId else {
            self.alertMessage = "Vehicle ID not found."
            self.showAlert = true
            return
        }
        
        logoutAPI(vehicleId: vehicleId) { success, message in
            DispatchQueue.main.async {
                self.alertMessage = message
                self.showAlert = true
                
                if success {
                    authManager.isAuthenticated = false
                    rideStore.vehicleId = nil
                    // Optionally, clear other sensitive data or perform additional cleanup here
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

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AuthManager())
            .environmentObject(RideStore.shared)
            .environmentObject(LocationManager())
    }
}
