import SwiftUI
import Combine
struct TodaysRides: View {
    
    @State private var tdrides = [DriverRideHistory]()
    var body: some View {
        VStack {
            List(tdrides) { ride in
                RideHistoryList(hist: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    await getTodaysRides()
                }
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
    func getTodaysRides() async {
            let fetchedRides = [
                DriverRideHistory(
                    rideDate: "2024-12-01",
                    passCount: "3",
                    miles: "15.5",
                    id: "1"
                ),
                DriverRideHistory(
                    rideDate: "2024-12-02",
                    passCount: "4",
                    miles: "10.0",
                    id: "2"
                )
            ]
            tdrides = fetchedRides
    }
}
#Preview {
    TodaysRides()
}

