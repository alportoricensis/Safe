//
//  driver_frontendApp.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//

import SwiftUI

@main
struct driver_frontendApp: App {
    @StateObject var appState = AppState()

    var body: some Scene {
        WindowGroup {
            if appState.isLoggedIn {
                ContentView()
                    .environmentObject(appState)
            } else {
                LoginView()
                    .environmentObject(appState)
            }
        }
    }
}

