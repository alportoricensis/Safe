//
//  RideList.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//

import SwiftUI

struct RideList: View {
    let ride: Ride
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                // Background color for the box
                Color.white
                    .cornerRadius(10)
                
                // VStack to display pick-up and drop-off locations vertically
                VStack(alignment: .leading, spacing: 4) {
                    if let pickupLoc = ride.pickcupLoc {
                        Text("Pick-up: \(pickupLoc)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let dropLoc = ride.dropLoc {
                        Text("Drop-off: \(dropLoc)")
                            .font(.subheadline)
                            .foregroundColor(.primary)
                    }
                }
                .padding() // Adds padding inside the gray box
            }
            .padding() // Adds padding around the gray box
        }
    }
}

