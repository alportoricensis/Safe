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
        .accentColor(.yellow)
    }
}
