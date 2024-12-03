import SwiftUI
import GoogleMaps

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
        uiView.clear() // Remove existing overlays
        route?.map = uiView // Add the route overlay to the map
    }

    class Coordinator: NSObject {
        var parent: MapViewWrapper
        var mapView: GMSMapView?

        init(_ parent: MapViewWrapper) {
            self.parent = parent
        }
    }
}
