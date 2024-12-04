import SwiftUI
import GoogleMaps

struct MapViewWrapper: UIViewRepresentable {
    @Binding var route: GMSPolyline?
    var initialCamera: CLLocationCoordinate2D
    var zoom: Float

    func makeUIView(context: Context) -> GMSMapView {
           let camera = GMSCameraPosition.camera(withLatitude: initialCamera.latitude,
                                                 longitude: initialCamera.longitude,
                                                 zoom: zoom)
           
           let mapView = GMSMapView(frame: .zero, camera: camera)
                      mapView.isMyLocationEnabled = true
           
           return mapView
       }

    func updateUIView(_ mapView: GMSMapView, context: Context) {
        mapView.clear()

        if let route = route {
            route.map = mapView

            // Zoom to fit the route on the map
            if let path = route.path {
                let bounds = GMSCoordinateBounds(path: path)
                let cameraUpdate = GMSCameraUpdate.fit(bounds, withPadding: 50.0)
                mapView.moveCamera(cameraUpdate)
            }
        }
    }
}

