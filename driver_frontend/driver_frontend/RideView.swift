import SwiftUI
import GoogleMaps
import CoreLocation


struct RideView: View {
    @EnvironmentObject var locationManager: LocationManager
    let ride: Ride

    @State private var buttonText: String = "Start"
    @State private var route: GMSPolyline?
    @State private var isAtPickup = false
    @State private var passengerPickedUp = false

    var body: some View {
        VStack {
            MapViewWrapper(route: $route, initialCamera: driverLocation, zoom: 15.0)
                .edgesIgnoringSafeArea(.all)
            
            Text(isAtPickup ? (passengerPickedUp ? "Successfully dropped off passenger" : "You have arrived at the pickup location") : "")
                .font(.headline)
                .padding()
            
            Button(action: handleButtonPress) {
                Text(buttonText)
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(10)
            }
            .padding()
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
            // Fallback to pickup location if driver location is unavailable
            return ride.pickupCoordinate
        }
    }

    private func handleButtonPress() {
        if !isAtPickup {
            isAtPickup = true
            buttonText = "Picked-Up Passenger"
            // You may want to check if the driver has reached the pickup location
        } else if !passengerPickedUp {
            passengerPickedUp = true
            buttonText = "Drop-Off Passenger"
            drawRoute(from: ride.pickupCoordinate, to: ride.dropOffCoordinate)
        } else {
            buttonText = "Trip Complete"
            // Handle trip completion logic
        }
    }
    
    private func drawRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        guard let apiKey = Bundle.main.object(forInfoDictionaryKey: "GOOGLE_API_KEY") as? String else {
            print("Google API Key not found in Info.plist")
            return
        }
        
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=\(apiKey)"
        guard let url = URL(string: urlString) else { return }
    
        URLSession.shared.dataTask(with: url) { data, _, error in
            guard let data = data, error == nil else { return }
    
            do {
                if let json = try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any],
                   let routes = json["routes"] as? [[String: Any]],
                   let overviewPolyline = routes.first?["overview_polyline"] as? [String: Any],
                   let points = overviewPolyline["points"] as? String {
                    DispatchQueue.main.async {
                        self.drawPath(from: points)
                        // Optionally, update the camera to show the entire route
                    }
                } else {
                    print("No routes found")
                }
            } catch {
                print("Error decoding route data: \(error)")
            }
        }.resume()
    }
    
    private func drawPath(from polyline: String) {
        guard let path = GMSPath(fromEncodedPath: polyline) else { return }
        route = GMSPolyline(path: path)
        route?.strokeWidth = 4
        route?.strokeColor = .blue
        // The MapViewWrapper will automatically display this route
    }
}



extension Ride {
    var pickupCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: pickupLatitude, longitude: pickupLongitude)
    }

    var dropOffCoordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: dropOffLatitude, longitude: dropOffLongitude)
    }
}

struct MapViewWrapper: UIViewRepresentable {
    @Binding var route: GMSPolyline?
    var initialCamera: CLLocationCoordinate2D
    var zoom: Float = 15.0

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition.camera(withLatitude: initialCamera.latitude, longitude: initialCamera.longitude, zoom: zoom)
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        context.coordinator.mapView = mapView
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {
        uiView.clear()
        route?.map = uiView
    }

    class Coordinator: NSObject {
        var parent: MapViewWrapper
        var mapView: GMSMapView?

        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
    }
}

