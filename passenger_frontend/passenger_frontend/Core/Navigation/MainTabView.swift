import SwiftUI
struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        TabView {
            RideServicesView()
                .tabItem {
                    Image(systemName: "paperplane.fill")
                    Text("Services")
                }
            
            BookingsView()
                .tabItem {
                    Image(systemName: "book.fill")
                    Text("Bookings")
                }
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                    Text("Account")
                }
        }
        .accentColor(Color(red: 255/255, green: 203/255, blue: 5/255))
    }
}
