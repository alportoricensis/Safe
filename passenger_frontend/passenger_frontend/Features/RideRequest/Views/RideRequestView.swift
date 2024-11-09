import SwiftUI
import MapKit
import CoreLocation

// View for selecting pickup location on the map


// Main RideRequestView
struct RideRequestView: View {
    let service: Service
    @StateObject private var viewModel = RideRequestViewModel()
    @Environment(\.dismiss) private var dismiss

    @State private var pickupLocationName: String = "Enter pickup point"

    @State private var isDestinationMapPresented = false
    @State private var destinationLocation: CLLocationCoordinate2D?
    @State private var destinationLocationName: String = "Where to?"

    @State private var navigateToWaiting = false

    var body: some View {
        NavigationStack {
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
                            // Replace Button with Picker for pickup location
                            Picker("Select Pickup Location", selection: $pickupLocationName) {
                                Text("Enter pickup point")
                                    .foregroundColor(.gray)
                                    .tag("Enter pickup point")
                                ForEach(viewModel.validPickupLocations, id: \.self) { location in
                                    Text(location)
                                        .tag(location)
                                }
                            }
                            .pickerStyle(.menu)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white)
                            .cornerRadius(8)

                            Button(action: {
                                isDestinationMapPresented = true
                            }) {
                                HStack {
                                    Text(destinationLocationName)
                                        .foregroundColor(.black)
                                    Spacer()
                                }
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .cornerRadius(8)
                            }
                            .sheet(isPresented: $isDestinationMapPresented) {
                                PickupMapView { location in
                                    self.destinationLocation = location
                                    getAddressFrom(coordinate: location) { address in
                                        if let address = address {
                                            self.destinationLocationName = address
                                        } else {
                                            self.destinationLocationName = "Selected location"
                                        }
                                    }
                                }
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

                    // New Confirm Ride button
                    if pickupLocationName != "Enter pickup point" && destinationLocation != nil {
                        Button(action: {
                            viewModel.requestRide(
                                service: service,
                                pickupLocation: pickupLocationName,
                                dropoffLocationName: destinationLocationName,
                                dropoffLocation: destinationLocation!
                            )
                            navigateToWaiting = true
                        }) {
                            Text("Confirm Destination")
                                .font(.headline)
                                .foregroundColor(.yellow)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color(red: 2/255, green: 28/255, blue: 52/255))
                                .cornerRadius(8)
                        }
                        .padding(.horizontal)
                    }
                }
                .padding()
            }
            .navigationDestination(isPresented: $navigateToWaiting) {
                WaitingView(viewModel: viewModel)
            }
            // Add alert for error handling
            .alert("Error", isPresented: .init(
                get: { if case .error(_) = viewModel.state { return true } else { return false } },
                set: { _ in viewModel.state = .idle }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                if case .error(let message) = viewModel.state {
                    Text(message)
                }
            }
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
