import SwiftUI

struct CurrRidesView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var locationManager: LocationManager
    
    var body: some View {
        VStack {
            if let ride = store.rides.first(where: { $0.status != "Completed" }) {
                NavigationLink(destination: RideView(ride: ride).environmentObject(locationManager)) {
                    RideCardView(ride: ride)
                        .padding()
                }
                .buttonStyle(PlainButtonStyle()) // Removes default button styling
            } else {
                Text("No Current Rides Available")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
        .onAppear {
            Task {
                await store.getRides()
            }
        }
    }
}

struct CurrRidesView_Previews: PreviewProvider {
    static var previews: some View {
        CurrRidesView()
            .environmentObject(RideStore.shared)
            .environmentObject(LocationManager())
    }
}
