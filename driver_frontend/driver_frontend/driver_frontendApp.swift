import SwiftUI
import GoogleMaps

@main
struct driver_frontendApp: App {
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var rideStore = RideStore.shared // Use shared instance
    
    init(){
        if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String {
            GMSServices.provideAPIKey(apiKey)
        }
        
        configureNavigationBarAppearance()
    }
    
    var body: some Scene {
        WindowGroup {
            if authManager.isAuthenticated {
                MenuView()
                    .environmentObject(authManager)
                    .environmentObject(locationManager)
                    .environmentObject(rideStore) // Inject RideStore
            } else {
                LoginView()
                    .environmentObject(authManager)
                    .environmentObject(locationManager)
                    .environmentObject(rideStore) // Inject RideStore
            }
        }
    }
    
    private func configureNavigationBarAppearance() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = UIColor(red: 2/255, green: 28/255, blue: 52/255, alpha: 1)
        appearance.titleTextAttributes = [.foregroundColor: UIColor.yellow]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.yellow]
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
