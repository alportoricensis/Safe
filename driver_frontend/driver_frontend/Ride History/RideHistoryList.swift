import SwiftUI
struct RideHistoryList: View {
    let hist: DriverRideHistory
    @State private var isLoading = false
    @State private var isUnloading = false
    @State private var alertMessage: String? = nil
    @State private var showAlert = false
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                Color.white
                    .cornerRadius(10)
                
                VStack(alignment: .leading, spacing: 4) {
                    if let rideDate = hist.rideDate {
                        Text("Date: \(rideDate)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    
                    if let passCount = hist.passCount{
                        Text("Passengers: \(passCount)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    if let miles = hist.miles {
                        Text("Miles: \(miles)")
                            .font(.headline)
                            .foregroundColor(.primary)
                    }
                    }
                }
                .padding()
            }
            .padding()
        }
    }
