//
//  driver_frontendApp.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//

import SwiftUI
import GoogleMaps
@main
struct driver_frontendApp: App {
    
    @StateObject private var authManager = AuthManager()
    @StateObject private var locationManager = LocationManager()

    
    init(){
            if let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String {
                print("Google API Key: \(apiKey)") // Debug print
                GMSServices.provideAPIKey(apiKey)
            } else {
                print("Google API Key not found in Info.plist")
            }
            
            configureNavigationBarAppearance()
        }
    
    var body: some Scene {
            WindowGroup {
                if authManager.isAuthenticated {
                    MenuView()
                        .environmentObject(authManager)
                        .environmentObject(locationManager)
                } else {
                    LoginView()
                        .environmentObject(authManager)
                        .environmentObject(locationManager)
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

