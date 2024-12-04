import SwiftUI
import GoogleMaps
import CoreLocation

struct RideView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var store: RideStore
    let ride: Ride

    @State private var buttonText: String = "Start"
    @State private var route: GMSPolyline?
    @State private var isAtPickup = false
    @State private var passengerPickedUp = false

    var body: some View {
        ZStack {
            // Google Map View as Background
            MapViewWrapper(route: $route, initialCamera: driverLocation, zoom: 15.0)
                .edgesIgnoringSafeArea(.all)
            
            // Foreground UI
            VStack {
                Spacer()
                VStack(spacing: 10) {
                    if isAtPickup {
                        Text(passengerPickedUp ? "Successfully dropped off passenger" : "You have arrived at the pickup location")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.black.opacity(0.6))
                            .cornerRadius(10)
                    }
                    
                    Button(action: handleButtonPress) {
                        Text(buttonText)
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                    }
                    .padding([.horizontal, .bottom])
                }
                .background(Color(red: 2/255, green: 28/255, blue: 52/255).opacity(0.8))
                .cornerRadius(15)
                .padding()
            }
        }
        .onAppear {
            guard let driverLocation = locationManager.location?.coordinate else {
                print("Driver location not available")
                return
            }
            drawRoute(from: driverLocation, to: ride.pickupCoordinate)
        }
    }

    private var driverLocation: CLLocationCoordinate2D {
        if let location = locationManager.location?.coordinate {
            return location
        } else {
            return ride.pickupCoordinate
        }
    }


    private func handleButtonPress() {
        if !isAtPickup {
            isAtPickup = true
            buttonText = "Picked-Up Passenger"
        } else if !passengerPickedUp {
            passengerPickedUp = true
            buttonText = "Drop-Off Passenger"
            drawRoute(from: ride.pickupCoordinate, to: ride.dropOffCoordinate)
        } else {
            buttonText = "Trip Complete"
            completeTrip()
        }
    }
    
    private func sendLoadUnloadAPI(rideId: String, vehicleId: String, reqType: String) async -> Bool {
        guard let url = URL(string: "http://18.191.14.26/api/v1/vehicles/load_unload/") else {
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "ride_id": rideId,
            "vehicle_id": vehicleId,
            "type": reqType // either "boarding" or "unloading"
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            let (_, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                return true
            } else {
                print("Failed to load/unload ride. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return false
            }
        } catch {
            print("Error sending load/unload request: \(error.localizedDescription)")
            return false
        }
    }

    
    private func sendLoadRequest() {
        Task {
            let success = await sendLoadUnloadAPI(rideId: ride.id, vehicleId: store.vehicleId ?? "", reqType: "boarding")
            DispatchQueue.main.async {
                if success {
                    print("Successfully onboarded passenger.")
                } else {
                    print("Failed to board passenger.")
                }
            }
        }
    }

    private func sendUnloadRequest() {
        Task {
            let success = await sendLoadUnloadAPI(rideId: ride.id, vehicleId: store.vehicleId ?? "", reqType: "unloading")
            DispatchQueue.main.async {
                if success {
                    print("Successfully offboarded passenger.")
                } else {
                    print("Failed to offboard passenger.")
                }
            }
        }
    }
    
    private func drawRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String else {
            print("Google API Key not found in Info.plist")
            return
        }
        
        let originString = "\(origin.latitude),\(origin.longitude)"
        let destinationString = "\(destination.latitude),\(destination.longitude)"
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(originString)&destination=\(destinationString)&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
        print(url)
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch route data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
    
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    print("JSON is valid: \(json)")
                    
                    if let routes = json["routes"] as? [[String: Any]] {
                        print("Routes found: \(routes)")
                        
                        if let overviewPolyline = routes.first?["overview_polyline"] as? [String: Any] {
                            print("Overview polyline found: \(overviewPolyline)")
                            if let points = overviewPolyline["points"] as? String {
                                print("Points found: \(points)")
                                DispatchQueue.main.async {
                                    self.drawPath(from: points)
                                }
                            } else {
                                print("No 'points' found in overview_polyline.")
                            }
                        } else {
                            print("No 'overview_polyline' found in first route.")
                        }
                    } else {
                        print("No 'routes' found in JSON.")
                    }
                } else {
                    print("Failed to parse JSON.")
                }
            } catch {
                print("Error decoding route data: \(error)")
            }

        }.resume()
    }
    
    private func drawPath(from polyline: String) {
        guard let path = GMSPath(fromEncodedPath: polyline) else {
            print("Failed to decode polyline.")
            return
        }
        route = GMSPolyline(path: path)
        route?.strokeWidth = 4
        route?.strokeColor = .blue
    }
    
    private func completeTrip() {
        store.updateRideStatus(rideId: ride.id, status: "Completed")
                sendUnloadRequest()
                Task {
            let success = await completeRideAPI(rideId: ride.id)
            DispatchQueue.main.async {
                if success {
                    // Navigate back to list of currently assigned rides
                }
            }
        }
    }
    
    private func completeRideAPI(rideId: String) async -> Bool {
        guard let vehicleId = store.vehicleId else {
            return false
        }
        
        guard let url = URL(string: "http://18.191.14.26/api/v1/vehicles/complete_ride/") else { // Update with correct endpoint
            return false
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let requestBody: [String: Any] = [
            "ride_id": rideId,
            "vehicle_id": vehicleId
        ]
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody, options: [])
            
            let (data, response) = try await URLSession.shared.data(for: request)
            
            if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                // Optionally, parse response if needed
                return true
            } else {
                print("Failed to mark ride as completed. Status code: \((response as? HTTPURLResponse)?.statusCode ?? 0)")
                return false
            }
        } catch {
            print("Error completing ride: \(error.localizedDescription)")
            return false
        }
    }
}
