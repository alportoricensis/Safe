import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Tab = .services

    enum Tab {
        case services, bookings, account
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RideServicesView()
                .tabItem {
                    Image(systemName: "paperplane.fill")
                        .renderingMode(.template)
                        .foregroundColor(selectedTab == .services ? Color(red: 255/255, green: 203/255, blue: 5/255) : .white)
                    Text("Services")
                }
                .tag(Tab.services)
            
            BookingsView()
                .tabItem {
                    Image(systemName: "book.fill")
                        .renderingMode(.template)
                        .foregroundColor(selectedTab == .bookings ? Color(red: 255/255, green: 203/255, blue: 5/255) : .white)
                    Text("Bookings")
                }
                .tag(Tab.bookings)
            
            AccountView()
                .tabItem {
                    Image(systemName: "person.fill")
                        .renderingMode(.template)
                        .foregroundColor(selectedTab == .account ? Color(red: 255/255, green: 203/255, blue: 5/255) : .white)
                    Text("Account")
                }
                .tag(Tab.account)
        }
        .tint(Color(red: 255/255, green: 203/255, blue: 5/255))
        .toolbar(.visible, for: .tabBar)
        .toolbarBackground(.black, for: .tabBar)
    }
}
