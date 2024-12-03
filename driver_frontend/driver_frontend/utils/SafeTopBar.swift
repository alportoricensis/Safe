//
//  SafeTopBar.swift
//  driver_frontend
//
//  Created by Aryan Pal on 11/10/24.
//


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
            HStack {
                Text("SAFE!")
                    .font(.largeTitle)
                    .bold()
                    .foregroundColor(.yellow)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(Color(red: 2/255, green: 28/255, blue: 52/255))
            
            content
        }
        .navigationBarHidden(true)
    }
}

extension View {
    func withSafeTopBar(title: String = "SAFE!") -> some View {
        modifier(SafeTopBar(title: title))
    }
}