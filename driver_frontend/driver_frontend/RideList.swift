//
//  RideList.swift
//  driver_frontend
//
//  Created by Bhavesh Vuyyuru on 11/1/24.
//

import SwiftUI

struct RideList: View {
    let ride: Ride
    @State private var isLoading = false
    @State private var isUnloading = false
    @State private var alertMessage: String? = nil
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Color.white
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let pickupLoc = ride.pickupLoc {
                        Text("Pick-up: \(pickupLoc)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let dropLoc = ride.dropLoc {
                        Text("Drop-off: \(dropLoc)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    if let passenger = ride.passenger {
                        Text("Passenger: \(passenger)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    Button(action: {
                        if ride.status == "In-Progress" {
                            unloadPassenger(ride)
                        } else {
                            loadPassenger(ride)
                        }
                    }) {
                        Text(ride.status == "In-Progress" ? "Unload" : "Pickup")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(ride.status == "In-Progress" ? Color.red : Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                    .alert(isPresented: $showAlert) {
                        Alert(title: Text("Status"), message: Text(alertMessage ?? ""), dismissButton: .default(Text("OK")))
                    }
                }
                .padding()
            }
            .padding()
        }
    }
    
    func loadPassenger(_ ride: Ride) {
        isLoading = true
        RideStore.shared.updateRideStatus(rideId: ride.id ?? "", status: "In-Progress")
        
        Task {
            let success = await loadUnloadAPI(rideId: ride.id ?? "", action: "boarding")
            DispatchQueue.main.async {
                if success {
                    alertMessage = "Successfully picked up the passenger."
                } else {
                    alertMessage = "Failed to pick up the passenger."
                }
                showAlert = true
                isLoading = false
            }
        }
    }
    
    func unloadPassenger(_ ride: Ride) {
        isUnloading = true
        RideStore.shared.updateRideStatus(rideId: ride.id ?? "", status: "Completed")
        
        Task {
            let success = await loadUnloadAPI(rideId: ride.id ?? "", action: "unloading")
            DispatchQueue.main.async {
                if success {
                    alertMessage = "Successfully unloaded the passenger."
                } else {
                    alertMessage = "Failed to unload the passenger."
                }
                showAlert = true
                isUnloading = false
            }
        }
    }
    
    func loadUnloadAPI(rideId: String, action: String) async -> Bool {
        guard let vehicleId = RideStore.shared.vehicleId else {
            return false
        }
        
        guard let url = URL(string: "http://18.191.14.26/api/v1/vehicles/load_unload/") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "ride_id": rideId,
            "vehicle_id": vehicleId,
            "type": action
        ]
        
        do {
            let data = try JSONSerialization.data(withJSONObject: requestBody)
            request.httpBody = data
            
            let (responseData, _) = try await URLSession.shared.data(for: request)
            if let jsonResponse = try? JSONSerialization.jsonObject(with: responseData) as? [String: Any],
               let message = jsonResponse["msg"] as? String {
                print(message)
                return true
            }
        } catch {
            print("API Error: \(error.localizedDescription)")
        }
        
        return false
    }
}





