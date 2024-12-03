import SwiftUI

struct CompletedRidesView: View {
    @EnvironmentObject var rideStore: RideStore
    @EnvironmentObject var locationManager: LocationManager
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        List(rideStore.rides.filter { $0.status == "Completed" }) { ride in
            RideList(ride: ride)
                .listRowSeparator(.hidden)
                .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
        }
        .listStyle(.plain)
        .refreshable {
            await rideStore.getRides()
        }
        .onAppear {
            Task {
                await rideStore.getRides()
            }
        }
        .onReceive(timer) { _ in
            Task {
                await rideStore.getRides()
            }
        }
    }
}

struct CompletedRidesView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedRidesView()
            .environmentObject(RideStore.shared)
            .environmentObject(LocationManager())
    }
}
