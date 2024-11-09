//
//  AuthViewModel.swift
//  driver_frontend
//
//  Created by James Nesbitt on 11/7/24.
//
import Combine

import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = false
    @Published var vehicleID: String?
    @Published var latitude: Double?
    @Published var longitude: Double?
    
    var username: String?
    var password: String?
}

