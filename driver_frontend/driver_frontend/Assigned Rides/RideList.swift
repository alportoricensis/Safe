import SwiftUI

struct RideList: View {
    let ride: Ride
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Color.white
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let pickupLoc = ride.pickupLoc {
                        Text("Pick-up: \(pickupLoc)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let dropLoc = ride.dropLoc {
                        Text("Drop-off: \(dropLoc)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    if let passenger = ride.passenger {
                        Text("Passenger: \(passenger)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    NavigationLink(destination: RideDetailView(ride: ride)) {
                        Text("Pickup")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(10)
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .padding()
        }
    }
}
