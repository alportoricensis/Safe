import SwiftUI
import MapKit
import CoreLocation

struct RideRequestView: View {
    let service: Service
    @StateObject private var viewModel = RideRequestViewModel()
    @EnvironmentObject var authViewModel: AuthViewModel

    @Environment(\.dismiss) private var dismiss

    @State private var pickupLocationName: String = "Enter pickup point"
    @State private var isDestinationMapPresented = false
    @State private var destinationLocation: CLLocationCoordinate2D?
    @State private var destinationLocationName: String = "Where to?"
    @State private var navigateToWaiting = false
    @State private var isScheduledRide = false
    @State private var scheduledDateTime = Date().addingTimeInterval(15 * 60)

    var body: some View {
        NavigationStack {
            ZStack {
                Color(red: 0/255, green: 39/255, blue: 76/255)
                    .ignoresSafeArea()

                VStack(spacing: 16) {
                    Text("\(service.provider) - \(service.serviceName)")
                        .font(.title2)
                        .foregroundColor(.yellow)

                    HStack(spacing: 12) {
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

                        VStack(spacing: 16) {
                            Picker("Select Pickup Location", selection: $pickupLocationName) {
                                Text("Enter pickup point")
                                    .foregroundColor(.gray)
                                    .tag("Enter pickup point")
                                ForEach(viewModel.validPickupLocations) { location in
                                    Text(location.name)
                                        .tag(location.name)
                                }
                            }
                            .pickerStyle(.menu)
                            .accentColor(.black)
                            .tint(.black)
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

                    Toggle("Schedule for later", isOn: $isScheduledRide)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    if isScheduledRide {
                        DatePicker(
                            "Pick-up time",
                            selection: $scheduledDateTime,
                            in: Date()...,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                        .tint(.yellow)
                    }

                    Spacer()

                    if pickupLocationName != "Enter pickup point" && destinationLocation != nil {
                        Button(action: {
                            viewModel.requestRide(
                                service: service,
                                pickupLocation: pickupLocationName,
                                dropoffLocationName: destinationLocationName,
                                dropoffLocation: destinationLocation!,
                                isScheduled: isScheduledRide,
                                scheduledTime: isScheduledRide ? scheduledDateTime : nil
                            )
                            navigateToWaiting = true
                        }) {
                            Text(isScheduledRide ? "Schedule Ride" : "Confirm Destination")
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
        .onAppear {
            viewModel.authViewModel = authViewModel
            viewModel.fetchPickupLocations()
        }
    }

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
