import SwiftUI
import GoogleMaps
import CoreLocation

struct RideView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var authManager: AuthManager
    @Environment(\.presentationMode) var presentationMode
    let ride: Ride

    @State private var buttonText: String = "Go to pickup"
    @State private var route: GMSPolyline?
    @State private var isAtPickup = false
    @State private var passengerPickedUp = false
    @State private var started = false

    var body: some View {
        ZStack {
            // Google Map View as Background
            MapViewWrapper(route: $route, initialCamera: driverLocation, zoom: 15.0)
                .edgesIgnoringSafeArea(.all)
            
            // Foreground UI
            VStack {
                Spacer()
                VStack(spacing: 10) {
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
        if !started{
            started=true
            buttonText="Picked-up Passenger"
        }
        else if !isAtPickup {
            isAtPickup = true
            buttonText = "Drop-Off Passenger"
            drawRoute(from: ride.pickupCoordinate, to: ride.dropOffCoordinate)
            sendLoadRequest()
        }
        else if !passengerPickedUp {
            passengerPickedUp = true
            buttonText = "Trip Completed"
            sendUnloadRequest()
        }
        else{
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
//        print(url)
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else {
                print("Failed to fetch route data: \(error?.localizedDescription ?? "Unknown error")")
                return
            }
    
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    if let routes = json["routes"] as? [[String: Any]] {
                        if let overviewPolyline = routes.first?["overview_polyline"] as? [String: Any] {
                            if let points = overviewPolyline["points"] as? String {
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
        print("completed the ride")
        presentationMode.wrappedValue.dismiss()
    }
    
}
