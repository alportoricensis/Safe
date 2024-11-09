//
//  AuthViewModel.swift
//  driver_frontend
//
//  Created by James Nesbitt on 11/7/24.
//
import Combine
import SwiftUI

class AuthViewModel: ObservableObject {
    @Published var isAuthenticated = false
    @Published var username = ""
    @Published var password = ""

    func login(username: String, password: String) {
        // Implement your actual login logic here.
        // For this example, we'll simulate a successful login.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.username = username
            self.password = password
            self.isAuthenticated = true
        }
    }
}
