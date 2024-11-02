import SwiftUI

struct CurrRidesView: View {
    private let store = RideStore.shared

    var body: some View {
        VStack {
            List(store.rides) { ride in
                RideList(ride: ride)
                    .listRowSeparator(.hidden)
                    .listRowBackground(Color(red:0.2, green:0.2, blue:0.5)) // Set a single color for all rows
            }
            .listStyle(.plain) // Use plain style to avoid default background color
            .onAppear {
                store.getRides() // Populate rides when the view appears
            }
        }
        .background(Color(red: 0.2, green: 0.2, blue: 0.5)) // Set the background color to match the parent
        .edgesIgnoringSafeArea(.all) // Ensure it fills the entire area
    }
}

#Preview {
    CurrRidesView()
}
