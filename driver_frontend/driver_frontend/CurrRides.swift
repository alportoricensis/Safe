import SwiftUI

struct CurrRidesView: View {
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var rideStore: RideStore
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        NavigationView {
            List(rideStore.rides) { ride in
                NavigationLink(destination: RideView(ride: ride).environmentObject(locationManager)) {
                    RideList(ride: ride)
                }
            }
            .listStyle(.plain)
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
}

