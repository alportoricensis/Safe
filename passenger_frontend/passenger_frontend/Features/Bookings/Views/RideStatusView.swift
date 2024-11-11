import SwiftUI

struct RideStatusView: View {
    let rideId: Int
    @StateObject private var viewModel: RideStatusViewModel
    
    init(rideId: Int) {
        self.rideId = rideId
        self._viewModel = StateObject(wrappedValue: RideStatusViewModel(rideId: rideId))
    }
    
    var body: some View {
        VStack {
            Text("Ride Status")
                .font(.headline)
            
            if let status = viewModel.rideStatus {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Driver: \(status.driver)")
                    Text("Pickup: \(status.pickup)")
                    Text("ETA: \(status.ETA, formatter: DateFormatter.iso8601Full)")
                    Text("ETP: \(status.ETP, formatter: DateFormatter.iso8601Full)")
                }
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
                    .foregroundColor(.red)
            } else {
                ProgressView()
            }
        }
        .padding()
    }
}

#Preview {
    RideStatusView(rideId: 1234)
}
