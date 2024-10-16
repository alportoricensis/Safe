//
//  Safe_Driver_SimApp.swift
//  Safe_Driver_Sim
//
//  Created by Alex Nunez on 10/15/24.
//

import SwiftUI

@main
struct Safe_Driver_SimApp: App {
    init() {
        LocManager.shared.startUpdates()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
