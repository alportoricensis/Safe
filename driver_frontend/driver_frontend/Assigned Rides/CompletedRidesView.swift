import SwiftUI

struct CompletedRidesView: View {
    @EnvironmentObject var store: RideStore

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 10) {
                let completedRides = store.rides.filter { $0.status == "Completed" }
                if completedRides.isEmpty {
                    Text("No Completed Rides Yet")
                        .foregroundColor(.gray)
                        .italic()
                        .padding()
                } else {
                    ForEach(completedRides) { ride in
                        RideCardView(ride: ride)
                            .padding(.horizontal)
                    }
                }
            }
            .padding(.top)
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
    }
}

struct CompletedRidesView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedRidesView()
            .environmentObject(RideStore.shared)
    }
}
