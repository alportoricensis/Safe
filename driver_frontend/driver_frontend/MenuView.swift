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
    @State private var selectedOption: MenuOption?
    @EnvironmentObject var locationManager: LocationManager

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
                ) {
                    Text("Ride History")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                NavigationLink(destination: SettingsView()) {
                    Text("Settings")
                        .foregroundColor(.white)
                        .font(.headline)
                }
                NavigationLink(destination: SupportView()) {
                    Text("Support")
                        .foregroundColor(.white)
                        .font(.headline)
                }
            }
            .padding(.horizontal)
            .foregroundColor(.white)
            
            Spacer()
            
            // Footer Section
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
    }
}

struct MenuView_Previews: PreviewProvider {
    static var previews: some View {
        MenuView()
            .environmentObject(AuthManager())
            .environmentObject(RideStore.shared)
    }
}
