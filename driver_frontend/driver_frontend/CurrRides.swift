import SwiftUI

struct CurrRidesView: View {
    @EnvironmentObject var locationManager: LocationManager
    private let store = RideStore.shared
    private let timer = Timer.publish(every: 10, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            List(store.rides) { ride in
                NavigationLink(destination: RideView(ride: ride).environmentObject(locationManager)) {
                    RideList(ride: ride)
                        .listRowSeparator(.hidden)
                        .listRowBackground(Color(red: 0/255, green: 39/255, blue: 76/255))
                }
            }
            .listStyle(.plain)
            .onAppear {
                Task {
                    await store.getRides()
                }
            }
            .onReceive(timer) { _ in
                Task {
                    await store.getRides()
                }
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
}
