import SwiftUI

struct MainTabView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var selectedTab: Tab = .services
    
    private let backgroundColor = Color(red: 0/255, green: 39/255, blue: 76/255)
    private let selectedColor = Color(red: 255/255, green: 203/255, blue: 5/255) // Yellow
    private let unselectedColor = Color.white

    enum Tab {
        case services, bookings, account
    }

    var body: some View {
        TabView(selection: $selectedTab) {
            RideServicesView(selectedTab: $selectedTab)
                .tabItem {
                    Label {
                        Text("Services")
                    } icon: {
                        Image(systemName: "paperplane.fill")
                    }
                }
                .tag(Tab.services)
            
            BookingsView()
                .tabItem {
                    Label {
                        Text("Bookings")
                    } icon: {
                        Image(systemName: "book.fill")
                    }
                }
                .tag(Tab.bookings)
            
            AccountView()
                .tabItem {
                    Label {
                        Text("Account")
                    } icon: {
                        Image(systemName: "person.fill")
                    }
                }
                .tag(Tab.account)
        }
        .onAppear {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = UIColor(backgroundColor)
            
            appearance.stackedLayoutAppearance.normal.iconColor = UIColor(unselectedColor)
            appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(unselectedColor)]
            
            appearance.stackedLayoutAppearance.selected.iconColor = UIColor(selectedColor)
            appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(selectedColor)]
            
            UITabBar.appearance().standardAppearance = appearance
            if #available(iOS 15.0, *) {
                UITabBar.appearance().scrollEdgeAppearance = appearance
            }
        }
    }
}
