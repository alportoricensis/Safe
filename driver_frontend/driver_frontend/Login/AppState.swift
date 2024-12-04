//
//  AppState.swift
//  driver_frontend
//
//  Created by James Nesbitt on 11/6/24.
//
import Foundation

class AppState: ObservableObject {
    @Published var vehicleID: String = ""
    @Published var isLoggedIn: Bool = false
}

