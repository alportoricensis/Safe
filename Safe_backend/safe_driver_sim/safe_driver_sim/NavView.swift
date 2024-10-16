//
//  NavView.swift
//  Safe_Driver_Sim
//
//  Created by Alex Nunez on 10/15/24.
//

import SwiftUI
import MapKit

struct NavView: View {
    // Variables
    @Binding var isPresenting: Bool
    @State var cameraPosition = MapCameraPosition.region(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: LocManager.shared.location.coordinate.latitude, longitude: LocManager.shared.location.coordinate.longitude), span: MKCoordinateSpan(latitudeDelta: 0.02, longitudeDelta: 0.02)))
    var vehicle: Vehicle
    
    // Functions
    var body: some View {
        HStack {
            VStack {
                Text(vehicle.vehicle_id)
                Text("Current Location (lat, long):")
                Text("\(LocManager.shared.location.coordinate.latitude), \(LocManager.shared.location.coordinate.longitude)")
                    .onChange(of: LocManager.shared.location.coordinate.latitude) {
                        vehicle.postLocation()
                    }
                Text("Current Itinerary:")
            }
            Map(position: $cameraPosition) {
                Marker(vehicle.vehicle_id, systemImage: "car", coordinate: LocManager.shared.location.coordinate)
            }
            .mapControls {
                 MapUserLocationButton()
                 MapCompass()
                 MapScaleView()
             }
        }
        .onAppear() {
            vehicle.loginVehicle()
        }
    }
}
