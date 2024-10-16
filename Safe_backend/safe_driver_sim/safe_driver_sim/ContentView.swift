//
//  ContentView.swift
//  Safe_Driver_Sim
//
//  Created by Alex Nunez on 10/15/24.
//

import SwiftUI

struct ContentView: View {
    @State private var isPresenting = false
    @State private var selected_vid: String = "Vehicle#288"
    
    var body: some View {
        HStack {
            VStack {
                Image(systemName: "car")
                    .imageScale(.large)
                    .foregroundStyle(.tint)
                Text("Select a vehicle to log in")
                HStack {
                    Text("Vehicle#288")
                    Button {
                        selected_vid = "Vehicle#288"
                        isPresenting.toggle()
                    } label: {
                        Image(systemName: "square.and.pencil")
                    }
                }
                
            }
            .fullScreenCover(isPresented: $isPresenting) {
                NavView(isPresenting: $isPresenting, vehicle: Vehicle(selected_vid))
            }
            .padding()
        }
    }
}

#Preview {
    ContentView()
}
