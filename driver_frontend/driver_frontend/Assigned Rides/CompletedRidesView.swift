import SwiftUI

struct CompletedRidesView: View {
    @EnvironmentObject var store: RideStore
    
    var body: some View {
        VStack {
            if let ride = store.rides.first(where: { $0.status == "Completed" }) {
                RideCardView(ride: ride)
                    .padding()
            } else {
                Text("No Completed Rides Yet")
                    .foregroundColor(.white)
                    .font(.headline)
                    .padding()
            }
        }
        .background(Color(red: 0/255, green: 39/255, blue: 76/255))
        .edgesIgnoringSafeArea(.all)
    }
}

struct CompletedRidesView_Previews: PreviewProvider {
    static var previews: some View {
        CompletedRidesView()
            .environmentObject(RideStore.shared)
    }
}
