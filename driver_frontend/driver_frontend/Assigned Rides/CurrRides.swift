import SwiftUI

struct CurrRidesView: View {
    @EnvironmentObject var store: RideStore
    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                let currentRides = store.rides.filter { $0.status != "Completed" }
                
                if currentRides.isEmpty {
                    Text("No Current Rides Available")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    ForEach(currentRides) { ride in
                        NavigationLink(destination: RideView(ride: ride)
                                        .environmentObject(store)
                                        .environmentObject(locationManager)
                                        .environmentObject(authManager)) {
                            RideCardView(ride: ride)
                                .padding(.horizontal)
                                .environmentObject(store)
                                .environmentObject(locationManager)
                                .environmentObject(authManager)
                        }
                        .buttonStyle(PlainButtonStyle()) // Removes default button styling
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
    }
}

struct CurrRidesView_Previews: PreviewProvider {
    static var previews: some View {
        CurrRidesView()
            .environmentObject(RideStore.shared)
            .environmentObject(LocationManager())
    }
}
