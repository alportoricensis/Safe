import SwiftUI

struct RideCardView: View {
    let ride: Ride
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading) {
                    Text("Pick-up: \(ride.pickupLoc)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Drop-off: \(ride.dropLoc)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Passenger: \(ride.passenger)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("Status: \(ride.status)")
                        .font(.subheadline)
                        .foregroundColor(ride.status == "Completed" ? .green : .orange)
                }
                Spacer()
                // Optional: Add an icon or image
                Image(systemName: "car.fill")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .foregroundColor(.yellow)
            }
            
            // Pickup Button (Visible only for Current Rides)
            if ride.status != "Completed" {
                NavigationLink(destination: RideView(ride: ride).environmentObject(RideStore.shared).environmentObject(locationManager).environmentObject(authManager)) {
                    Text("Pickup")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.green)
                        .cornerRadius(10)
                }
                .buttonStyle(PlainButtonStyle()) // Removes default button styling
            }
        }
        .padding()
        .background(Color(red: 2/255, green: 28/255, blue: 52/255)) // Dark background
        .cornerRadius(15)
        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 5)
    }
}

struct RideCardView_Previews: PreviewProvider {
    static var previews: some View {
        RideCardView(ride: Ride(
            pickupLoc: "Duderstadt Center",
            dropLoc: "South Quad",
            passenger: "John Doe",
            status: "Pending",
            id: "ride1",
            pickupLatitude: 42.2936,
            pickupLongitude: -83.7166,
            dropOffLatitude: 42.2745,
            dropOffLongitude: -83.7409
        ))
        .previewLayout(.sizeThatFits)
    }
}
