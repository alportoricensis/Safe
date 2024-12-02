//
//  AuthViewModel.swift
//  driver_frontend
//
//  Created by James Nesbitt on 11/7/24.
//
import Combine

import Combine

class AuthManager: ObservableObject {
    @Published var isAuthenticated = true
    @Published var vehicleID: String?    
    var username: String?
    var password: String?
}

