import SwiftUI
import MapKit
import CoreLocation

// View for selecting pickup location on the map


// Main RideRequestView
struct RideRequestView: View {
    let service: Service
    @Environment(\.dismiss) private var dismiss

    @State private var isPickupMapPresented = false
    @State private var pickupLocation: CLLocationCoordinate2D?
    @State private var pickupLocationName: String = "Enter pickup point"

    var body: some View {
        ZStack {
            Color(red: 0/255, green: 39/255, blue: 76/255)
                .ignoresSafeArea()

            VStack(spacing: 16) {
                // Service name header
                Text("\(service.provider) - \(service.serviceName)")
                    .font(.title2)
                    .foregroundColor(.yellow)

                // Pickup and destination section with line indicator
                HStack(spacing: 12) {
                    // Location line indicator
                    VStack(spacing: 0) {
                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)

                        Rectangle()
                            .fill(.white)
                            .frame(width: 2, height: 40)

                        Circle()
                            .fill(.white)
                            .frame(width: 12, height: 12)
                    }

                    // Text fields changed to buttons
                    VStack(spacing: 16) {
                        Button(action: {
                            isPickupMapPresented = true
                        }) {
                            HStack {
                                Text(pickupLocationName)
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                        .sheet(isPresented: $isPickupMapPresented) {
                            PickupMapView { location in
                                self.pickupLocation = location
                                getAddressFrom(coordinate: location) { address in
                                    if let address = address {
                                        self.pickupLocationName = address
                                    } else {
                                        self.pickupLocationName = "Selected location"
                                    }
                                }
                            }
                        }

                        Button(action: {
                            // Add destination selection action here
                        }) {
                            HStack {
                                Text("Where to?")
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)
                        }
                    }
                }
                .padding(.horizontal)

                // Saved places button
                Button(action: {}) {
                    HStack {
                        Image(systemName: "star.fill")
                        Text("Saved Places")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                }

                // Set location on map button
                Button(action: {}) {
                    HStack {
                        Image(systemName: "map.fill")
                        Text("Set location on map")
                    }
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue.opacity(0.3))
                    .cornerRadius(8)
                }

                Spacer()
            }
            .padding()
        }
    }

    // Function to reverse geocode coordinates to address
    func getAddressFrom(coordinate: CLLocationCoordinate2D, completion: @escaping (String?) -> Void) {
        let geocoder = CLGeocoder()
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            if let placemark = placemarks?.first {
                var addressString = ""
                if let name = placemark.name {
                    addressString += name + ", "
                }
                if let city = placemark.locality {
                    addressString += city + ", "
                }
                if let state = placemark.administrativeArea {
                    addressString += state + ", "
                }
                if let country = placemark.country {
                    addressString += country
                }
                completion(addressString)
            } else {
                completion(nil)
            }
        }
    }
}
