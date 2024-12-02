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
    @State private var selectedOption: MenuOption?

    var body: some View {
        NavigationView {
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
                            Text(authManager.username ?? "Unknown User")
                                .font(.headline)
                            
                            Divider()
                            
                            NavigationLink(destination: MessagesView()) {
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
                
                // Menu Options
                VStack(alignment: .leading, spacing: 15) {
                    NavigationLink(destination: AssignedRidesView()) {
                        Text("Assigned Rides")
                    }
                    NavigationLink(destination: RideHistoryView()) {
                        Text("Ride History")
                    }
                    NavigationLink(destination: SettingsView()) {
                        Text("Settings")
                    }
                    NavigationLink(destination: SupportView()) {
                        Text("Support")
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
            }
            .background(Color(red: 0/255, green: 39/255, blue: 76/255))
            .navigationBarHidden(true) // Hide navigation bar in menu
        }
    }
}
