import SwiftUI
import GoogleMaps
import CoreLocation

struct RideView: View {
    @EnvironmentObject var locationManager: LocationManager
    let ride: Ride
    
    @State private var buttonText: String = "Start"
    @State private var currentRoute: GMSPolyline?
    @State private var mapView = GMSMapView()
    @State private var isAtPickup = false
    @State private var passengerPickedUp = false
    
    var body: some View {
        VStack {
            MapViewWrapper(mapView: $mapView, currentRoute: $currentRoute)
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
        }
    }
    
    private func drawRoute(from origin: CLLocationCoordinate2D, to destination: CLLocationCoordinate2D) {
        let urlString = "https://maps.googleapis.com/maps/api/directions/json?origin=\(origin.latitude),\(origin.longitude)&destination=\(destination.latitude),\(destination.longitude)&key=YOUR_API_KEY"
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
                    }
                }
            } catch {
                print("Error decoding route data: \(error)")
            }
        }.resume()
    }
    
    private func drawPath(from polyline: String) {
        guard let path = GMSPath(fromEncodedPath: polyline) else { return }
        currentRoute?.map = nil // Remove existing route
        currentRoute = GMSPolyline(path: path)
        currentRoute?.strokeWidth = 4
        currentRoute?.strokeColor = .blue
        currentRoute?.map = mapView
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
    @Binding var mapView: GMSMapView
    @Binding var currentRoute: GMSPolyline?

    func makeUIView(context: Context) -> GMSMapView {
        let camera = GMSCameraPosition(latitude: 0, longitude: 0, zoom: 15) // Default initial position
        let mapView = GMSMapView(frame: .zero, camera: camera)
        mapView.isMyLocationEnabled = true
        self.mapView = mapView
        return mapView
    }

    func updateUIView(_ uiView: GMSMapView, context: Context) {}
}
