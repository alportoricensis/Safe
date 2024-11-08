//
//  SafeTopBar.swift
//  passenger_frontend
//
//  Created by Kunal Mansukhani on 11/7/24.
//
import SwiftUI

struct SafeTopBar: ViewModifier {
    let title: String
    
    func body(content: Content) -> some View {
        VStack(spacing: 0) {
            // Top Bar
            HStack {
                Text("SAFE!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.yellow)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 2/255, green: 28/255, blue: 52/255))
            
            // Main Content
            content
        }
        .navigationBarHidden(true) // Hides default navigation bar
    }
}

// Create a View extension for easier use
extension View {
    func withSafeTopBar(title: String = "SAFE!") -> some View {
        modifier(SafeTopBar(title: title))
    }
} 
