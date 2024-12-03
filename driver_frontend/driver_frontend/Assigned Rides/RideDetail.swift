import SwiftUI

struct RideDetailView: View {
    let ride: Ride
    @Environment(\.presentationMode) var presentationMode
    @State private var showAlert = false
    @State private var alertMessage: String = ""

    var body: some View {
        VStack(spacing: 20) {
            Text("Ride Details")
                .font(.largeTitle)
                .padding()

            if let pickupLoc = ride.pickupLoc {
                Text("Pick-up: \(pickupLoc)")
                    .font(.headline)
            }

            if let dropLoc = ride.dropLoc {
                Text("Drop-off: \(dropLoc)")
                    .font(.headline)
            }
            if let passenger = ride.passenger {
                Text("Passenger: \(passenger)")
                    .font(.headline)
            }

            Button(action: {
                completeRide()
            }) {
                Text("Complete Ride")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .background(Color.blue)
                    .cornerRadius(10)
            }
            .alert(isPresented: $showAlert) {
                Alert(title: Text("Ride Status"), message: Text(alertMessage), dismissButton: .default(Text("OK"), action: {
                    presentationMode.wrappedValue.dismiss()
                }))
            }

            Spacer()
        }
        .padding()
    }

    func completeRide() {
        // Update the ride status to "Completed"
        RideStore.shared.updateRideStatus(rideId: ride.id ?? "", status: "Completed")

        // Optionally, make an API call to update the backend

        alertMessage = "Ride has been marked as completed."
        showAlert = true
    }
}
