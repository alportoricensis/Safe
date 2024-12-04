import SwiftUI
import GoogleMaps

struct MapViewWrapper: UIViewRepresentable {
    @Binding var route: GMSPolyline?
    var initialCamera: CLLocationCoordinate2D
    var zoom: Float

    func makeUIView(context: Context) -> GMSMapView {
           // Create the camera for the map view
           let camera = GMSCameraPosition.camera(withLatitude: initialCamera.latitude,
                                                 longitude: initialCamera.longitude,
                                                 zoom: zoom)
           
           // Initialize the map view
           let mapView = GMSMapView(frame: .zero, camera: camera)
           
           // Enable location tracking if needed
           mapView.isMyLocationEnabled = true
           
           return mapView
       }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        // Clear the map before drawing the new route
        mapView.clear()

        // Draw the route if it exists
        if let route = route {
            route.map = mapView

            // Zoom to fit the polyline on the map
            if let path = route.path {
                let bounds = GMSCoordinateBounds(path: path)
                let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                mapView.moveCamera(cameraUpdate)
            }
        }
    }

    
    // Create a Coordinator to manage the map view lifecycle
    class Coordinator: NSObject {
        var mapView: GMSMapView?
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator()
    }
}

