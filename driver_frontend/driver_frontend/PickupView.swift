//
//  PickupView.swift
//  driver_frontend
//
//  Created by James Nesbitt on 12/2/24.
//
import SwiftUI

struct PickupView: View {
    let ride: Ride

    var body: some View {
        VStack {
            Text("Pickup View")
                .font(.largeTitle)
                .padding()

            Text("Pickup details for ride ID: \(ride.id ?? "N/A")")
                .padding()

            Spacer()
        }
        .navigationBarTitle("Pickup", displayMode: .inline)
    }
}

struct EditView: View {
    let ride: Ride

    var body: some View {
        VStack {
            Text("Edit View")
                .font(.largeTitle)
                .padding()

            Text("Edit details for ride ID: \(ride.id ?? "N/A")")
                .padding()

            Spacer()
        }
        .navigationBarTitle("Edit Ride", displayMode: .inline)
    }
}

